# PySpark Compute Engine

This directory contains PySpark-based implementations for accessing Iceberg tables through different catalogs.

## Available Demos

- **[glue-catalog](glue-catalog/)** - ✅ PySpark + AWS Glue Catalog integration (Working)
- **[polaris-catalog](polaris-catalog/)** - ⚠️ PySpark + Polaris Catalog integration (In Progress)

## Quick Start

Each catalog implementation includes:
- Jupyter notebook with step-by-step demo
- `config.template.py` - Configuration template (copy to `config.py`)
- `README.md` - Specific setup instructions

## Common Utilities

See [common/](common/) for shared utilities across all PySpark demos.
