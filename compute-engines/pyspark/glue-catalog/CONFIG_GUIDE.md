# Configuration Guide

## Overview

This project uses a centralized configuration file (`config.py`) to manage all settings. This makes it easy to:
- ✅ Update settings in one place
- ✅ Switch between different environments (dev, staging, prod)
- ✅ Share code without exposing credentials
- ✅ Maintain consistency across the notebook

## Configuration File Structure

### Main Configuration File: `config.py`

**⚠️ IMPORTANT:** `config.py` contains your personal settings and is excluded from git via `.gitignore`

### Template File: `config.template.py`

This is a template with placeholder values that can be committed to git and shared with others.

## Setup Instructions

### First Time Setup

1. **Copy the template to create your config file:**
   ```bash
   cd ~/iceberg-projects/glue-demo
   cp config.template.py config.py
   ```

2. **Edit config.py with your settings:**
   ```bash
   # Use your favorite editor
   nano config.py
   # OR
   code config.py
   ```

3. **Update these key values:**
   ```python
   AWS_PROFILE = "tarun_student"  # Your AWS profile name
   AWS_REGION = "us-east-1"       # Your AWS region
   S3_BUCKET_NAME = "tarun-lakehouse-bucket"  # Your S3 bucket
   ```

## Configuration Variables

### AWS Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_PROFILE` | AWS credentials profile name | `"tarun_student"` |
| `AWS_REGION` | AWS region for resources | `"us-east-1"` |

### S3 Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `S3_BUCKET_NAME` | S3 bucket name | `"tarun-lakehouse-bucket"` |
| `S3_BUCKET_PREFIX` | Path prefix in bucket | `"catalogs/glue"` |
| `S3_WAREHOUSE_PATH` | Full warehouse path | Auto-generated from above |

### Catalog Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `CATALOG_NAME` | Glue catalog name | `"glue"` |
| `DATABASE_NAME` | Database name | `"prod"` |
| `TABLE_NAME` | Default table name | `"customer"` |
| `FULL_TABLE_NAME` | Full table reference | Auto-generated |

### Spark Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `SPARK_APP_NAME` | Spark application name | `"Iceberg-Glue-Demo"` |
| `JARS_DIR` | JAR files directory | `"~/iceberg/jars"` |
| `JAR_FILES` | List of required JARs | Array of JAR filenames |

### Iceberg Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `ICEBERG_FORMAT_VERSION` | Iceberg table format | `"2"` |
| `ICEBERG_TABLE_TYPE` | Table type | `"ICEBERG"` |
| `ENABLE_VECTORIZATION` | Enable vectorized reads | `"false"` |

## Helper Functions

### `print_config()`
Prints the current configuration in a readable format.

**Usage:**
```python
from config import print_config
print_config()
```

**Output:**
```
======================================================================
ICEBERG + GLUE CONFIGURATION
======================================================================
AWS Profile:        tarun_student
AWS Region:         us-east-1
S3 Bucket:          tarun-lakehouse-bucket
...
======================================================================
```

### `get_spark_config()`
Returns a dictionary of all Spark configuration settings.

**Usage:**
```python
from config import get_spark_config

spark_config = get_spark_config()
builder = SparkSession.builder
for key, value in spark_config.items():
    builder = builder.config(key, value)
spark = builder.getOrCreate()
```

### `validate_setup()`
Validates that all required components are properly configured.

**Usage:**
```python
from config import validate_setup
validate_setup()
```

**Checks:**
- ✅ JAR files exist
- ✅ AWS credentials are valid
- ✅ S3 bucket is accessible

### `get_table_location(table_name)`
Generates the S3 location for a table.

**Usage:**
```python
from config import get_table_location

orders_location = get_table_location("orders")
# Returns: "s3://tarun-lakehouse-bucket/catalogs/glue/orders/"
```

## Using Config in Notebook

### Cell 2: Load Configuration
```python
import sys
sys.path.insert(0, '/Users/tarunvihartumati/iceberg-projects/glue-demo')
from config import *

import os
os.environ['AWS_PROFILE'] = AWS_PROFILE
os.environ['AWS_DEFAULT_REGION'] = AWS_REGION

print_config()
```

### Cell 5: Create Spark Session
```python
from pyspark.sql import SparkSession
import os

spark_config = get_spark_config()

builder = SparkSession.builder
for key, value in spark_config.items():
    builder = builder.config(key, value)

spark = builder.getOrCreate()
```

### Cell 10: Create Database
```python
spark.sql(f"CREATE DATABASE IF NOT EXISTS {CATALOG_NAME}.{DATABASE_NAME}")
```

### Cell 12: Create Table
```python
spark.sql(f"""
CREATE TABLE IF NOT EXISTS {FULL_TABLE_NAME} (
    id string,
    name string,
    price decimal(10,2)
)
USING iceberg
LOCATION '{TABLE_LOCATION}'
""")
```

## Testing Configuration

### Quick Test
```bash
cd ~/iceberg-projects/glue-demo
python3 config.py
```

This will:
1. Print your configuration
2. Validate JAR files exist
3. Test AWS credentials
4. Check S3 bucket access

### Expected Output
```
======================================================================
ICEBERG + GLUE CONFIGURATION
======================================================================
...
======================================================================

Validating setup...
✅ All JAR files found in ~/iceberg/jars
✅ AWS credentials valid for account: 047825088072
✅ S3 bucket 'tarun-lakehouse-bucket' is accessible

Setup validation complete!
```

## Multiple Environments

### Creating Different Configs

You can create multiple config files for different environments:

```bash
# Development config
cp config.template.py config_dev.py

# Production config
cp config.template.py config_prod.py
```

### Switching Environments

In your notebook, change the import:

```python
# For development
from config_dev import *

# For production
from config_prod import *
```

## Common Customizations

### Change Database Name
```python
DATABASE_NAME = "development"  # or "staging", "production"
```

### Use Different S3 Bucket
```python
S3_BUCKET_NAME = "my-other-bucket"
S3_BUCKET_PREFIX = "iceberg/tables"
```

### Update JAR Versions
```python
JAR_FILES = [
    "bundle-2.32.0.jar",  # Updated version
    "url-connection-client-2.32.0.jar",
    ...
]
```

## Best Practices

1. **Never commit config.py** - It's in `.gitignore` for security
2. **Always use config.template.py as reference** - Keep it updated
3. **Document custom changes** - Add comments to your config.py
4. **Validate after changes** - Run `python3 config.py` to test
5. **Use meaningful names** - For databases, tables, etc.

## Troubleshooting

### Config not found
```
ModuleNotFoundError: No module named 'config'
```
**Solution:** Make sure you've created `config.py` from the template

### Import errors
```
ImportError: cannot import name 'AWS_PROFILE' from 'config'
```
**Solution:** Verify your config.py has all required variables

### Path issues
```
FileNotFoundError: JAR files not found
```
**Solution:** Check `JARS_DIR` points to the correct directory

## Benefits of This Approach

✅ **Single Source of Truth** - All settings in one place
✅ **Easy Updates** - Change once, apply everywhere
✅ **Environment Management** - Switch configs easily
✅ **Security** - Keep credentials out of git
✅ **Maintainability** - Clear, organized structure
✅ **Validation** - Built-in checks for setup

## Next Steps

1. Create your `config.py` from the template
2. Update with your settings
3. Run validation: `python3 config.py`
4. Run the notebook with new config
5. Create additional configs for other environments if needed
