====================================
--Create external volume
--1_external_volume
--ambari_ext_volume


USE ROLE accountadmin;

-- Drop old external volume
DROP EXTERNAL VOLUME IF EXISTS glue_ext_volume;




-- Create with correct bucket
CREATE EXTERNAL VOLUME glue_ext_volume 
STORAGE_LOCATIONS = ( 
  ( NAME = 'glue_ext_volume'
    STORAGE_PROVIDER = 'S3'
    STORAGE_BASE_URL = 's3://tarun-lakehouse-bucket/catalogs/glue/'
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::047825088072:role/ambari_snow_glue_linked'
  ) 
);

-- Get IAM user info to update trust relationship
DESC EXTERNAL VOLUME glue_ext_volume;


====================================
====================================
--create ambari_snow_glue_linked role
====================================


====================================
--create glue catalog integration
====================================


drop CATALOG INTEGRATION if exists ambari_prod_catalog_glue_int;


CREATE OR REPLACE CATALOG INTEGRATION ambari_prod_catalog_glue_int
  CATALOG_SOURCE = ICEBERG_REST
  TABLE_FORMAT = ICEBERG
  CATALOG_NAMESPACE = 'prod'
  REST_CONFIG = (
    CATALOG_URI = 'https://glue.us-east-1.amazonaws.com/iceberg',
    CATALOG_API_TYPE = AWS_GLUE,
    CATALOG_NAME = '047825088072'
  )
  REST_AUTHENTICATION = (
    TYPE = SIGV4,
    SIGV4_IAM_ROLE = 'arn:aws:iam::047825088072:role/ambari_snow_glue_linked',
    SIGV4_SIGNING_REGION = 'us-east-1'
  )
  ENABLED = TRUE,
  REFRESH_INTERVAL_SECONDS = 180;



  ====================================
--update role trust 
====================================  
DESCRIBE CATALOG INTEGRATION ambari_prod_catalog_glue_int;


GRANT ALL ON  INTEGRATION ambari_prod_catalog_glue_int TO ROLE iceberg_role WITH GRANT OPTION;


=============================================
--Lakeformation Permission. 
=============================================

# Grant ALL permissions on the database
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Database": { "Name": "prod" } }' \
  --permissions "ALL"

# Grant ALL permissions on all tables in the database
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Table": { "DatabaseName": "prod", "TableWildcard": {} } }' \
  --permissions "ALL"

  
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Database": { "Name": "prod" } }' \
  --permissions "CREATE_TABLE" "ALTER" "DROP" "DESCRIBE"


aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Table": { "DatabaseName": "prod", "Name": "customer" } }' \
  --permissions "ALTER" "DESCRIBE" "SELECT" "INSERT" "DELETE" "DROP"

aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Table": { "DatabaseName": "prod", "Name": "customer4" } }' \
  --permissions "ALTER" "DESCRIBE" "SELECT" "INSERT" "DELETE" "DROP"

aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "DataLocation": { "ResourceArn": "arn:aws:s3:::tarun-lakehouse-bucket/prod/" } }' \
  --permissions "DATA_LOCATION_ACCESS"



drop database if exists ambari_glue_prod_LINKED_DB;

CREATE DATABASE ambari_glue_prod_LINKED_DB
  LINKED_CATALOG = (
    CATALOG = 'ambari_prod_catalog_glue_int'
  ),
  EXTERNAL_VOLUME = 'glue_ext_volume';


  SELECT SYSTEM$CATALOG_LINK_STATUS('ambari_glue_prod_LINKED_DB');



{"failureDetails":[{"qualifiedEntityName":"prod.customer","entityDomain":"TABLE","operation":"CREATE","errorCode":"094120","errorMessage":"\"One of the specified Iceberg metadata files does not conform to the required directory hierarchy. All files must reside as a strict subpath under the defined base directory. Current base directory: s3://tarun-lakehouse-bucket/external_volumes/glue/. Conflicting file path: s3://tarun-lakehouse-bucket/catalogs/glue/customer/metadata/00003-f54c185e-7d9d-4d78-94e4-5eb6d53899ab.metadata.json.\\n\""}],"executionState":"RUNNING","lastLinkAttemptStartTime":"2025-10-22T00:05:27.818Z"}


GRANT ALL ON DATABASE ambari_glue_prod_LINKED_DB TO ROLE iceberg_role;
GRANT ALL ON schema ambari_glue_prod_LINKED_DB."prod" TO ROLE iceberg_role;


insert into ambari_glue_prod_LINKED_DB."prod"."customer" select * from ambari_glue_prod_LINKED_DB."prod"."customer";

=============================================
--Create an Iceberg table in a standard Snowflake database
--https://docs.snowflake.com/en/user-guide/tables-iceberg-externally-managed-writes#label-tables-iceberg-externally-managed-writes-create-schema
=============================================

use database iceberg_db;
use schema sales;
CREATE OR REPLACE ICEBERG TABLE my_iceberg_table
  EXTERNAL_VOLUME = 'glue_ext_volume'
  CATALOG_NAMESPACE = 'prod'
  CATALOG = 'ambari_prod_catalog_glue_int'
  CATALOG_TABLE_NAME = 'customer'
  AUTO_REFRESH = TRUE;

select * from my_iceberg_table;