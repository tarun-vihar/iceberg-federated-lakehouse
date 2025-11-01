# My Learning Journey

## 🎯 Learning Objectives

This document tracks my learning progress across Data Lakehouse technologies and GenAI/ML. It serves as both a progress tracker and a reflection space for key learnings.

---

## 📚 Data Lakehouse Track

### Apache Iceberg
**Status**: 🟢 In Progress

#### Concepts Learned
- [x] Iceberg table format basics
- [x] Metadata layers (metadata.json, manifest files, data files)
- [x] Snapshot isolation and time travel
- [x] Schema evolution
- [x] Partition evolution
- [ ] Hidden partitioning
- [ ] Merge-on-read vs Copy-on-write
- [ ] Table maintenance (compaction, expiration)

#### Practical Skills
- [x] Creating Iceberg tables with PySpark
- [x] INSERT, UPDATE, DELETE operations
- [x] MERGE operations (upserts)
- [x] Time travel queries (VERSION AS OF)
- [x] Querying table history and snapshots
- [ ] Performance tuning
- [ ] Advanced partitioning strategies

#### Key Learnings
```
✨ Iceberg's snapshot isolation allows multiple writers without conflicts
✨ Metadata-only operations (like schema changes) are instant
✨ Time travel is powerful for debugging and auditing
```

---

### AWS Glue Catalog
**Status**: 🟢 Complete

#### Concepts Learned
- [x] Glue as a Hive Metastore alternative
- [x] Database and table organization
- [x] IAM permissions for Glue access
- [x] Lake Formation integration
- [x] Catalog versioning

#### Practical Skills
- [x] Creating databases and tables
- [x] Configuring PySpark to use Glue
- [x] Configuring Snowflake to use Glue
- [x] Managing Lake Formation permissions
- [x] Cross-account catalog access

#### Key Learnings
```
✨ Glue integrates seamlessly with AWS ecosystem
✨ Lake Formation provides fine-grained access control
✨ Glue catalog is serverless and highly available
```

---

### Polaris Catalog
**Status**: 🟡 In Progress

#### Concepts Learned
- [x] Polaris as open-source catalog
- [x] REST catalog API
- [x] Snowflake-hosted Polaris
- [ ] Self-hosted Polaris deployment
- [ ] Multi-region setup

#### Practical Skills
- [x] Basic PySpark + Polaris setup
- [ ] Production-ready configuration
- [ ] Polaris + Snowflake integration
- [ ] Access control policies

#### Key Learnings
```
✨ Polaris offers vendor-neutral catalog option
✨ REST API makes it engine-agnostic
⚠️ Configuration can be tricky - requires careful credential management
```

---

### Snowflake
**Status**: 🟢 In Progress

#### Concepts Learned
- [x] Snowflake architecture (storage, compute, services)
- [x] Virtual warehouses
- [x] External volumes
- [x] Catalog integrations
- [x] Iceberg table support
- [ ] Time travel in Snowflake
- [ ] Zero-copy cloning

#### Practical Skills
- [x] Creating external volumes
- [x] Linking to Glue catalog
- [x] Creating Iceberg tables
- [ ] Query performance optimization
- [ ] Cost optimization strategies

#### Key Learnings
```
✨ Snowflake's separation of storage and compute is powerful
✨ External volumes enable open data formats
✨ Catalog integrations bridge Snowflake with open ecosystems
```

---

## 🤖 GenAI/ML Track

### Large Language Models
**Status**: 🔵 Starting Soon

#### Planned Learning
- [ ] LLM fundamentals (transformers, attention)
- [ ] Prompt engineering techniques
- [ ] Model selection (GPT-4, Claude, Llama)
- [ ] Context window management
- [ ] Token optimization
- [ ] Temperature and sampling parameters

#### Practical Skills to Build
- [ ] Making API calls (OpenAI, Anthropic)
- [ ] Prompt templates
- [ ] Few-shot prompting
- [ ] Chain-of-thought prompting
- [ ] Structured output generation

---

### RAG (Retrieval Augmented Generation)
**Status**: 🔵 Not Started

#### Planned Learning
- [ ] RAG architecture patterns
- [ ] Document chunking strategies
- [ ] Embedding models (OpenAI, Sentence Transformers)
- [ ] Vector similarity search
- [ ] Retrieval optimization
- [ ] Hybrid search (vector + keyword)
- [ ] Re-ranking techniques

#### Practical Skills to Build
- [ ] Basic RAG pipeline
- [ ] Document preprocessing
- [ ] Vector store integration
- [ ] RAG evaluation (faithfulness, relevance)
- [ ] RAG over structured data (tables)

---

### LangChain
**Status**: 🔵 Not Started

#### Planned Learning
- [ ] LangChain architecture
- [ ] Chains (LLMChain, SequentialChain)
- [ ] Agents and tools
- [ ] Memory systems
- [ ] Callbacks and monitoring
- [ ] LangSmith for debugging

#### Practical Skills to Build
- [ ] Building custom chains
- [ ] Creating custom tools
- [ ] Agent orchestration
- [ ] Memory management
- [ ] Production deployment

---

### LlamaIndex
**Status**: 🔵 Not Started

#### Planned Learning
- [ ] LlamaIndex vs LangChain
- [ ] Index types (Vector, Tree, List)
- [ ] Query engines
- [ ] Data connectors
- [ ] Multi-document agents

