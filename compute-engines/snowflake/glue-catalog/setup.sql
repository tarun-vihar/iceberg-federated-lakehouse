-- ========================================================================
-- Snowflake + AWS Glue Catalog Integration for Iceberg Tables
-- ========================================================================
-- Purpose: Configure Snowflake to read/write Iceberg tables via AWS Glue Catalog
-- Shared Setup: Uses SAME S3 tables as PySpark Glue demo
-- S3 Location: s3://tarun-lakehouse-bucket/catalogs/glue/
-- Architecture: Snowflake → Glue Catalog → S3 Iceberg Tables ← PySpark
-- ========================================================================

-- ========================================================================
-- STEP 1: CREATE EXTERNAL VOLUME
-- ========================================================================
-- External Volume connects Snowflake to S3 storage for Iceberg tables
-- This volume points to the SAME S3 path used by PySpark

USE ROLE accountadmin;

-- Clean up old volume if exists
DROP EXTERNAL VOLUME IF EXISTS glue_ext_volume;

-- Create External Volume pointing to shared S3 location
-- IMPORTANT: This MUST match the PySpark warehouse path
-- PySpark config: S3_WAREHOUSE_PATH = "s3://tarun-lakehouse-bucket/catalogs/glue"
CREATE EXTERNAL VOLUME glue_ext_volume
STORAGE_LOCATIONS = (
  ( NAME = 'glue_ext_volume'
    STORAGE_PROVIDER = 'S3'
    STORAGE_BASE_URL = 's3://tarun-lakehouse-bucket/catalogs/glue/'    -- Same as PySpark!
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::047825088072:role/ambari_snow_glue_linked'
  )
);

-- Get Snowflake IAM details for AWS trust relationship
-- CRITICAL: Copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID
-- Add these to the AWS IAM role trust relationship
DESC EXTERNAL VOLUME glue_ext_volume;

-- ========================================================================
-- STEP 2: UPDATE AWS IAM ROLE TRUST RELATIONSHIP
-- ========================================================================
-- Before proceeding, update the IAM role trust policy:
--
-- Go to AWS Console → IAM → Roles → ambari_snow_glue_linked → Trust relationships
-- Add the Principal (STORAGE_AWS_IAM_USER_ARN) and ExternalId from DESC above
--
-- Example Trust Policy:
-- {
--   "Version": "2012-10-17",
--   "Statement": [{
--     "Effect": "Allow",
--     "Principal": {
--       "AWS": "arn:aws:iam::123456789012:user/abc123-s..."  -- From DESC output
--     },
--     "Action": "sts:AssumeRole",
--     "Condition": {
--       "StringEquals": {
--         "sts:ExternalId": "ABC123_SFCRole=..."  -- From DESC output
--       }
--     }
--   }]
-- }
-- ========================================================================

-- ========================================================================
-- STEP 3: CREATE GLUE CATALOG INTEGRATION
-- ========================================================================
-- Catalog Integration connects Snowflake to AWS Glue Catalog
-- This allows Snowflake to discover tables managed by Glue

-- Clean up old integration if exists
DROP CATALOG INTEGRATION IF EXISTS ambari_prod_catalog_glue_int;

-- Create Catalog Integration for Glue
CREATE OR REPLACE CATALOG INTEGRATION ambari_prod_catalog_glue_int
  CATALOG_SOURCE = ICEBERG_REST                    -- Use Iceberg REST API
  TABLE_FORMAT = ICEBERG                           -- Iceberg table format
  CATALOG_NAMESPACE = 'prod'                       -- Same database as PySpark
  REST_CONFIG = (
    CATALOG_URI = 'https://glue.us-east-1.amazonaws.com/iceberg',  -- Glue REST endpoint
    CATALOG_API_TYPE = AWS_GLUE,                   -- Specify Glue catalog
    CATALOG_NAME = '047825088072'                  -- AWS account ID
  )
  REST_AUTHENTICATION = (
    TYPE = SIGV4,                                  -- AWS SigV4 authentication
    SIGV4_IAM_ROLE = 'arn:aws:iam::047825088072:role/ambari_snow_glue_linked',
    SIGV4_SIGNING_REGION = 'us-east-1'
  )
  ENABLED = TRUE,
  REFRESH_INTERVAL_SECONDS = 180;                  -- Refresh catalog every 3 minutes

