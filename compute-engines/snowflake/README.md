# Snowflake Compute Engine

This directory contains Snowflake SQL scripts for accessing Iceberg tables through different catalogs.

## Available Integrations

- **[glue-catalog](glue-catalog/)** - ✅ Snowflake + Glue Catalog via Catalog Integration (Working)
- **[polaris-catalog](polaris-catalog/)** - ⚠️ Snowflake + Polaris via External Volume (Not Tested)
- **[snowflake-catalog](snowflake-catalog/)** - 🚀 Snowflake native catalog (Planned)

## Quick Start

Each integration includes:
- `setup.sql` - Complete setup script with detailed comments
- `README.md` - Specific instructions and prerequisites
- `debugger.sql` - Troubleshooting queries (if applicable)

## Prerequisites

- Snowflake account with ACCOUNTADMIN access
- AWS S3 bucket for Iceberg tables
- IAM role with appropriate permissions
