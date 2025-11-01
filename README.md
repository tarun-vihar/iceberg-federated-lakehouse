# Federated Lakehouse with GenAI Integration

> A comprehensive learning and implementation project combining Apache Iceberg, multiple catalogs (AWS Glue, Polaris), compute engines (PySpark, Snowflake), and GenAI technologies (RAG, LangChain, LlamaIndex).

[![Architecture](docs/architecture/images/federated-architecture.png)](docs/architecture/01-federated-lakehouse.md)

## 🎯 Project Vision

This project demonstrates a **Federated Lakehouse Architecture** where multiple compute engines can seamlessly work with different catalog systems over a unified data storage layer (S3/Iceberg). Additionally, it explores integrating GenAI capabilities to enable natural language interactions with lakehouse data.

### Key Objectives

1. **Multi-Catalog Lakehouse**: Build a federated data architecture using Apache Iceberg with AWS Glue and Polaris catalogs
2. **Multi-Engine Support**: Enable PySpark, Snowflake, Trino, DuckDB, and other engines to access the same data
3. **GenAI Integration**: Implement RAG, LangChain, and LlamaIndex to enable AI-powered data exploration
4. **MCP Buffet Architecture**: Create Model Context Protocol servers for unified lakehouse access
5. **Learning Journey**: Document learnings and best practices for data engineering and GenAI

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Compute Engines Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌───────┐  ┌────────┐  ┌────────┐ │
│  │ PySpark  │  │Snowflake │  │ Trino │  │DuckDB  │  │  EMR   │ │
│  └──────────┘  └──────────┘  └───────┘  └────────┘  └────────┘ │
└────────────────────┬────────────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────────────┐
│                    Catalog Layer (Metadata)                      │
│  ┌──────────────┐         ┌──────────────┐      ┌─────────┐    │
│  │  AWS Glue    │         │   Polaris    │      │  Unity  │    │
│  │   Catalog    │         │   Catalog    │      │ Catalog │    │
│  └──────────────┘         └──────────────┘      └─────────┘    │
└────────────────────┬────────────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────────────┐
│                  Storage Layer (Data)                            │
│              Apache Iceberg Tables on S3                         │
│         (Parquet files + Iceberg metadata)                       │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                     GenAI Layer (Future)                          │
│  ┌──────┐  ┌──────────┐  ┌───────────┐  ┌──────────────────┐   │
│  │ RAG  │  │LangChain │  │LlamaIndex │  │ MCP Servers      │   │
│  └──────┘  └──────────┘  └───────────┘  └──────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
iceberg-projects/
├── compute-engines/          # Engine-specific implementations
│   ├── pyspark/             # PySpark demos
│   │   ├── glue-catalog/    ✅ Working
│   │   └── polaris-catalog/ ⚠️  In Progress
│   ├── snowflake/           # Snowflake SQL scripts
│   │   ├── glue-catalog/    ✅ Working
│   │   └── polaris-catalog/ ⚠️  Not Tested
│   └── databricks/          🚀 Future (optional)
│
├── catalogs/                # Catalog configurations
│   ├── glue/               # AWS Glue setup
│   └── polaris/            # Polaris setup
│
├── genai/                  # GenAI learning and implementations
│   ├── 01-fundamentals/    # LLM basics
│   ├── 02-rag/            # RAG implementations
│   ├── 03-langchain/      # LangChain projects
│   ├── 04-llamaindex/     # LlamaIndex projects
│   ├── 05-vector-stores/  # Vector databases
│   └── 06-mcp-integration/ # MCP Buffet architecture
│
├── integrations/          # Cross-platform integrations
│   ├── lakehouse-genai/   # AI-powered lakehouse features
│   ├── data-quality/      🚀 Future
│   └── orchestration/     🚀 Future
│
├── examples/              # End-to-end use cases
│   ├── 01-multi-catalog-query/
│   ├── 02-time-travel-comparison/
│   ├── 03-ai-powered-analytics/
│   └── 04-federated-rag/
│
└── docs/                  # Documentation
    ├── architecture/      # Architecture docs
    ├── learning-notes/    # Learning journey notes
    ├── setup-guides/      # Setup instructions
    └── troubleshooting/   # Common issues
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Java 11+ (for PySpark)
- AWS Account with S3 access
- Snowflake Account (optional)
- OpenAI/Anthropic API keys (for GenAI demos)

### 1. PySpark with AWS Glue Catalog

```bash
cd compute-engines/pyspark/glue-catalog/
jupyter notebook glue_iceberg_demo.ipynb
```

See [PySpark + Glue README](compute-engines/pyspark/glue-catalog/README.md) for details.

### 2. Snowflake with Glue Catalog

```bash
cd compute-engines/snowflake/glue-catalog/
# Run setup.sql in Snowflake worksheet
```

See [Snowflake + Glue README](compute-engines/snowflake/glue-catalog/README.md) for details.

### 3. GenAI Fundamentals

```bash
cd genai/01-fundamentals/llm-basics/
jupyter notebook 01-first-prompt.ipynb
```

See [GenAI Learning Path](genai/README.md) for details.

## 📚 Learning Resources

- [Architecture Guide](ARCHITECTURE.md) - Detailed architecture explanation
- [Learning Journey](LEARNING.md) - Track your progress
- [Roadmap](ROADMAP.md) - Future development plans
- [Setup Guides](docs/setup-guides/) - Step-by-step setup instructions

## 🎓 Current Status

### ✅ Working
- PySpark → AWS Glue Catalog → S3 Iceberg tables
- Snowflake → AWS Glue Catalog (via Catalog Integration)

### ⚠️ In Progress
- PySpark → Polaris Catalog → S3 Iceberg tables
- Snowflake → Polaris Catalog (External Volume)

### 🚀 Planned
- GenAI RAG over Iceberg metadata
- LangChain agents for lakehouse operations
- MCP servers for unified access
- Multi-engine benchmarking
- Databricks integration (optional)

## 🤝 Contributing

This is primarily a learning project, but suggestions and improvements are welcome!

## 📝 License

This project is for educational purposes.

## 🔗 Related Projects

- [Apache Iceberg](https://iceberg.apache.org/)
- [AWS Glue Catalog](https://docs.aws.amazon.com/glue/)
- [Polaris Catalog](https://www.snowflake.com/en/data-cloud/workloads/apache-iceberg/)
- [LangChain](https://www.langchain.com/)
- [LlamaIndex](https://www.llamaindex.ai/)

---

**Author**: Tarun Vihar Tumati
**Last Updated**: November 1, 2024
**Project Status**: Active Development
