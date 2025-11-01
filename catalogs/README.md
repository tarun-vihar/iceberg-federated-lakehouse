# Catalog Layer

This directory contains configurations and setup instructions for different catalog implementations.

## What is a Catalog?

In a lakehouse architecture, the catalog is the metadata layer that stores information about:
- Databases and namespaces
- Table schemas
- Table locations
- Partitions
- Snapshots and history
- Statistics

The catalog is separate from the data itself (stored in S3), allowing multiple compute engines to access the same data through different catalogs.

## Available Catalogs

### [AWS Glue](glue/) - ✅ Working
- **Type**: Managed service (AWS)
- **Best For**: AWS-native workloads, integration with Lake Formation
- **Pros**: Serverless, highly available, integrates with AWS ecosystem
- **Cons**: AWS vendor lock-in, costs can add up

### [Polaris](polaris/) - ⚠️ In Progress
- **Type**: Open-source (can be self-hosted or Snowflake-hosted)
- **Best For**: Vendor-neutral setups, multi-cloud
- **Pros**: Open-source, REST API, flexible deployment
- **Cons**: Self-hosting requires operational overhead

### [Unity Catalog](unity-catalog/) - 🚀 Planned
- **Type**: Open-source (Databricks-initiated)
- **Best For**: Multi-modal data (tables, ML models, files)
- **Pros**: Unified governance, open-source
- **Cons**: Still maturing

### [Nessie](nessie/) - 🚀 Planned
- **Type**: Open-source (Git-like versioning)
- **Best For**: Data versioning, multi-table transactions
- **Pros**: Git-like semantics, branching/tagging
- **Cons**: Additional complexity

## Catalog Comparison

| Feature | Glue | Polaris | Unity | Nessie |
|---------|------|---------|-------|--------|
| **Deployment** | Managed | Managed/Self | Self | Self |
| **REST API** | ✅ | ✅ | ✅ | ✅ |
| **Multi-cloud** | ❌ | ✅ | ✅ | ✅ |
| **Open Source** | ❌ | ✅ | ✅ | ✅ |
| **Versioning** | Basic | Basic | Basic | Advanced |
| **Maturity** | High | Medium | Medium | Medium |

## Choosing a Catalog

**Use AWS Glue if:**
- You're all-in on AWS
- You need Lake Formation integration
- You want zero operational overhead

**Use Polaris if:**
- You want vendor neutrality
- You need multi-cloud support
- You prefer open-source solutions

**Use Unity Catalog if:**
- You need unified governance across data types
- You're using Databricks
- You want ML model cataloging

**Use Nessie if:**
- You need advanced versioning (branches, tags)
- You want multi-table transactions
- You're comfortable with operational overhead
