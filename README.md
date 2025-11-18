
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
```

### Automated Setup

Run the automated setup script (detects GPU and installs appropriate environment):

```bash
bash setup.sh
```

Or use the Makefile:

```bash
make setup          # Auto-detect GPU/CPU
make setup-gpu      # Force GPU environment with CUDA
make setup-cpu      # Force CPU-only environment
```

### Manual Setup

**For GPU systems with CUDA:**
```bash
mamba env create -f environment-gpu.yml
conda activate agents_unplugged
```

**For CPU-only systems:**
```bash
mamba env create -f environment-cpu.yml
conda activate agents_unplugged
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

## Why Conda/Mamba?

This project uses Conda/Mamba instead of pip because:

1. **GPU Support**: Manages CUDA toolkit and ensures version compatibility
2. **Reproducibility**: Locks system-level dependencies (CUDA, cuDNN)
3. **Binary Packages**: Pre-compiled packages for faster installation
4. **Conflict Resolution**: Better dependency resolution for ML packages
5. **Environment Isolation**: Complete isolation including system libraries

For GPU users, conda is **essential** for proper CUDA management.
