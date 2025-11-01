# Snowflake + AWS Glue Catalog Integration

This directory contains Snowflake SQL scripts to integrate Snowflake with AWS Glue Catalog for reading/writing Iceberg tables.

## 🎯 What This Does

Allows Snowflake to:
- ✅ Read Iceberg tables created by PySpark (via Glue Catalog)
- ✅ Write to the same Iceberg tables
- ✅ Access tables through Glue Catalog Integration
- ✅ Query the **same data** that PySpark uses

## 📊 Shared Configuration

This setup accesses the **SAME S3 tables** as the PySpark Glue demo:

| Component | Value | Shared with PySpark? |
|-----------|-------|---------------------|
| **S3 Bucket** | `tarun-lakehouse-bucket` | ✅ Yes |
| **S3 Path** | `s3://tarun-lakehouse-bucket/catalogs/glue/` | ✅ Yes |
| **Glue Database** | `prod` | ✅ Yes |
| **Table Name** | `customer` | ✅ Yes |
| **AWS Account** | `047825088072` | ✅ Yes |
| **Region** | `us-east-1` | ✅ Yes |

## 🔄 Integration Approaches

This demo shows **TWO** ways to access Glue catalog from Snowflake:

### 1. Catalog Integration (Linked Database)
Creates a Snowflake database linked to the Glue catalog:
```sql
CREATE DATABASE ambari_glue_prod_LINKED_DB
  LINKED_CATALOG = (
    CATALOG = 'ambari_prod_catalog_glue_int'
  ),
  EXTERNAL_VOLUME = 'glue_ext_volume';
```

**Pros:**
- Automatic table discovery
- Real-time catalog sync
- No manual table creation

**Cons:**
- More complex IAM/Lake Formation setup
- Requires catalog integration configuration

### 2. External Iceberg Table
Manually create Snowflake table pointing to Glue catalog:
```sql
CREATE ICEBERG TABLE my_iceberg_table
  EXTERNAL_VOLUME = 'glue_ext_volume'
  CATALOG_NAMESPACE = 'prod'
  CATALOG = 'ambari_prod_catalog_glue_int'
  CATALOG_TABLE_NAME = 'customer'
  AUTO_REFRESH = TRUE;
```

**Pros:**
- Simpler setup
- More control
- Easier troubleshooting

**Cons:**
- Manual table creation needed
- No automatic discovery

## 📁 Files

- **[setup.sql](setup.sql)** - Complete setup script with detailed comments
- **[debugger.sql](debugger.sql)** - Troubleshooting queries

## 🚀 Quick Start

### Prerequisites

1. **AWS Setup:**
   - S3 bucket: `tarun-lakehouse-bucket`
   - IAM role: `ambari_snow_glue_linked`
   - Glue database: `prod`
   - Iceberg tables created (run PySpark demo first)

2. **Snowflake Setup:**
   - Account with ACCOUNTADMIN access
   - User: `TARUNVIHAR`
   - Role: `iceberg_role` (created by script)

### Steps

1. **Run PySpark Glue Demo First**
   ```bash
   cd ../pyspark/glue-catalog/
   jupyter notebook glue_iceberg_demo.ipynb
   # This creates the Iceberg tables in S3
   ```

2. **Configure AWS IAM**
   - Create IAM role: `ambari_snow_glue_linked`
   - Attach S3 access policy
   - Add Glue permissions
   - Add Lake Formation grants (see setup.sql)

3. **Run Snowflake Setup**
   ```sql
   -- In Snowflake worksheet:
   -- Open setup.sql and run sections in order
   ```

4. **Verify Access**
   ```sql
   -- Query the same table PySpark created
   SELECT * FROM my_iceberg_table;

   -- Or via linked database
   SELECT * FROM ambari_glue_prod_LINKED_DB."prod"."customer";
   ```

## 🔧 Configuration Details

### External Volume
```sql
CREATE EXTERNAL VOLUME glue_ext_volume
STORAGE_LOCATIONS = (
  ( NAME = 'glue_ext_volume'
    STORAGE_PROVIDER = 'S3'
    STORAGE_BASE_URL = 's3://tarun-lakehouse-bucket/catalogs/glue/'
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::047825088072:role/ambari_snow_glue_linked'
  )
);
```

### Catalog Integration
```sql
CREATE CATALOG INTEGRATION ambari_prod_catalog_glue_int
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
  );
```

## 🔍 Verification

Check if Snowflake can access the PySpark-created table:

```sql
-- Check catalog link status
SELECT SYSTEM$CATALOG_LINK_STATUS('ambari_glue_prod_LINKED_DB');

-- Query table metadata
DESC TABLE my_iceberg_table;

-- Query actual data (created by PySpark)
SELECT * FROM my_iceberg_table;

-- Should see the same 5 products PySpark inserted
```

## ⚠️ Known Issues

### Path Mismatch Error
If you see:
```
Conflicting file path: s3://tarun-lakehouse-bucket/catalogs/glue/customer/metadata/...
```

**Solution:** Ensure External Volume `STORAGE_BASE_URL` matches PySpark warehouse path:
- PySpark: `s3://tarun-lakehouse-bucket/catalogs/glue`
- Snowflake External Volume: `s3://tarun-lakehouse-bucket/catalogs/glue/`

### Lake Formation Permissions
Common error: "Access denied"

**Solution:** Grant Lake Formation permissions (see setup.sql):
```bash
aws lakeformation grant-permissions \
  --principal DataLakePrincipalIdentifier=arn:aws:iam::047825088072:role/ambari_snow_glue_linked \
  --resource '{ "Database": { "Name": "prod" } }' \
  --permissions "ALL"
```

## 📚 Related Documentation

- [Snowflake Iceberg Catalog Integrations](https://docs.snowflake.com/en/user-guide/tables-iceberg-configure-catalog-integration)
- [AWS Glue Catalog](https://docs.aws.amazon.com/glue/)
- [PySpark Glue Demo](../../pyspark/glue-catalog/README.md) - Create tables first

## 🎓 Learning Notes

**Key Insights:**
- Snowflake and PySpark can share the same Iceberg tables
- Glue Catalog acts as the metadata coordinator
- Both engines read/write the same S3 Parquet files
- This is true **federated lakehouse** architecture!

**Architecture:**
```
PySpark ──┐
          ├──> Glue Catalog ──> S3 Iceberg Tables
Snowflake ┘
```

Both engines see the same data, schemas, and snapshots!
