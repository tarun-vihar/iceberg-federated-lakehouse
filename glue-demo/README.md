# AWS Glue + Apache Iceberg Demo

This project demonstrates how to use Apache Iceberg tables with AWS Glue Data Catalog.

## Prerequisites

- Python 3.x with PySpark 4.0.1
- AWS credentials configured (`tarun_student` profile)
- Iceberg JAR files in `~/iceberg/jars/`
- Access to AWS Glue and S3

## Setup

### 1. AWS Configuration

**Profile:** `tarun_student` in `~/.aws/credentials`

```ini
[tarun_student]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

**Region:** us-east-1

### 2. S3 Bucket Structure

**Bucket:** `tarun-lakehouse-bucket`

```
tarun-lakehouse-bucket/
└── catalogs/
    ├── glue/          # Iceberg tables for Glue catalog
    ├── polaris/       # Iceberg tables for Polaris catalog
    └── external_data/ # Other data
```

### 3. Required Python Packages

```bash
pip3 install findspark sparksql-magic boto3
```

### 4. Iceberg JAR Files

Located in `~/iceberg/jars/`:
- `bundle-2.31.63.jar` (AWS SDK)
- `url-connection-client-2.31.63.jar`
- `glue-2.31.63.jar`
- `iceberg-aws-1.10.0.jar`
- `iceberg-spark-runtime-4.0_2.13-1.10.0.jar`

## Running the Notebook

1. Open `glue_iceberg_demo.ipynb` in Jupyter/VS Code
2. Run cells in order:
   - Cell 0: Load sparksql_magic extension
   - Cell 1: Import libraries and initialize findspark
   - Cell 2: Set AWS credentials
   - Cell 5: Create Spark session with Iceberg + Glue
   - Cell 7-9: Create sample data
   - Cell 10: Create Glue database
   - Cell 12: Create Iceberg table
   - Continue with remaining cells for demo operations

## Features Demonstrated

### Basic Operations
- ✅ Create Glue database
- ✅ Create Iceberg tables in Glue catalog
- ✅ Insert data
- ✅ Query data

### Advanced Iceberg Features
- ✅ Time travel queries (query historical data)
- ✅ Table snapshots and history
- ✅ DELETE operations
- ✅ MERGE operations (upsert)
- ✅ Schema evolution

### AWS Integration
- ✅ AWS Glue Data Catalog integration
- ✅ S3 as Iceberg storage layer
- ✅ IAM authentication

## Project Structure

```
glue-demo/
├── README.md                    # This file
└── glue_iceberg_demo.ipynb     # Main notebook
```

## Configuration

**Glue Catalog:**
- Catalog name: `glue`
- Database: `prod`
- Warehouse location: `s3://tarun-lakehouse-bucket/catalogs/glue`

**Spark Configuration:**
- Default catalog: Glue
- Iceberg format version: 2
- Region: us-east-1

## Example Queries

### Create Table
```sql
CREATE TABLE glue.prod.customer (
    id string,
    name string,
    price decimal(10,2)
)
USING iceberg
LOCATION 's3://tarun-lakehouse-bucket/catalogs/glue/customer/'
```

### Time Travel
```sql
SELECT * FROM glue.prod.customer
TIMESTAMP AS OF '2025-10-18 10:00:00'
```

### View History
```sql
SELECT * FROM glue.prod.customer.history
```

### MERGE (Upsert)
```sql
MERGE INTO glue.prod.customer AS t
USING updates AS u
ON t.id = u.id
WHEN MATCHED THEN UPDATE SET t.price = u.price
WHEN NOT MATCHED THEN INSERT *
```

## Troubleshooting

### ClassNotFoundException for Iceberg
- Ensure all JAR files are in `~/iceberg/jars/`
- Check that JARs are added to both driver and executor classpath

### AWS Credentials Error
- Verify `tarun_student` profile exists in `~/.aws/credentials`
- Check IAM permissions for Glue and S3

### S3 Access Denied
- Verify bucket name is correct
- Check IAM user has S3 read/write permissions

## Resources

- [Apache Iceberg Documentation](https://iceberg.apache.org/)
- [AWS Glue Documentation](https://docs.aws.amazon.com/glue/)
- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)

## Notes

- The notebook uses local JAR files instead of Maven packages for better control
- Iceberg format version 2 is used for advanced features like row-level deletes
- All table data and metadata is stored in S3
- Glue Data Catalog stores only table metadata references
