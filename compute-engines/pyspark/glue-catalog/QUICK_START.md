# Quick Start Guide

## Your Working Configuration

### AWS Setup
- **Profile:** `tarun_student`
- **Region:** `us-east-1`
- **Bucket:** `tarun-lakehouse-bucket`
- **Warehouse Path:** `s3://tarun-lakehouse-bucket/catalogs/glue`

### Installed Dependencies
✅ Python packages:
- `findspark`
- `sparksql-magic`
- `boto3`
- `pyspark 4.0.1`

✅ JAR files in `~/iceberg/jars/`:
- bundle-2.31.63.jar (633 MB)
- url-connection-client-2.31.63.jar (32 KB)
- glue-2.31.63.jar (8.4 MB)
- iceberg-aws-1.10.0.jar (217 KB)
- iceberg-spark-runtime-4.0_2.13-1.10.0.jar (45 MB)

## Running the Demo

### Step 1: Open the Notebook
```bash
cd ~/iceberg-projects/glue-demo
jupyter notebook glue_iceberg_demo.ipynb
# OR open in VS Code
```

### Step 2: Run Cells in Order
1. **Cell 0** - Load extensions
2. **Cell 1** - Imports
3. **Cell 2** - AWS credentials
4. **Cell 5** - Create Spark session ⭐
5. **Cell 7-9** - Create sample data
6. **Cell 10** - Create database
7. **Cell 11** - Drop existing table
8. **Cell 12** - Create Iceberg table ⭐
9. **Cell 15** - Insert data
10. Continue with remaining cells...

### Step 3: Verify in AWS Console
- **Glue Console:** Check database `prod` and table `customer`
- **S3 Console:** Check `s3://tarun-lakehouse-bucket/catalogs/glue/`

## Key Cells

### Cell 5: Spark Session
Creates Spark with Iceberg + Glue integration
```python
spark = SparkSession.builder
  .config("spark.sql.catalog.glue.warehouse","s3://tarun-lakehouse-bucket/catalogs/glue")
  .config("spark.sql.catalog.glue.client.region","us-east-1")
  ...
```

### Cell 12: Create Table
Creates Iceberg table in Glue catalog
```sql
CREATE TABLE glue.prod.customer (...)
USING iceberg
LOCATION 's3://tarun-lakehouse-bucket/catalogs/glue/customer/'
```

## Common Commands

### Test AWS Connection
```python
import boto3
import os
os.environ['AWS_PROFILE'] = 'tarun_student'

# Test Glue
glue = boto3.client('glue', region_name='us-east-1')
print(glue.get_databases())

# Test S3
s3 = boto3.client('s3')
print(s3.list_buckets())
```

### Check Table in Glue
```python
spark.sql("SHOW DATABASES").show()
spark.sql("SHOW TABLES IN glue.prod").show()
spark.sql("DESC EXTENDED glue.prod.customer").show(truncate=False)
```

### View Table History
```python
spark.sql("SELECT * FROM glue.prod.customer.history").show()
spark.sql("SELECT * FROM glue.prod.customer.snapshots").show()
```

## Troubleshooting

### Issue: ClassNotFoundException
**Solution:** Restart kernel and re-run Cell 5

### Issue: AWS Credentials Error
**Solution:** Check `~/.aws/credentials` has `[tarun_student]` section

### Issue: S3 Access Denied
**Solution:** Verify IAM permissions for S3 and Glue

### Issue: Table Creation Fails
**Solution:**
1. Check Cell 10 ran successfully (database created)
2. Verify S3 bucket path is correct
3. Check AWS region matches

## What You Built

✅ **Working Iceberg + Glue Setup**
- Spark 4.0 with Iceberg 1.10.0
- AWS Glue Data Catalog integration
- S3 as storage layer

✅ **Demonstrated Features**
- Table creation and management
- CRUD operations (Create, Read, Update, Delete)
- Time travel queries
- Table snapshots and history
- MERGE operations (upsert)

## Next Steps

1. **Experiment** with different table schemas
2. **Try partitioning** for larger datasets
3. **Explore schema evolution** (add/remove columns)
4. **Set up automation** with AWS Glue Jobs
5. **Integrate with BI tools** like Athena or Tableau

## Important Files

- `glue_iceberg_demo.ipynb` - Main notebook
- `~/iceberg/jars/` - Required JAR files
- `~/.aws/credentials` - AWS credentials
- `s3://tarun-lakehouse-bucket/catalogs/glue/` - Table storage

## Success! 🎉

You now have a fully working Iceberg + Glue environment for lakehouse data management!
