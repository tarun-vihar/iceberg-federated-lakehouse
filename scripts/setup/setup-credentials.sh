#!/bin/bash

# Credentials Setup Helper Script
# This script helps you set up and manage API keys and credentials

set -e  # Exit on error

CREDENTIALS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/credentials"
TEMPLATE_FILE="$CREDENTIALS_DIR/api-keys.template.env"
ENV_FILE="$CREDENTIALS_DIR/api-keys.env"

echo "============================================"
echo "API Keys & Credentials Setup"
echo "============================================"
echo ""

# Check if credentials directory exists
if [ ! -d "$CREDENTIALS_DIR" ]; then
    echo "❌ Credentials directory not found!"
    echo "   Expected: $CREDENTIALS_DIR"
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Template file not found!"
    echo "   Expected: $TEMPLATE_FILE"
    exit 1
fi

# Check if .env file already exists
if [ -f "$ENV_FILE" ]; then
    echo "⚠️  Credentials file already exists:"
    echo "   $ENV_FILE"
    echo ""
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✅ Keeping existing credentials file"
        exit 0
    fi
fi

# Copy template to .env
echo "📝 Creating credentials file from template..."
cp "$TEMPLATE_FILE" "$ENV_FILE"
echo "✅ Created: $ENV_FILE"
echo ""

echo "============================================"
echo "Next Steps:"
echo "============================================"
echo ""
echo "1. Edit your credentials file:"
echo "   vim $ENV_FILE"
echo "   # or use your preferred editor"
echo ""
echo "2. Fill in your actual API keys"
echo ""
echo "3. Load environment variables:"
echo "   source $ENV_FILE"
echo ""
echo "4. Verify keys are loaded:"
echo "   echo \$GITHUB_TOKEN"
echo "   echo \$OPENAI_API_KEY"
echo ""
echo "============================================"
echo "Security Reminders:"
echo "============================================"
echo ""
echo "✅ api-keys.env is gitignored (never committed)"
echo "⚠️  Never share your actual keys"
echo "🔄 Rotate keys every 90 days"
echo ""