-- Verify catalog integration was created
DESCRIBE CATALOG INTEGRATION ambari_prod_catalog_glue_int;

-- Grant permissions to iceberg_role (if exists)
-- Note: Create iceberg_role first if you don't have it (see create_external_volume.sql)
GRANT ALL ON INTEGRATION ambari_prod_catalog_glue_int TO ROLE iceberg_role WITH GRANT OPTION;

-- ========================================================================
-- STEP 4: CONFIGURE AWS LAKE FORMATION PERMISSIONS
-- ========================================================================
-- Lake Formation controls access to Glue catalog and S3 data
-- Run these commands in your terminal (not in Snowflake)
--
-- Required permissions for Snowflake IAM role:
-- - ALL on database 'prod'
-- - ALL on all tables in database
-- - DATA_LOCATION_ACCESS on S3 bucket

-- Grant ALL permissions on the database
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Database": { "Name": "prod" } }' \
  --permissions "ALL"

-- Grant ALL permissions on all tables in the database
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Table": { "DatabaseName": "prod", "TableWildcard": {} } }' \
  --permissions "ALL"

-- Grant specific permissions on database (alternative to ALL)
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Database": { "Name": "prod" } }' \
  --permissions "CREATE_TABLE" "ALTER" "DROP" "DESCRIBE"

-- Grant permissions on specific table (customer)
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Table": { "DatabaseName": "prod", "Name": "customer" } }' \
  --permissions "ALTER" "DESCRIBE" "SELECT" "INSERT" "DELETE" "DROP"

-- Grant data location access (allows reading S3 files)
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "DataLocation": { "ResourceArn": "arn:aws:s3:::tarun-lakehouse-bucket/catalogs/glue/" } }' \
  --permissions "DATA_LOCATION_ACCESS"

-- ========================================================================
-- STEP 5: CREATE LINKED DATABASE (Option 1)
-- ========================================================================
-- Creates a Snowflake database that automatically syncs with Glue Catalog
-- Tables created by PySpark will automatically appear here!

-- Clean up old database if exists
DROP DATABASE IF EXISTS ambari_glue_prod_LINKED_DB;

-- Create linked database
CREATE DATABASE ambari_glue_prod_LINKED_DB
  LINKED_CATALOG = (
    CATALOG = 'ambari_prod_catalog_glue_int'       -- Reference to catalog integration
  ),
  EXTERNAL_VOLUME = 'glue_ext_volume';             -- Reference to external volume

-- Check catalog link status
-- Expected: "executionState":"RUNNING" or "SUCCEEDED"
SELECT SYSTEM$CATALOG_LINK_STATUS('ambari_glue_prod_LINKED_DB');

-- Grant permissions to iceberg_role
GRANT ALL ON DATABASE ambari_glue_prod_LINKED_DB TO ROLE iceberg_role;
GRANT ALL ON SCHEMA ambari_glue_prod_LINKED_DB."prod" TO ROLE iceberg_role;

-- ========================================================================
-- VERIFICATION: Query PySpark-Created Table via Linked Database
-- ========================================================================
-- If PySpark has created the 'customer' table, you should see it here

-- Query the customer table (created by PySpark!)
-- Should see 5 products: Heater, Thermostat, Television, Blender, USB charger
SELECT * FROM ambari_glue_prod_LINKED_DB."prod"."customer";

-- Insert test (proves write access)
-- Note: This will fail if you haven't run PySpark demo first
INSERT INTO ambari_glue_prod_LINKED_DB."prod"."customer"
SELECT * FROM ambari_glue_prod_LINKED_DB."prod"."customer"
LIMIT 0;  -- Insert 0 rows (just testing permissions)

