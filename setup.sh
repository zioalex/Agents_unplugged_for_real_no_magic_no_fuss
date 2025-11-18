#!/bin/bash
#
# Automated setup script for Agents Unplugged
# Detects GPU availability and installs appropriate environment
#

set -e  # Exit on error

echo "================================================"
echo "  Agents Unplugged - Automated Setup"
echo "================================================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect GPU
detect_gpu() {
    if command_exists nvidia-smi; then
        if nvidia-smi &>/dev/null; then
            echo "✓ GPU detected"
            return 0
        fi
    fi
    echo "✗ No GPU detected (will use CPU-only mode)"
    return 1
}

# Check for conda/mamba
if ! command_exists conda && ! command_exists mamba; then
    echo "ERROR: Neither conda nor mamba found!"
    echo ""
    echo "Please install Miniforge (includes mamba and conda):"
    echo ""
    echo "  Linux/WSL:"
    echo "    wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
    echo "    bash Miniforge3-Linux-x86_64.sh"
    echo ""
    echo "  macOS:"
    echo "    wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh"
    echo "    bash Miniforge3-MacOSX-$(uname -m).sh"
    echo ""
    echo "After installation, restart your terminal and run this script again."
    exit 1
fi

# Prefer mamba over conda (much faster)
if command_exists mamba; then
    CONDA_CMD="mamba"
    echo "Using: mamba (fast!)"
else
    CONDA_CMD="conda"
    echo "Using: conda"
fi

echo ""
echo "Step 1: Detecting environment..."
echo "--------------------------------"

# Detect GPU and select environment file
if detect_gpu; then
    ENV_FILE="environment-gpu.yml"
    echo "Selected: GPU environment (with CUDA support)"
else
    ENV_FILE="environment-cpu.yml"
    echo "Selected: CPU-only environment (lighter weight)"
fi

echo ""
echo "Step 2: Creating conda environment..."
echo "--------------------------------------"

# Check if environment already exists
if $CONDA_CMD env list | grep -q "^agents_unplugged "; then
    echo "⚠ Environment 'agents_unplugged' already exists!"
    read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        $CONDA_CMD env remove -n agents_unplugged -y
    else
        echo "Updating existing environment instead..."
        $CONDA_CMD env update -n agents_unplugged -f "$ENV_FILE" --prune
        echo ""
        echo "✓ Environment updated successfully!"
        echo ""
        echo "To activate:"
        echo "  conda activate agents_unplugged"
        exit 0
    fi
fi

# Create new environment
echo "This may take 5-15 minutes depending on your internet connection..."
$CONDA_CMD env create -f "$ENV_FILE"

echo ""
echo "Step 3: Verifying installation..."
echo "----------------------------------"

# Activate and verify
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate agents_unplugged

# Verify Python
echo -n "Python version: "
python --version

# Verify key packages
echo -n "PyTorch version: "
python -c "import torch; print(torch.__version__)"

if detect_gpu; then
    echo -n "CUDA available: "
    python -c "import torch; print('Yes' if torch.cuda.is_available() else 'No (Check GPU drivers!)')"

    echo -n "CUDA version: "
    python -c "import torch; print(torch.version.cuda if torch.cuda.is_available() else 'N/A')"
fi

echo -n "LangChain version: "
python -c "import langchain; print(langchain.__version__)" 2>/dev/null || echo "Not installed (will install with langflow)"

echo ""
echo "================================================"
echo "  ✓ Setup Complete!"
echo "================================================"
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
echo "Optional - Install Ollama for local LLM:"
echo "   curl -fsSL https://ollama.com/install.sh | sh"
echo "   ollama pull llama3.1:8b"
echo ""
