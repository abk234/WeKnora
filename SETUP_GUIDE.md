# WeKnora Setup Guide

## 📋 Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Environment Configuration](#environment-configuration)
- [Quick Start](#quick-start)
- [Available Tools & Features](#available-tools--features)
- [Configuration Options](#configuration-options)
- [Troubleshooting](#troubleshooting)
- [Development Mode](#development-mode)

## 🎯 Overview

**WeKnora** is an LLM-powered framework for document understanding and semantic retrieval (RAG system). It provides:
- Multi-type knowledge bases (FAQ, Document)
- ReACT Agent mode with tool calling
- Support for local models (Ollama, LLAMA-CPP)
- Web UI with conversation management
- Multiple vector storage backends

## ✅ Prerequisites

### Required
- **Docker** (with Docker Compose v2 or docker-compose v1)
- **Git**

### Optional (for local models)
- **Ollama** (for local LLM models)
- Runs on Linux, macOS, or Windows with WSL2

### System Requirements
- **Memory**: Minimum 4GB RAM (8GB+ recommended)
- **Disk**: Minimum 10GB free space
- **CPU**: Multi-core processor recommended

## ⚙️ Environment Configuration

### Current Configuration Status

Your `.env` file has been configured with:

```bash
# Application Ports (Updated to avoid conflicts)
APP_PORT=8082          # Backend API port
FRONTEND_PORT=8083     # Web UI port
DOCREADER_PORT=50051   # Document parser port

# Database
DB_DRIVER=postgres
DB_USER=postgres
DB_PASSWORD=postgres123!@#
DB_NAME=WeKnora

# Storage
STORAGE_TYPE=local
LOCAL_STORAGE_BASE_DIR=./data/files

# Redis (for task queue)
STREAM_MANAGER_TYPE=redis
REDIS_PASSWORD=redis123!@#

# Vector Storage
RETRIEVE_DRIVER=postgres  # Options: postgres, elasticsearch_v7, elasticsearch_v8, qdrant

# Ollama (for local models)
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Security
TENANT_AES_KEY=weknorarag-api-key-secret-secret
JWT_SECRET=weknora-jwt-secret

# Features
ENABLE_GRAPH_RAG=false  # Set to true to enable knowledge graph
```

### 🔑 Important Notes

1. **Python Environment**: NOT required! Python dependencies run inside Docker containers.

2. **Telemetry**: Jaeger tracing is optional and disabled by default.
   - To enable: `docker compose --profile jaeger up -d`

3. **Local Models**: Application supports:
   - Ollama (recommended for local LLM models)
   - LLAMA-CPP (via Ollama)
   - External APIs (OpenAI, etc.)

4. **No External Dependencies**: Works completely offline with local models.

## 🚀 Quick Start

### Option 1: Simple Startup (Recommended)

```bash
# Start all services
./start.sh
```

This script will:
- Check environment configuration
- Start Ollama (if configured locally)
- Start Docker containers
- Display access URLs

### Option 2: Manual Startup

```bash
# Start only Docker services
./scripts/start_all.sh --docker

# Start with Ollama
./scripts/start_all.sh --all

# Or use Make
make start-all
```

### Option 3: Development Mode (Hot Reload)

```bash
# Terminal 1: Start infrastructure
make dev-start

# Terminal 2: Start backend (with hot reload)
make dev-app

# Terminal 3: Start frontend (with hot reload)
make dev-frontend
```

### Stopping Services

```bash
# Simple stop
./stop.sh

# Or
./scripts/start_all.sh --stop

# Or
make stop-all
```

## 🌐 Accessing the Application

After startup, access services at:

| Service | URL | Description |
|---------|-----|-------------|
| **Web UI** | http://localhost:8083 | Main application interface |
| **API** | http://localhost:8082 | Backend REST API |
| **Health Check** | http://localhost:8082/health | API health status |
| **Jaeger UI** | http://localhost:16686 | Tracing (if enabled) |

### First Time Setup

1. **Access the Web UI**: http://localhost:8083
2. **Register an Account**: You'll be redirected to registration on first visit
3. **Configure Models**: Navigate to settings to configure:
   - LLM Model (e.g., Ollama models)
   - Embedding Model
   - Rerank Model (optional)

## 🛠 Available Tools & Features

### 1. Knowledge Base Management

**Create Knowledge Bases:**
- Click "New Knowledge Base"
- Select type: FAQ or Document
- Configure settings

**Import Documents:**
- Drag & drop files
- Folder import
- URL import
- Online entry

**Supported Formats:**
- PDF
- Word (DOC, DOCX)
- Text (TXT)
- Markdown (MD)
- Images (with OCR)
- Excel (XLS, XLSX)
- CSV

### 2. Conversation Features

**Agent Mode:**
- Enable/disable in conversation input
- Uses ReACT pattern
- Can call built-in tools
- Web search integration
- MCP tool support

**Normal Mode:**
- Standard RAG retrieval
- Context-aware responses
- Multi-turn conversations

**Configuration:**
- Set retrieval thresholds
- Configure prompt templates
- Adjust rerank settings
- Enable/disable query rewriting

### 3. Model Configuration

**LLM Models (for generation):**
```bash
# Example Ollama models
- qwen2.5:7b
- llama3.1:8b
- deepseek-r1:7b
- mistral:7b
```

**Embedding Models (for vector search):**
```bash
# Local options via Ollama
- nomic-embed-text
- mxbai-embed-large
- bge-m3

# Or use external APIs
```

**How to use local models:**
```bash
# 1. Ensure Ollama is running
ollama serve

# 2. Pull models
ollama pull qwen2.5:7b
ollama pull nomic-embed-text

# 3. Configure in Web UI
# Navigate to: Settings > Models
# Add model with base URL: http://host.docker.internal:11434
```

### 4. Search & Retrieval

**Retrieval Strategies:**
- BM25 (keyword search)
- Dense retrieval (vector search)
- Hybrid (combined)
- GraphRAG (with knowledge graph)

**Configuration:**
- Adjust `vector_threshold` for relevance
- Set `rerank_threshold` for precision
- Configure `embedding_top_k` for recall

### 5. Web Search Integration

**Available Engines:**
- DuckDuckGo (built-in, no API key needed)
- Extensible for other engines

**Configuration in `config/config.yaml`:**
```yaml
web_search:
  default:
    provider: "duckduckgo"
    max_results: 5
```

### 6. MCP (Model Context Protocol) Tools

**Supported Launchers:**
- uvx (Python-based tools)
- npx (Node.js-based tools)

**Transport Methods:**
- Stdio
- HTTP Streamable
- SSE (Server-Sent Events)

## ⚙️ Configuration Options

### Enabling Optional Features

**1. Knowledge Graph (GraphRAG)**
```bash
# In .env file
ENABLE_GRAPH_RAG=true

# Requires Neo4j
docker compose --profile neo4j up -d
```

**2. Jaeger Tracing**
```bash
docker compose --profile jaeger up -d
```

**3. MinIO Object Storage**
```bash
# In .env file
STORAGE_TYPE=minio

# Start MinIO
docker compose --profile minio up -d
```

**4. Qdrant Vector Database**
```bash
# In .env file
RETRIEVE_DRIVER=qdrant

# Start Qdrant
docker compose --profile qdrant up -d
```

### Vector Storage Comparison

| Backend | Best For | Notes |
|---------|----------|-------|
| **PostgreSQL** | Simple setup, all-in-one | Default, uses pgvector |
| **Elasticsearch** | Advanced search, analytics | Requires separate instance |
| **Qdrant** | High-performance vectors | Best for large-scale |

## 🔧 Troubleshooting

### Common Issues

**1. Port Already in Use**
```bash
# Check what's using the port
lsof -i :8082

# Solution: Change port in .env file
APP_PORT=8090
```

**2. Docker Permission Denied**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

**3. Ollama Not Connecting**
```bash
# Check Ollama status
curl http://localhost:11434/api/tags

# Restart Ollama
./scripts/start_all.sh --ollama
```

**4. Database Connection Failed**
```bash
# Check database status
docker compose ps postgres

# View logs
docker compose logs postgres

# Restart database
docker compose restart postgres
```

**5. Out of Memory**
```bash
# Increase Docker memory limit
# Docker Desktop: Settings > Resources > Memory

# Or reduce concurrent operations
CONCURRENCY_POOL_SIZE=2  # in .env
```

### Diagnostic Commands

```bash
# Check environment configuration
./scripts/check-env.sh

# View all container status
docker compose ps

# View logs
docker compose logs -f app
docker compose logs -f docreader

# Check system resources
docker stats

# List running containers
./scripts/start_all.sh --list

# Full environment check
./scripts/start_all.sh --check
```

### Reset & Clean

```bash
# Stop all services
./stop.sh

# Clean database volumes (WARNING: deletes all data)
make clean-db

# Remove all containers
docker compose down -v

# Rebuild from scratch
docker compose build --no-cache
docker compose up -d
```

## 💻 Development Mode

### Fast Development Workflow

Development mode allows code changes without rebuilding Docker images:

```bash
# Start infrastructure only (Postgres, Redis, etc.)
make dev-start

# In another terminal: Run backend locally
make dev-app

# In another terminal: Run frontend locally
make dev-frontend
```

**Requirements for dev mode:**
- Go 1.21+ (for backend)
- Node.js 18+ (for frontend)
- Air (for Go hot reload): `go install github.com/cosmtrek/air@latest`

**Advantages:**
- Frontend auto hot-reload
- Backend quick restart (5-10s)
- No Docker rebuild needed
- IDE debugging support

### Making Code Changes

```bash
# Backend changes (Go)
# Edit files in internal/, cmd/, etc.
# Air automatically reloads (if using dev-app)

# Frontend changes
# Edit files in frontend/src
# Vite automatically hot-reloads

# Config changes
# Edit config/config.yaml
# Restart backend: Ctrl+C then make dev-app
```

## ✅ Application Testing Results

The application has been successfully tested and verified to be working correctly.

### Health Check Results

```bash
# Backend API Health
$ curl http://localhost:8082/health
{"status":"ok"}

# Frontend Web UI
$ curl http://localhost:8083
✓ Loading successfully (React/Vue SPA)
```

### Available API Endpoints (Verified)

The application exposes a comprehensive REST API with the following capabilities:

**Authentication & User Management:**
- User registration and login
- JWT token refresh
- User profile management
- Password updates

**Knowledge Base Management:**
- Create, read, update, delete knowledge bases
- Configure knowledge base settings (retrieval, rerank, prompts)
- Support for FAQ and Document types

**Document Management:**
- Upload documents (PDF, DOCX, TXT, MD, etc.)
- Parse and chunk documents
- Import from URLs
- Folder import
- Track processing status

**FAQ Management:**
- Create FAQ entries
- Search FAQ database
- Update and delete entries

**Chunk Management:**
- View document chunks
- Update chunk metadata
- Delete chunks
- Manage generated questions

**Conversation & Chat:**
- Create and manage conversation sessions
- RAG-based knowledge chat
- Agent mode with ReACT pattern
- Knowledge search
- Generate conversation titles
- Stream responses

**Model Configuration:**
- Add LLM, embedding, and rerank models
- Test model connectivity
- Ollama integration with model download
- Remote API support

**MCP (Model Context Protocol) Integration:**
- Register MCP services
- Test MCP connections
- List available tools
- Access MCP resources

**Web Search:**
- DuckDuckGo integration
- Extensible search providers

**System & Initialization:**
- Check Ollama status
- List available Ollama models
- Download models via Ollama
- Test embedding models
- Check rerank models
- Multimodal function testing

### Known Warnings (Non-Critical)

The following warning appears in logs but does not affect functionality:
```
traces export: exporter export timeout: rpc error: code = Unavailable desc = name resolver error: produced zero addresses
```

**Explanation**: This occurs because OpenTelemetry tracing is configured but Jaeger is not running. This is expected and harmless since Jaeger is optional. To eliminate this warning, either:
1. Disable tracing in the config (if desired)
2. Start Jaeger: `docker compose --profile jaeger up -d`

### Next Steps After Testing

Now that the application is verified to be working:

1. **Access the Web UI**: Navigate to http://localhost:8083
2. **Register an account**: First-time setup requires user registration
3. **Configure models**: Add your Ollama models via Settings
4. **Create knowledge base**: Start with a test knowledge base
5. **Upload documents**: Test document parsing with a PDF or text file
6. **Test conversations**: Try both RAG mode and Agent mode

## 📊 Monitoring & Logs

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f docreader
docker compose logs -f postgres

# Recent logs only
docker compose logs --tail=100 -f

# Save logs to file
docker compose logs > weknora.log
```

### Jaeger Tracing

If enabled, view traces at: http://localhost:16686

**Use cases:**
- Debug performance issues
- Trace request flows
- Monitor latency
- Identify bottlenecks

## 🔒 Security Considerations

1. **Change Default Passwords**
```bash
# In .env file
DB_PASSWORD=your_secure_password
REDIS_PASSWORD=your_secure_redis_password
JWT_SECRET=your_random_secret_key
TENANT_AES_KEY=your_random_aes_key
```

2. **Internal Deployment**
   - WeKnora is designed for internal/private networks
   - Do NOT expose directly to public internet
   - Use firewall rules to restrict access

3. **API Keys**
   - Store securely, never commit to git
   - Rotate regularly
   - Use environment variables

## 🎓 Learning Resources

- **Official Documentation**: https://weknora.weixin.qq.com
- **API Reference**: See `docs/API.md` in repository
- **GitHub Issues**: https://github.com/Tencent/WeKnora/issues
- **Changelog**: See `CHANGELOG.md` for version history

## 📞 Getting Help

If you encounter issues:

1. Check this guide's Troubleshooting section
2. Review logs: `docker compose logs -f`
3. Check GitHub issues: https://github.com/Tencent/WeKnora/issues
4. Run diagnostics: `./scripts/start_all.sh --check`

---

**Happy Knowledge Building! 🚀**
