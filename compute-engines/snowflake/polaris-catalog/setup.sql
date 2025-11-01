-- ========================================================================
-- Snowflake External Volume Setup for Iceberg Tables
-- ========================================================================
-- Purpose: Configure Snowflake to read/write Iceberg tables in AWS S3
-- S3 Location: s3://tarun-lakehouse-bucket/catalogs/external_snowflake/
-- ========================================================================

-- Step 1: Use ACCOUNTADMIN role for setup
-- ACCOUNTADMIN has all necessary privileges to create objects and grant permissions
USE ROLE ACCOUNTADMIN;

-- Step 2: Create compute warehouse for Iceberg workloads
-- XSMALL is default size, suitable for development/testing
-- Troubleshooting: If this fails, warehouse may already exist. Use CREATE OR REPLACE instead.
CREATE WAREHOUSE iceberg_vw;

-- Step 3: Create dedicated role for Iceberg operations
-- Following principle of least privilege - separate role for Iceberg work
-- Troubleshooting: If role exists, use CREATE OR REPLACE or DROP ROLE first
CREATE ROLE iceberg_role;

-- Step 4: Create database for Iceberg tables
-- This will contain all Iceberg-related schemas and tables
CREATE DATABASE iceberg_db;

-- Step 5: Create schema within the database
-- Using 'sales' as the business domain schema
CREATE SCHEMA iceberg_db.sales;

-- Step 6: Grant database permissions to iceberg_role
-- WITH GRANT OPTION allows iceberg_role to grant these permissions to other roles
-- Permissions include: CREATE, MODIFY, MONITOR, USAGE on database
GRANT ALL ON DATABASE iceberg_db TO ROLE iceberg_role WITH GRANT OPTION;

-- Step 7: Grant schema permissions to iceberg_role
-- Allows iceberg_role to create tables, views, and other objects in the schema
GRANT ALL ON SCHEMA iceberg_db.sales TO ROLE iceberg_role WITH GRANT OPTION;

-- Step 8: Grant warehouse permissions to iceberg_role
-- Allows iceberg_role to use the warehouse for compute operations
-- Troubleshooting: Without this, queries will fail with "No active warehouse selected"
GRANT ALL ON WAREHOUSE iceberg_vw TO ROLE iceberg_role WITH GRANT OPTION;

-- Step 9: Ensure we're using ACCOUNTADMIN (redundant but safe)
USE ROLE accountadmin;

-- Step 10: Create External Volume pointing to S3
-- External volume connects Snowflake to external storage (S3) for Iceberg tables
-- IMPORTANT: Before running this, ensure AWS IAM role 'ambari_polaris' exists
CREATE OR REPLACE EXTERNAL VOLUME ambari_ext_vol
STORAGE_LOCATIONS = (
  ( 
    NAME = 'snowflake-ext-volume'                                              -- Friendly name for this storage location
    STORAGE_PROVIDER = 'S3'                                                    -- Cloud provider (S3, Azure, GCS)
    STORAGE_BASE_URL = 's3://tarun-lakehouse-bucket/catalogs/external_snowflake/'  -- S3 path where Iceberg tables will be stored
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::047825088072:role/ambari_polaris'   -- IAM role that Snowflake assumes to access S3
  )
);
-- Troubleshooting: If this succeeds but verification fails later:
-- 1. Check IAM role trust relationship includes Snowflake IAM user (get from DESC below)
-- 2. Verify IAM policy has s3:PutObject, s3:GetObject, s3:DeleteObject, s3:ListBucket
-- 3. Ensure S3 bucket exists and IAM role has access to the specific path

-- Step 11: Grant external volume access to iceberg_role
-- Without this, iceberg_role cannot create tables using this external volume
GRANT ALL ON EXTERNAL VOLUME ambari_ext_vol TO ROLE iceberg_role WITH GRANT OPTION;

-- Step 12: Describe external volume to get Snowflake IAM details
-- CRITICAL: Copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID from output
-- These values must be added to the AWS IAM role trust relationship
DESC EXTERNAL VOLUME ambari_ext_vol;
-- Expected output columns: property, property_value, property_default, property_description
-- Look for: STORAGE_AWS_IAM_USER_ARN
--          STORAGE_AWS_EXTERNAL_ID 

-- Step 13: Verify external volume configuration
-- This tests read, write, list, and delete operations on S3
SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('ambari_ext_vol');
-- Expected success output: {"success":true,"writeResult":"PASSED","readResult":"PASSED","listResult":"PASSED","deleteResult":"PASSED"}
-- 
-- Troubleshooting common failures:
-- - writeResult FAILED: IAM policy missing s3:PutObject permission
-- - readResult FAILED: IAM policy missing s3:GetObject permission  
-- - listResult FAILED: IAM policy missing s3:ListBucket or Condition block is too restrictive
-- - deleteResult FAILED: IAM policy missing s3:DeleteObject permission
-- - awsRoleArnValidationResult FAILED: IAM trust relationship not configured with Snowflake IAM user
--
-- Required IAM Policy for ambari_polaris role:
-- {
--   "Version": "2012-10-17",
--   "Statement": [
--     {
--       "Effect": "Allow",
--       "Action": ["s3:PutObject", "s3:GetObject", "s3:GetObjectVersion", "s3:DeleteObject", "s3:DeleteObjectVersion"],
--       "Resource": "arn:aws:s3:::tarun-lakehouse-bucket/catalogs/external_snowflake/*"
--     },
--     {
--       "Effect": "Allow",
--       "Action": "s3:ListBucket",
--       "Resource": "arn:aws:s3:::tarun-lakehouse-bucket",
--       "Condition": {
--         "StringLike": {
--           "s3:prefix": ["catalogs/external_snowflake/*"]
--         }
--       }
--     },
--     {
--       "Effect": "Allow",
--       "Action": "s3:GetBucketLocation",
--       "Resource": "arn:aws:s3:::tarun-lakehouse-bucket"
--     }
--   ]
-- }

