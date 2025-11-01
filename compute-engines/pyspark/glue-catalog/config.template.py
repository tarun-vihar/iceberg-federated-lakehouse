"""
Configuration Template for Iceberg + AWS Glue Demo

INSTRUCTIONS:
1. Copy this file to config.py: cp config.template.py config.py
2. Update the values below with your own settings
3. Never commit config.py to git (it's in .gitignore)
"""

# ============================================================================
# AWS Configuration - UPDATE THESE
# ============================================================================
AWS_PROFILE = "YOUR_AWS_PROFILE_NAME"  # e.g., "tarun_student"
AWS_REGION = "us-east-1"  # Your AWS region

# ============================================================================
# S3 Configuration - UPDATE THESE
# ============================================================================
S3_BUCKET_NAME = "your-bucket-name"  # e.g., "tarun-lakehouse-bucket"
S3_BUCKET_PREFIX = "catalogs/glue"  # Path prefix in bucket
S3_WAREHOUSE_PATH = f"s3://{S3_BUCKET_NAME}/{S3_BUCKET_PREFIX}"

# ============================================================================
# Glue Catalog Configuration
# ============================================================================
CATALOG_NAME = "glue"
DATABASE_NAME = "prod"  # Change if you want a different database name
TABLE_NAME = "customer"  # Default table name

# Full table reference
FULL_TABLE_NAME = f"{CATALOG_NAME}.{DATABASE_NAME}.{TABLE_NAME}"

# ============================================================================
# Spark Configuration
# ============================================================================
SPARK_APP_NAME = "Iceberg-Glue-Demo"

# JAR files location - update if your JARs are in a different location
JARS_DIR = "~/iceberg/jars"

# Required JAR files - update versions if needed
JAR_FILES = [
    "bundle-2.31.63.jar",
    "url-connection-client-2.31.63.jar",
    "glue-2.31.63.jar",
    "iceberg-aws-1.10.0.jar",
    "iceberg-spark-runtime-4.0_2.13-1.10.0.jar"
]

# ============================================================================
# Iceberg Configuration
# ============================================================================
ICEBERG_FORMAT_VERSION = "2"
ICEBERG_TABLE_TYPE = "ICEBERG"
ENABLE_VECTORIZATION = "false"

# ============================================================================
# Table Locations (S3 paths)
# ============================================================================
def get_table_location(table_name):
    """Generate S3 location for a table"""
    return f"{S3_WAREHOUSE_PATH}/{table_name}/"

# Default table location
TABLE_LOCATION = get_table_location(TABLE_NAME)

# ============================================================================
# Spark Catalog Configuration
# ============================================================================
SPARK_CATALOG_CONFIG = {
    "spark.sql.defaultCatalog": CATALOG_NAME,
    "spark.sql.catalog.glue": "org.apache.iceberg.spark.SparkCatalog",
    "spark.sql.catalog.glue.type": "glue",
    "spark.sql.catalog.glue.warehouse": S3_WAREHOUSE_PATH,
    "spark.sql.catalog.glue.io-impl": "org.apache.iceberg.aws.s3.S3FileIO",
    "spark.sql.catalog.glue.client.region": AWS_REGION,
}

# ============================================================================
# Helper Functions
# ============================================================================
def print_config():
    """Print current configuration"""
    print("="*70)
    print("ICEBERG + GLUE CONFIGURATION")
    print("="*70)
    print(f"AWS Profile:        {AWS_PROFILE}")
    print(f"AWS Region:         {AWS_REGION}")
    print(f"S3 Bucket:          {S3_BUCKET_NAME}")
    print(f"S3 Prefix:          {S3_BUCKET_PREFIX}")
    print(f"Warehouse Path:     {S3_WAREHOUSE_PATH}")
    print(f"Catalog:            {CATALOG_NAME}")
    print(f"Database:           {DATABASE_NAME}")
    print(f"Table:              {TABLE_NAME}")
    print(f"Full Table Name:    {FULL_TABLE_NAME}")
    print(f"Table Location:     {TABLE_LOCATION}")
    print(f"JARs Directory:     {JARS_DIR}")
    print("="*70)

def get_spark_config():
    """Get complete Spark configuration as dictionary"""
    import os

    jars_dir_expanded = os.path.expanduser(JARS_DIR)
    jar_paths = [f"{jars_dir_expanded}/{jar}" for jar in JAR_FILES]

    config = {
        "spark.app.name": SPARK_APP_NAME,
        "spark.jars": ",".join(jar_paths),
        "spark.driver.extraClassPath": ":".join(jar_paths),
        "spark.executor.extraClassPath": ":".join(jar_paths),
        "spark.sql.extensions": "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions",
        "spark.sql.iceberg.vectorization.enabled": ENABLE_VECTORIZATION,
    }

    # Add catalog configuration
    config.update(SPARK_CATALOG_CONFIG)

    return config

def validate_setup():
    """Validate that all required components are in place"""
    import os
    import boto3

    print("Validating setup...")

    # Check JAR files
    jars_dir_expanded = os.path.expanduser(JARS_DIR)
    missing_jars = []
    for jar in JAR_FILES:
        jar_path = f"{jars_dir_expanded}/{jar}"
        if not os.path.exists(jar_path):
            missing_jars.append(jar)

    if missing_jars:
        print(f"❌ Missing JAR files: {missing_jars}")
    else:
        print(f"✅ All JAR files found in {JARS_DIR}")

    # Check AWS credentials
    try:
        os.environ['AWS_PROFILE'] = AWS_PROFILE
        session = boto3.Session(profile_name=AWS_PROFILE)
        sts = session.client('sts')
        identity = sts.get_caller_identity()
        print(f"✅ AWS credentials valid for account: {identity['Account']}")
    except Exception as e:
        print(f"❌ AWS credentials error: {e}")

    # Check S3 bucket
    try:
        s3 = session.client('s3')
        s3.head_bucket(Bucket=S3_BUCKET_NAME)
        print(f"✅ S3 bucket '{S3_BUCKET_NAME}' is accessible")
    except Exception as e:
        print(f"❌ S3 bucket error: {e}")

    print("\nSetup validation complete!")

if __name__ == "__main__":
    print_config()
    print("\n")
    validate_setup()