#### Practical Skills to Build
- [ ] Building indexes
- [ ] Custom data connectors
- [ ] Query optimization
- [ ] Integration with catalogs

---

### Vector Databases
**Status**: 🔵 Not Started

#### Planned Learning
- [ ] Vector database concepts
- [ ] Similarity metrics (cosine, euclidean)
- [ ] Index types (HNSW, IVF)
- [ ] Chroma DB
- [ ] Pinecone
- [ ] Weaviate
- [ ] pgvector

#### Practical Skills to Build
- [ ] Setting up vector stores
- [ ] Ingesting embeddings
- [ ] Similarity search
- [ ] Filtering and metadata
- [ ] Performance tuning

---

### Model Context Protocol (MCP)
**Status**: 🔵 Not Started

#### Planned Learning
- [ ] MCP architecture
- [ ] Server implementation
- [ ] Tool definition
- [ ] Client integration
- [ ] Claude Desktop setup

#### Practical Skills to Build
- [ ] Building MCP servers
- [ ] Defining custom tools
- [ ] Integrating with lakehouse
- [ ] Multi-server orchestration

---

## 📊 Learning Metrics

### Time Invested
- **Data Lakehouse**: ~40 hours
- **GenAI/ML**: ~0 hours (starting soon)
- **Total**: ~40 hours

### Notebooks Created
- **Data Lakehouse**: 2
- **GenAI**: 0
- **Total**: 2

### Concepts Mastered
- **Iceberg**: 60% complete
- **Glue**: 80% complete
- **Polaris**: 40% complete
- **Snowflake**: 50% complete
- **GenAI**: 0% complete

---

## 💡 Key Insights & Aha Moments

### Week 1-2: Iceberg Basics
```
💡 The metadata layer architecture is genius - operations like schema
   changes are instant because they only update metadata files!

💡 Time travel isn't just for debugging - it's essential for compliance
   and data lineage.
```

### Week 3-4: Multi-Catalog Setup
```
💡 Different catalogs have different strengths:
   - Glue: AWS-native, serverless, integrated with Lake Formation
   - Polaris: Open-source, vendor-neutral, self-hostable

💡 The catalog is just metadata - the data layer (S3) remains the same.
   This is the foundation of the federated lakehouse!
```

### Week 5-6: Snowflake Integration
```
💡 Snowflake's external volumes + catalog integrations = best of both worlds
   - Use Snowflake's query engine
   - Keep data in open formats (Iceberg)
   - Maintain vendor independence

⚠️ Lake Formation permissions are tricky - need both IAM and LF grants
```

---

## 🎯 Next Steps

### This Week
- [ ] Fix Polaris demo configuration
- [ ] Test Snowflake + Polaris integration
- [ ] Document learnings in blog post

### This Month
- [ ] Complete all Phase 1 lakehouse demos
- [ ] Start GenAI fundamentals
- [ ] First RAG implementation

### This Quarter
- [ ] Master basic GenAI concepts
- [ ] Build RAG over Iceberg metadata
- [ ] Create first MCP server

---

## 📖 Resources I'm Using

### Books
- [ ] "Designing Data-Intensive Applications" - Martin Kleppmann
- [ ] "The Hundred-Page Machine Learning Book" - Andriy Burkov

### Courses
- [ ] LangChain for LLM Application Development (DeepLearning.AI)
- [ ] Building Systems with the ChatGPT API (DeepLearning.AI)

### Blogs & Documentation
- [x] Apache Iceberg Documentation
- [x] AWS Glue Documentation
- [ ] LangChain Documentation
- [ ] LlamaIndex Documentation

### Communities
- [ ] Apache Iceberg Slack
- [ ] LangChain Discord
- [ ] r/LocalLLaMA

---

## 🤔 Challenges & Solutions

### Challenge 1: Connection Refused Error in PySpark
**Problem**: Socket error when creating Spark session
**Solution**: Set `SPARK_LOCAL_IP='127.0.0.1'` environment variable
**Learning**: Python 3.14 compatibility issues with PySpark internals

### Challenge 2: Hardcoded Values in Notebooks
**Problem**: Notebooks broke when recreating tables
**Solution**: Created config.py template pattern with all variables
**Learning**: Configuration management is critical for reusability

### Challenge 3: Lake Formation Permissions
**Problem**: Snowflake couldn't access Glue catalog
**Solution**: Both IAM policies AND Lake Formation grants needed
**Learning**: AWS has multiple permission layers that must all align

---

## 📝 Reflection Questions

**What am I most proud of learning?**
> Building a working multi-catalog lakehouse from scratch. Understanding
> how all the pieces fit together - catalogs, storage, compute engines.

**What was most challenging?**
> AWS permissions and Lake Formation. The interaction between IAM, S3 bucket
> policies, and Lake Formation grants is complex.

**What surprised me?**
> How powerful Iceberg's metadata-only operations are. Schema evolution and
> time travel are game-changers for data engineering.

**What's next on my learning radar?**
> GenAI and RAG. I'm excited to combine lakehouse expertise with AI to
> enable natural language data exploration.

---

**Last Updated**: November 1, 2024
**Learning Since**: October 2024
**Total Journey Duration**: 1 month
