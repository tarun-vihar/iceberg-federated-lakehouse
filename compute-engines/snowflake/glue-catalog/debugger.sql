SHOW ROLES;

SHOW EXTERNAL VOLUMES;

SHOW GRANTS TO USER TARUNVIHAR

SHOW GRANTS TO ROLE iceberg_role;



USE ROLE accountadmin;

-- Test External Volume
SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('glue_ext_volume');
-- Should return: {"status": "success"}

-- Test Catalog Link
SELECT SYSTEM$CATALOG_LINK_STATUS('ambari_prod_catalog_glue_int');
-- Should show: "executionState": "SUCCEEDED"

-- Try querying
USE ROLE iceberg_role;
SELECT * FROM ambari_glue_prod_LINKED_DB."prod"."customer";

SHOW SCHEMAS IN DATABASE ambari_glue_prod_LINKED_DB;


SHOW TABLES IN SCHEMA ambari_glue_prod_LINKED_DB."prod";


SELECT * FROM ambari_glue_prod_LINKED_DB."prod"."customer";


USE ROLE ACCOUNTADMIN;
DESC CATALOG tarun_polaris_catalog;


DESC CATALOG;


USE ROLE ACCOUNTADMIN;
DESC CATALOG tarun_polaris_catalog;