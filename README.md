
# Agents for Real — Separate Files Package (Full)

This archive contains: slides (Markdown), notebooks, code, and assets demonstrating LangChain, LangFlow, LangGraph, and MCP for building AI agents.

## Structure
- `presentation/Agents_for_Real_slides.md` - Presentation slides
- `notebooks/llm_agents_langchain_langflow_demo.ipynb` - Main demo notebook
- `notebooks/mcp_addon_minimal.ipynb` - MCP integration demo
- `code/mcp_safe_server.py` - Safe MCP server implementation
- `environment.yml` - Conda environment (auto-detects GPU/CPU)
- `environment-gpu.yml` - GPU environment with CUDA support
- `environment-cpu.yml` - CPU-only environment
- `requirements.txt` - Legacy pip requirements (use conda instead)

## Quick Start (Recommended: Conda/Mamba)

### Prerequisites

Install Miniforge (includes both conda and mamba):

**Linux/WSL:**
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh
# Restart your terminal after installation
```

**macOS:**
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh
bash Miniforge3-MacOSX-$(uname -m).sh
# Restart your terminal after installation

If you are not setting coda as your default, initialize conda for your shell:
```bash
conda_setup
```

### Automated Setup (RECOMMENDED - Fast!)

**Use the fast setup** - Minimal conda + staged pip installation (5-15 minutes):

```bash
bash setup-fast.sh
```

Or use the Makefile:

```bash
make setup       # Default: Fast setup (recommended!)
make setup-fast  # Same as above
```

⚡ **Why this is better:**
- Uses minimal conda environment (only CUDA, PyTorch, Jupyter)
- Installs most packages via pip (much faster, no memory issues)
- Staged installation prevents memory spikes
- **Won't hang your system!**

### Alternative: Old Setup (May Hang!)

⚠️ **Not recommended** - Full conda resolution can hang with 500+ dependencies:

```bash
bash setup.sh       # Old method (30+ min, may hang)
make setup-old      # Old method via Makefile
```

This can take several minutes depending on your internet speed and system.

### Manual Setup

**Minimal Conda + Pip (Recommended):**

For GPU systems:
```bash
# 1. Create minimal conda environment with CUDA
mamba env create -f environment-minimal-gpu.yml
conda activate agents_unplugged

# 2. Install Python packages via pip
pip install -r requirements-core.txt
pip install -r requirements-heavy.txt
pip install -r requirements-vllm.txt  # If you want vLLM
```

For CPU systems:
```bash
# 1. Create minimal conda environment (CPU only)
mamba env create -f environment-minimal-cpu.yml
conda activate agents_unplugged

# 2. Install Python packages via pip
pip install -r requirements-core.txt
pip install -r requirements-heavy.txt
# Skip vllm for CPU
```

**Full Conda (Not Recommended - May Hang!):**

If you insist on pure conda:
```bash
# GPU (may take 30+ min or hang!)
mamba env create -f environment-gpu.yml

# CPU (may take 30+ min or hang!)
mamba env create -f environment-cpu.yml
```

## Alternative: Pip Installation (Not Recommended)

If you cannot use conda/mamba:

```bash
python -m venv .venv && source .venv/bin/activate  # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

⚠️ **Note:** Pip installation may have CUDA version conflicts. Conda/mamba is strongly recommended for GPU systems.

## Configuration

Create and configure your API keys:

```bash
# Copy the example config
cp notebooks/config.json.example notebooks/config.json

# Edit with your API keys
nano notebooks/config.json  # or use your favorite editor
```

Configuration file format:
```json
{
  "OPENAI_API_BASE": "https://api.openai.com/v1",
  "API_KEY": "your_openai_api_key_here",
  "LANGFLOW_API_KEY": "your_langflow_api_key_here"
}
```

## Running the Notebooks

### Activate Environment

```bash
conda activate agents_unplugged
```

### Start Jupyter

```bash
jupyter notebook
# or use the Makefile
make jupyter
```

### Open and Run

1. Navigate to `notebooks/llm_agents_langchain_langflow_demo.ipynb`
2. Set the `BACKEND` variable (OPENAI or OLLAMA)
3. Run the cells!

## Optional: Local LLM with Ollama

Install Ollama for offline/local LLM usage:

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull a model
ollama pull llama3.1:8b
```

In the notebook, set `BACKEND = "OLLAMA"` to use local models.

## Optional: vLLM Server (GPU Required)

For high-performance inference with vLLM:

```bash
# Requires GPU environment
conda activate agents_unplugged

# Start vLLM server
vllm serve "swiss-ai/Apertus-8B-Instruct-2509" --gpu-memory-utilization 0.4
```

## Optional: LangFlow

Run LangFlow for visual flow building:

```bash
conda activate agents_unplugged
langflow run --host 127.0.0.1 --port 7860
```

Then call your flows via REST from the notebook.

## Optional: MCP Server

Start the MCP (Model Context Protocol) server:

```bash
python notebooks/safe_mcp_server.py
```

Then explore the `notebooks/mcp_addon_minimal.ipynb` notebook for MCP integration examples.

## Verify Installation

Test your installation:

```bash
make test
# or manually:
conda activate agents_unplugged
python -c "import torch; import langchain; print('✓ Installation successful!')"
```

## Troubleshooting

### GPU Not Detected

```bash
# Check CUDA availability
conda activate agents_unplugged
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

If CUDA is not available but you have a GPU:
1. Check GPU drivers: `nvidia-smi`
2. Reinstall with GPU environment: `make setup-gpu`

### Package Conflicts

```bash
# Clean and reinstall
make clean
make setup
```

### Out of Date Dependencies

```bash
# Update all packages
make update
```

## Makefile Commands

- `make help` - Show all available commands
- `make setup` - Auto-detect and setup environment
- `make jupyter` - Start Jupyter notebook
- `make test` - Verify installation
- `make clean` - Remove environment
- `make update` - Update packages

## Why Minimal Conda + Pip Hybrid?

This project uses a **hybrid approach**:
- **Conda for system dependencies**: CUDA, PyTorch, core scientific packages
- **Pip for Python packages**: LangChain, LangFlow, and other pure-Python packages

### Benefits:

1. **Fast Installation**: 5-15 minutes vs 30-60+ minutes (or hanging forever)
2. **No Memory Issues**: Conda resolver won't consume 10+ GB RAM
3. **Still GPU-Friendly**: Conda manages CUDA properly, pip installs on top
4. **Reproducible**: Locked versions in requirements files
5. **Flexible**: Easy to update individual packages

### Why Not Pure Conda?

Pure conda with 500+ dependencies (from langflow) causes:
- ❌ Conda SAT solver explosion (10+ GB RAM usage)
- ❌ Can hang indefinitely on dependency resolution
- ❌ 30-60+ minute installation times (if it completes)

### Why Not Pure Pip?

Pure pip doesn't manage:
- ❌ CUDA toolkit versions
- ❌ Binary compatibility between PyTorch and CUDA
- ❌ System-level dependencies

**The hybrid approach gives you the best of both worlds!**
