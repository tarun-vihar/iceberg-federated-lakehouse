# Prerequisites & Setup Guide

This guide walks you through setting up your development environment for the Federated Lakehouse project.

## 📋 System Requirements

### Required Software

1. **Python 3.11+**
   ```bash
   python3 --version  # Should be 3.11 or higher
   ```

2. **Java 11+** (for PySpark)
   ```bash
   java -version  # Should be 11 or higher
   ```

3. **Git**
   ```bash
   git --version
   ```

### Recommended Software

- **AWS CLI** - For managing AWS resources
- **Snowflake CLI** (optional) - For Snowflake operations
- **Docker** (optional) - For containerized development

---

## 🚀 Quick Start Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/tarun-vihar/iceberg-federated-lakehouse.git
cd iceberg-federated-lakehouse
```

### Step 2: Create Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate  # On macOS/Linux
# OR
venv\Scripts\activate     # On Windows
```

### Step 3: Install Dependencies

**Option A: Full Installation (includes GenAI libraries)**
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**Option B: Minimal Installation (PySpark + AWS only)**
```bash
pip install --upgrade pip
pip install -r requirements-minimal.txt
```

### Step 4: Verify Installation

```bash
# Test PySpark
python -c "import pyspark; print(f'PySpark {pyspark.__version__} installed!')"

# Test Findspark
python -c "import findspark; findspark.init(); print('Spark found!')"

# Test Boto3
python -c "import boto3; print(f'Boto3 {boto3.__version__} installed!')"
```

---

## 🔧 Java Setup (for PySpark)

### macOS (using Homebrew)

```bash
# Install Java 11
brew install openjdk@11

# Set JAVA_HOME
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
source ~/.zshrc

# Verify
java -version
echo $JAVA_HOME
```

### Linux (Ubuntu/Debian)

```bash
# Install Java 11
sudo apt update
sudo apt install openjdk-11-jdk

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
source ~/.bashrc

# Verify
java -version
```

### Windows

1. Download Java 11 JDK from [Oracle](https://www.oracle.com/java/technologies/downloads/#java11) or [Adoptium](https://adoptium.net/)
2. Install and note installation path
3. Set JAVA_HOME environment variable to installation path
4. Add `%JAVA_HOME%\bin` to PATH

---

## 📦 Iceberg JAR Files Setup

PySpark requires Iceberg JAR files. Download them once:

```bash
# Create jars directory
mkdir -p ~/iceberg/jars
cd ~/iceberg/jars

# Download required JARs (URLs may need updating for latest versions)
# Check versions at: https://mvnrepository.com/

# Iceberg Spark Runtime
wget https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.13/1.5.0/iceberg-spark-runtime-3.5_2.13-1.5.0.jar

# AWS SDK Bundle
wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.648/aws-java-sdk-bundle-1.12.648.jar

# Verify downloads
ls -lh ~/iceberg/jars/
```

**Or use the automated script:**
```bash
./scripts/setup/download-jars.sh
```

---

## ☁️ AWS Setup

### 1. Install AWS CLI

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
Download from [AWS CLI Website](https://aws.amazon.com/cli/)

### 2. Configure AWS Credentials

```bash
aws configure --profile tarun_student

# Enter when prompted:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json
```

### 3. Verify AWS Setup

```bash
# Test credentials
aws sts get-caller-identity --profile tarun_student

# Test S3 access
aws s3 ls --profile tarun_student
```

---

## 🔐 Credentials Setup

### 1. Copy API Keys Template

```bash
cd credentials/
cp api-keys.template.env api-keys.env
```

### 2. Edit with Your Keys

```bash
vim api-keys.env  # or use your preferred editor

# Fill in:
# - AWS credentials
# - GitHub token
# - Snowflake credentials
# - GenAI API keys (OpenAI, Anthropic, etc.)
```

### 3. Load Credentials

```bash
# In terminal
source credentials/api-keys.env

# Or in Python/Jupyter
from dotenv import load_dotenv
load_dotenv('credentials/api-keys.env')
```

---

## ❄️ Snowflake Setup (Optional)

### 1. Create Snowflake Account

Sign up at [Snowflake](https://signup.snowflake.com/)

### 2. Note Your Details

- Account identifier: `YOUR_ORG-YOUR_ACCOUNT`
- Username: `YOUR_USERNAME`
- Password: `YOUR_PASSWORD`

### 3. Update Credentials

Add to `credentials/api-keys.env`:
```bash
SNOWFLAKE_ACCOUNT=your_account_identifier
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
```

---

## 🧪 Verify Complete Setup

Run this verification script:

```bash
python scripts/setup/verify-setup.sh
```

Or manually verify:

```python
# test_setup.py
import sys
import subprocess

checks = {
    "Python 3.11+": lambda: sys.version_info >= (3, 11),
    "PySpark": lambda: __import__('pyspark'),
    "Findspark": lambda: __import__('findspark'),
    "Boto3": lambda: __import__('boto3'),
    "Jupyter": lambda: __import__('jupyter'),
    "Java": lambda: subprocess.run(['java', '-version'], capture_output=True).returncode == 0
}

print("Verification Results:")
print("=" * 50)
for name, check in checks.items():
    try:
        check()
        print(f"✅ {name}")
    except Exception as e:
        print(f"❌ {name}: {str(e)}")
```

---

## 🎯 Next Steps

Once setup is complete:

1. **Test PySpark + Glue Demo**
   ```bash
   cd compute-engines/pyspark/glue-catalog/
   jupyter notebook glue_iceberg_demo.ipynb
   ```

2. **Configure Snowflake** (if using)
   - See `compute-engines/snowflake/glue-catalog/setup.sql`

3. **Start Learning GenAI** (optional)
   - See `genai/01-fundamentals/README.md`

---

## 🐛 Troubleshooting

### Common Issues

**Issue: "java command not found"**
```bash
# Solution: Install Java and set JAVA_HOME
brew install openjdk@11
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
```

**Issue: "findspark cannot find Spark"**
```bash
# Solution: Ensure PySpark is installed in same environment
pip install pyspark findspark
```

**Issue: "AWS credentials not found"**
```bash
# Solution: Configure AWS CLI
aws configure --profile tarun_student
```

**Issue: "Module not found" errors**
```bash
# Solution: Ensure virtual environment is activated
source venv/bin/activate
pip install -r requirements.txt
```

---

## 📚 Additional Resources

- [Apache Spark Installation Guide](https://spark.apache.org/docs/latest/)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [Jupyter Notebook Documentation](https://jupyter-notebook.readthedocs.io/)
- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)

---

**Last Updated**: November 1, 2024
