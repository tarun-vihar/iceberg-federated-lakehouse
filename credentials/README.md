# Credentials Management

This directory stores sensitive API keys and credentials for the project.

## 🔒 Security Rules

**IMPORTANT:**
- ✅ All actual credentials are `.gitignore`d and **NEVER** committed to git
- ✅ Only templates (`.template.*` files) are committed
- ✅ Always use environment variables or config files for credentials
- ❌ NEVER hardcode credentials in notebooks or scripts

## 📁 File Organization

```
credentials/
├── README.md                      # This file (committed)
├── .gitkeep                       # Keep directory in git (committed)
├── api-keys.template.env          # Template (committed)
├── api-keys.env                   # YOUR KEYS (gitignored)
├── aws-credentials.template.json  # Template (committed)
├── aws-credentials.json           # YOUR KEYS (gitignored)
└── snowflake-config.template.json # Template (committed)
```

## 🚀 Quick Setup

### 1. Copy Templates

```bash
cd credentials/

# Copy and fill in your actual keys
cp api-keys.template.env api-keys.env
# Edit api-keys.env with your actual keys
```

### 2. Load Environment Variables

**Option A: Manual Load (each session)**
```bash
# Load all environment variables
source credentials/api-keys.env

# Or load specific ones
export OPENAI_API_KEY=$(grep OPENAI_API_KEY credentials/api-keys.env | cut -d '=' -f2)
```

**Option B: Auto-load (add to ~/.zshrc or ~/.bashrc)**
```bash
# Add this line to your shell config
source ~/iceberg-projects/credentials/api-keys.env
```

**Option C: Use in Python**
```python
from dotenv import load_dotenv
import os

# Load from .env file
load_dotenv('credentials/api-keys.env')

# Access keys
openai_key = os.getenv('OPENAI_API_KEY')
```

**Option D: Use in Jupyter Notebooks**
```python
%load_ext dotenv
%dotenv credentials/api-keys.env

import os
github_token = os.getenv('GITHUB_TOKEN')
```

## 📝 Available Templates

### 1. **api-keys.env**
Main environment file for all API keys:
- GitHub token
- AWS credentials
- Snowflake credentials
- LLM API keys (OpenAI, Anthropic)
- Vector database keys

### 2. **AWS Credentials** (Optional)
If you prefer JSON format for AWS:
```json
{
  "aws_access_key_id": "YOUR_KEY",
  "aws_secret_access_key": "YOUR_SECRET",
  "region": "us-east-1"
}
```

### 3. **Snowflake Config** (Optional)
For Snowflake connection details:
```json
{
  "account": "your-account",
  "user": "YOUR_USER",
  "password": "YOUR_PASSWORD",
  "warehouse": "iceberg_vw",
  "database": "iceberg_db"
}
```

## 🛡️ Best Practices

### DO ✅
- Use environment variables whenever possible
- Rotate keys regularly (every 90 days)
- Use separate keys for dev/prod
- Keep templates updated
- Use `.env` files for local development
- Use AWS Secrets Manager / Vault for production

### DON'T ❌
- Never commit actual keys to git
- Never share keys in Slack/email
- Never hardcode keys in code
- Never use production keys in development
- Never commit `.env` files (only `.template.env`)

## 🔄 Key Rotation Checklist

When rotating keys:
- [ ] Generate new key in service (GitHub, AWS, etc.)
- [ ] Update `credentials/api-keys.env`
- [ ] Test new key works
- [ ] Revoke old key
- [ ] Update documentation if needed

## 🚨 If Keys Are Leaked

If you accidentally commit keys to git:

1. **Immediately revoke the key** in the service
2. **Generate a new key**
3. **Remove from git history:**
   ```bash
   # Use BFG Repo Cleaner or git filter-branch
   # Then force push (be careful!)
   ```
4. **Notify your team** if it's a shared repo

## 📚 Related Documentation

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GitHub Token Security](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Python dotenv Documentation](https://pypi.org/project/python-dotenv/)

## 🔍 Verify Security

Check that credentials are not tracked:
```bash
# Should show credentials/* in .gitignore
cat ../.gitignore | grep credentials

# Should NOT show api-keys.env
git status
```