-- Step 14: Grant iceberg_role to specific user
-- This allows user TARUNVIHAR to use the iceberg_role
-- Troubleshooting: If you get "role not assigned" error when using iceberg_role, this step was skipped
GRANT ROLE iceberg_role TO USER TARUNVIHAR;

-- ========================================================================
-- CREATE EXTERNAL SNOWFLAKE ICEBERG TABLES
-- ========================================================================

-- Step 15: Switch to iceberg_role for table creation
-- Using iceberg_role instead of ACCOUNTADMIN follows security best practices
USE ROLE iceberg_role;

-- Step 16: Set database context
USE DATABASE iceberg_db;

-- Step 17: Set schema context
USE SCHEMA sales;

-- Step 18: Create Iceberg table with Snowflake-managed catalog
-- This creates a new Iceberg table that stores data in S3
CREATE OR REPLACE ICEBERG TABLE ice3(
  c_custkey INTEGER,        -- Customer ID (primary identifier)
  c_name STRING,            -- Customer name
  c_address STRING,         -- Customer address
  c_nationkey INTEGER,      -- Nation/country ID (foreign key reference)
  c_phone STRING,           -- Phone number
  c_acctbal INTEGER,        -- Account balance
  c_mktsegment STRING,      -- Market segment (BUILDING, AUTOMOBILE, etc.)
  c_comment STRING          -- Additional comments
)
CATALOG='SNOWFLAKE'                           -- Use Snowflake-managed catalog (not external Glue/Polaris)
EXTERNAL_VOLUME='ambari_ext_vol'              -- Reference to the external volume created earlier
BASE_LOCATION='ice3';                         -- Subfolder within external volume (full path: s3://tarun-lakehouse-bucket/catalogs/external_snowflake/ice3/)

-- Troubleshooting:
-- - "External volume not found": Grant missing (see Step 11)
-- - "Insufficient privileges": Role doesn't have permissions on schema/database
-- - "Invalid CATALOG": Use 'SNOWFLAKE', 'GLUE', or catalog integration name
--
-- What happens in S3:
-- Creates folders: s3://tarun-lakehouse-bucket/catalogs/external_snowflake/ice3/
--                  - metadata/ (Iceberg metadata files: *.metadata.json, snap-*.avro)
--                  - data/ (Parquet data files)

-- Step 19: Insert sample data into the Iceberg table
-- Data is written to S3 in Parquet format with Iceberg metadata
INSERT INTO ice3 VALUES
  (1, 'Tarun', '123 Main St', 1, '555-0001', 1000, 'BUILDING', 'Good customer'),
  (2, 'Krishna', '456 Oak Ave', 2, '555-0002', 2000, 'AUTOMOBILE', 'Great customer'),
  (3, 'Aravind', '789 Pine Rd', 3, '555-0003', 1500, 'MACHINERY', 'Regular customer');

-- Troubleshooting:
-- - Insert fails with "No active warehouse": Run USE WAREHOUSE iceberg_vw;
-- - Slow performance: Warehouse may be suspended, increase size or check AUTO_RESUME
-- - S3 write failures: Check IAM permissions and VERIFY_EXTERNAL_VOLUME results
--
-- Verify data:
-- SELECT * FROM ice3;
-- SELECT COUNT(*) FROM ice3;  -- Should return 3
--
-- Check S3 files created (in AWS Console):
-- tarun-lakehouse-bucket/catalogs/external_snowflake/ice3/
-- ├── metadata/
-- │   ├── v1.metadata.json  (Iceberg table metadata - schema, partitions, snapshots)
-- │   └── snap-*.avro       (Snapshot manifest files)
-- └── data/
--     └── *.parquet         (Actual customer data in columnar format)

-- ========================================================================
-- POST-SETUP VERIFICATION QUERIES
-- ========================================================================

-- Uncomment and run these queries to verify setup:

-- Check table details:
-- DESCRIBE TABLE ice3;

-- View all Iceberg tables in schema:
-- SHOW ICEBERG TABLES IN SCHEMA iceberg_db.sales;

-- Check table metadata:
-- SELECT table_catalog, table_schema, table_name, table_type 
-- FROM information_schema.tables 
-- WHERE table_name = 'ICE3';

-- Verify role permissions:
-- SHOW GRANTS TO ROLE iceberg_role;

-- Check what roles current user has:
-- SHOW GRANTS TO USER CURRENT_USER();

-- ========================================================================
-- CLEANUP (Optional - only if you want to remove everything)
-- ========================================================================

-- USE ROLE ACCOUNTADMIN;
-- DROP TABLE IF EXISTS iceberg_db.sales.ice3;
-- DROP SCHEMA IF EXISTS iceberg_db.sales CASCADE;
-- DROP DATABASE IF EXISTS iceberg_db CASCADE;
-- DROP EXTERNAL VOLUME IF EXISTS ambari_ext_vol;
-- DROP WAREHOUSE IF EXISTS iceberg_vw;
-- REVOKE ROLE iceberg_role FROM USER TARUNVIHAR;
-- DROP ROLE IF EXISTS iceberg_role;

-- Note: Dropping external volume does NOT delete S3 files
-- Delete S3 files manually if needed: aws s3 rm s3://tarun-lakehouse-bucket/catalogs/external_snowflake/ --recursive