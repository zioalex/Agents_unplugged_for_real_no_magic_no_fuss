#!/bin/bash
#
# Fast Setup Script for Agents Unplugged
# Uses minimal conda + staged pip installation to avoid memory issues
#

set -e  # Exit on error

echo "================================================"
echo "  Agents Unplugged - Fast Setup"
echo "  (Minimal Conda + Staged Pip Installation)"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect GPU
detect_gpu() {
    if command_exists nvidia-smi; then
        if nvidia-smi &>/dev/null; then
            echo -e "${GREEN}✓ GPU detected${NC}"
            return 0
        fi
    fi
    echo -e "${YELLOW}✗ No GPU detected (will use CPU-only mode)${NC}"
    return 1
}

# Check for conda/mamba
if ! command_exists conda && ! command_exists mamba; then
    echo -e "${RED}ERROR: Neither conda nor mamba found!${NC}"
    echo ""
    echo "Please install Miniforge (includes mamba and conda):"
    echo ""
    echo "  Linux/WSL:"
    echo "    wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
    echo "    bash Miniforge3-Linux-x86_64.sh"
    echo ""
    echo "After installation, restart your terminal and run this script again."
    exit 1
fi

# Prefer mamba over conda (much faster)
if command_exists mamba; then
    CONDA_CMD="mamba"
    echo -e "${GREEN}Using: mamba (fast!)${NC}"
else
    CONDA_CMD="conda"
    echo -e "${YELLOW}Using: conda (consider installing mamba for faster performance)${NC}"
fi

echo ""
echo "Step 1: Detecting environment..."
echo "--------------------------------"

# Detect GPU and select environment file
if detect_gpu; then
    ENV_FILE="environment-minimal-gpu.yml"
    INSTALL_VLLM=true
    echo -e "${GREEN}Selected: Minimal GPU environment (with CUDA support)${NC}"
else
    ENV_FILE="environment-minimal-cpu.yml"
    INSTALL_VLLM=false
    echo -e "${YELLOW}Selected: Minimal CPU-only environment${NC}"
fi

echo ""
echo "Step 2: Creating minimal conda environment..."
echo "----------------------------------------------"
echo "This installs ONLY Python, PyTorch, CUDA (if GPU), and Jupyter"
echo "All other packages will be installed via pip (much faster!)"
echo ""

# Check if environment already exists
if $CONDA_CMD env list | grep -q "^agents_unplugged "; then
    echo -e "${YELLOW}⚠ Environment 'agents_unplugged' already exists!${NC}"
    read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        $CONDA_CMD env remove -n agents_unplugged -y
    else
        echo -e "${YELLOW}Skipping conda environment creation...${NC}"
        SKIP_CONDA=true
    fi
fi

# Create new environment (takes 2-5 minutes)
if [ "$SKIP_CONDA" != true ]; then
    echo "Creating minimal conda environment (this will be quick!)..."
    $CONDA_CMD env create -f "$ENV_FILE"
    echo -e "${GREEN}✓ Conda environment created!${NC}"
fi

echo ""
echo "Step 3: Installing Python packages via pip..."
echo "----------------------------------------------"

# Activate environment
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate agents_unplugged

echo ""
echo "3a. Installing core packages..."
echo "   (LangChain, MCP, matplotlib, scipy, etc.)"
pip install --no-cache-dir -r requirements-core.txt
echo -e "${GREEN}✓ Core packages installed!${NC}"

echo ""
echo "3b. Installing heavy packages (langflow)..."
echo "   (This has 500+ dependencies, may take 5-10 minutes)"
echo "   Tip: Go grab a coffee ☕"
pip install --no-cache-dir -r requirements-heavy.txt
echo -e "${GREEN}✓ Heavy packages installed!${NC}"

if [ "$INSTALL_VLLM" = true ]; then
    echo ""
    echo "3c. Installing vLLM (GPU inference engine)..."
    pip install --no-cache-dir -r requirements-vllm.txt
    echo -e "${GREEN}✓ vLLM installed!${NC}"
fi

echo ""
echo "Step 4: Verifying installation..."
echo "----------------------------------"

# Verify Python
echo -n "Python version: "
python --version

# Verify key packages
echo -n "PyTorch version: "
python -c "import torch; print(torch.__version__)"

if [ "$INSTALL_VLLM" = true ]; then
    echo -n "CUDA available: "
    python -c "import torch; print('Yes ✓' if torch.cuda.is_available() else 'No ✗ (Check GPU drivers!)')"

    echo -n "CUDA version: "
    python -c "import torch; print(torch.version.cuda if torch.cuda.is_available() else 'N/A')"

    echo -n "vLLM version: "
    python -c "import vllm; print(vllm.__version__)" 2>/dev/null || echo "Not installed"
fi

echo -n "LangChain version: "
python -c "import langchain; print(langchain.__version__)"

echo -n "LangFlow installed: "
python -c "import langflow; print('Yes ✓')" 2>/dev/null || echo "No ✗"

echo ""
echo "================================================"
echo -e "  ${GREEN}✓ Setup Complete!${NC}"
echo "================================================"
echo ""
echo "Installation time comparison:"
echo "  Old approach (conda for everything): 30-60+ minutes or HANGS"
echo "  New approach (minimal conda + pip):  5-15 minutes ✓"
echo ""
echo "Next steps:"
echo ""
echo "1. Activate the environment:"
echo "   conda activate agents_unplugged"
echo ""
echo "2. Copy and configure your API keys:"
echo "   cp notebooks/config.json.example notebooks/config.json"
echo "   # Edit notebooks/config.json with your API keys"
echo ""
echo "3. Start Jupyter:"
echo "   jupyter notebook"
echo ""
echo "4. Open and run:"
echo "   notebooks/llm_agents_langchain_langflow_demo.ipynb"
echo ""
if [ "$INSTALL_VLLM" != true ]; then
    echo -e "${YELLOW}Note: vLLM not installed (no GPU detected)${NC}"
    echo "If you later get a GPU, run: pip install vllm==0.6.5"
    echo ""
fi
echo "Optional - Install Ollama for local LLM:"
echo "   curl -fsSL https://ollama.com/install.sh | sh"
echo "   ollama pull llama3.1:8b"
echo ""
