# GenAI Learning and Integration

This directory contains learning materials and implementations for integrating GenAI technologies with the lakehouse architecture.

## Learning Path

Follow these modules in order:

### 1. [Fundamentals](01-fundamentals/) - 🔵 Not Started
Start here to learn LLM basics, embeddings, and prompt engineering.

### 2. [RAG](02-rag/) - 🔵 Not Started
Learn Retrieval Augmented Generation patterns and implement RAG pipelines.

### 3. [LangChain](03-langchain/) - 🔵 Not Started
Explore LangChain framework for building LLM applications.

### 4. [LlamaIndex](04-llamaindex/) - 🔵 Not Started
Learn LlamaIndex for data framework and indexing.

### 5. [Vector Stores](05-vector-stores/) - 🔵 Not Started
Implement and compare different vector databases.

### 6. [MCP Integration](06-mcp-integration/) - 🔵 Not Started
Build Model Context Protocol servers for lakehouse access.

## Prerequisites

- Python 3.11+
- OpenAI API key (for GPT models)
- Anthropic API key (for Claude models)
- Basic understanding of machine learning concepts

## Setup

```bash
# Install GenAI dependencies
pip install openai anthropic langchain llamaindex chromadb pinecone-client

# Set API keys
export OPENAI_API_KEY="your-key-here"
export ANTHROPIC_API_KEY="your-key-here"
```

## Integration with Lakehouse

The goal is to enable natural language interactions with lakehouse data:
- Query catalogs using natural language
- Generate SQL from natural language
- Auto-generate insights from data
- Conversational data exploration

See [../integrations/lakehouse-genai/](../integrations/lakehouse-genai/) for integration examples.