-- ========================================================================
-- STEP 6: CREATE EXTERNAL ICEBERG TABLE (Option 2)
-- ========================================================================
-- Alternative approach: Manually create Snowflake table pointing to Glue catalog
-- Use this if you want more control or linked database isn't working

-- Switch to your Iceberg database (create if needed)
USE DATABASE iceberg_db;
USE SCHEMA sales;

-- Create external Iceberg table referencing Glue catalog
-- This table reads the SAME data as PySpark
CREATE OR REPLACE ICEBERG TABLE my_iceberg_table
  EXTERNAL_VOLUME = 'glue_ext_volume'              -- S3 storage location
  CATALOG_NAMESPACE = 'prod'                       -- Glue database name
  CATALOG = 'ambari_prod_catalog_glue_int'         -- Glue catalog integration
  CATALOG_TABLE_NAME = 'customer'                  -- Table name in Glue
  AUTO_REFRESH = TRUE;                             -- Automatically detect changes

-- ========================================================================
-- VERIFICATION: Query via External Table
-- ========================================================================

-- Query the external table (same data as PySpark!)
SELECT * FROM my_iceberg_table;

-- Check table metadata
DESC TABLE my_iceberg_table;

-- Show table history (Iceberg snapshots)
SELECT * FROM my_iceberg_table.snapshots;

-- ========================================================================
-- TROUBLESHOOTING
-- ========================================================================

-- 1. Check External Volume
SHOW EXTERNAL VOLUMES;
DESC EXTERNAL VOLUME glue_ext_volume;

-- 2. Verify External Volume permissions
SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('glue_ext_volume');
-- Expected: All tests should PASS

-- 3. Check Catalog Integration
SHOW CATALOG INTEGRATIONS;
DESC CATALOG INTEGRATION ambari_prod_catalog_glue_int;

-- 4. Check Linked Database Status
SELECT SYSTEM$CATALOG_LINK_STATUS('ambari_glue_prod_LINKED_DB');

-- 5. List tables in Glue catalog
SHOW TABLES IN ambari_glue_prod_LINKED_DB."prod";

-- 6. Common Errors and Solutions:
--
-- Error: "Cannot access external volume"
-- Solution: Check IAM role trust relationship (Step 2)
--
-- Error: "Access denied to Glue catalog"
-- Solution: Check Lake Formation grants (Step 4)
--
-- Error: "Table not found"
-- Solution: Run PySpark demo first to create tables
--
-- Error: "Path mismatch"
-- Solution: Ensure External Volume STORAGE_BASE_URL matches PySpark warehouse

-- ========================================================================
-- CLEANUP (Optional - only if you want to remove everything)
-- ========================================================================

-- USE ROLE ACCOUNTADMIN;
-- DROP DATABASE IF EXISTS ambari_glue_prod_LINKED_DB CASCADE;
-- DROP TABLE IF EXISTS iceberg_db.sales.my_iceberg_table;
-- DROP CATALOG INTEGRATION IF EXISTS ambari_prod_catalog_glue_int;
-- DROP EXTERNAL VOLUME IF EXISTS glue_ext_volume;

-- ========================================================================
-- SUMMARY
-- ========================================================================
-- After running this script:
--
-- ✅ Snowflake can read Iceberg tables created by PySpark
-- ✅ Both engines share the same S3 data (federated lakehouse!)
-- ✅ Changes in PySpark are visible in Snowflake
-- ✅ Glue Catalog coordinates metadata between engines
--
-- Two ways to query:
-- 1. Linked Database: ambari_glue_prod_LINKED_DB."prod"."customer"
-- 2. External Table:  my_iceberg_table
--
-- Test Federation:
-- 1. Run PySpark: INSERT INTO glue.prod.customer ...
-- 2. Run Snowflake: SELECT * FROM my_iceberg_table
-- 3. See the same data! 🎉
-- ========================================================================
