# Installation Guide

## Overview

This project now uses **Conda/Mamba** for dependency management to ensure reproducible installations, especially for GPU environments.

## Why Conda/Mamba?

### Key Advantages

1. **GPU/CUDA Management**: Automatically installs and manages CUDA toolkit versions
2. **Binary Compatibility**: Ensures PyTorch, vLLM, and CUDA versions match correctly
3. **Reproducibility**: Locks both Python and system-level dependencies
4. **Faster Installation**: Pre-compiled binary packages (no compilation needed)
5. **Better Conflict Resolution**: Handles complex ML dependency trees

### Comparison with Pip

| Feature | Conda/Mamba | Pip |
|---------|-------------|-----|
| CUDA Management | ✅ Automatic | ❌ Manual (system-wide only) |
| Binary Packages | ✅ Yes | ⚠️ Limited |
| System Dependencies | ✅ Yes | ❌ No |
| Reproducibility | ✅ Full stack | ⚠️ Python only |
| Speed | ✅ Fast (mamba) | ⚠️ Slower |
| GPU Isolation | ✅ Per-env CUDA | ❌ Single system CUDA |

## Installation Methods

### Method 1: Automated Setup (Recommended)

```bash
# Clone repository
git clone <repo-url>
cd Agents_unplugged_for_real_no_magic_no_fuss

# Run automated setup
bash setup.sh
```

The script will:
- Detect if you have a GPU
- Install the appropriate environment (GPU with CUDA or CPU-only)
- Verify the installation

### Method 2: Makefile

```bash
make setup          # Auto-detect GPU/CPU
make setup-gpu      # Force GPU environment
make setup-cpu      # Force CPU-only environment
```

### Method 3: Manual Installation

**Step 1: Install Miniforge**

```bash
# Linux/WSL
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh

# macOS
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh
bash Miniforge3-MacOSX-$(uname -m).sh
```

Restart your terminal after installation.

**Step 2: Create Environment**

For GPU systems:
```bash
mamba env create -f environment-gpu.yml
```

For CPU systems:
```bash
mamba env create -f environment-cpu.yml
```

**Step 3: Activate**

```bash
conda activate agents_unplugged
```

## Environment Files

### `environment.yml`
- Auto-detects GPU/CPU
- General purpose
- Recommended for most users

### `environment-gpu.yml`
- Includes CUDA 12.1 toolkit
- PyTorch with GPU support
- vLLM for high-performance inference
- Use this if you have an NVIDIA GPU

### `environment-cpu.yml`
- CPU-only PyTorch (smaller download)
- No CUDA toolkit
- vLLM not included
- Use this for machines without GPU

## Verifying Installation

### Check Python and Core Packages

```bash
conda activate agents_unplugged
make test
```

Or manually:

```bash
python -c "import torch; import langchain; print('✓ Installation successful!')"
```

### Check GPU/CUDA

```bash
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
python -c "import torch; print(f'CUDA version: {torch.version.cuda}')"
```

### Check vLLM (GPU only)

```bash
python -c "import vllm; print(f'vLLM version: {vllm.__version__}')"
```

## Troubleshooting

### CUDA Not Available

**Symptom**: `torch.cuda.is_available()` returns `False`

**Solutions**:
1. Check GPU drivers: `nvidia-smi`
2. Reinstall GPU environment: `make clean && make setup-gpu`
3. Check CUDA compatibility: Ensure your GPU supports CUDA 12.1

### Import Errors

**Symptom**: `ModuleNotFoundError` when importing packages

**Solutions**:
1. Ensure environment is activated: `conda activate agents_unplugged`
2. Reinstall environment: `make clean && make setup`

### Package Conflicts

**Symptom**: Conda reports conflicts during installation

**Solutions**:
1. Update conda/mamba: `mamba update -n base mamba`
2. Use specific environment file: `make setup-gpu` or `make setup-cpu`
3. Report issue with your OS and CUDA version

### Slow Installation

**Solutions**:
1. Use mamba instead of conda (10-100x faster)
2. Reduce number of channels in environment.yml
3. Use libmamba solver: `conda install -n base conda-libmamba-solver`

## Updating

### Update All Packages

```bash
make update
```

Or manually:

```bash
conda activate agents_unplugged
mamba update --all
```

### Update Single Package

```bash
conda activate agents_unplugged
mamba update <package-name>
```

## Maintenance

### List Installed Packages

```bash
conda activate agents_unplugged
conda list
```

### Export Current Environment

```bash
conda activate agents_unplugged
conda env export > environment-lock.yml
```

### Remove Environment

```bash
make clean
# or
conda env remove -n agents_unplugged
```

## Advanced Usage

### Creating Environment in Custom Location

```bash
mamba env create -f environment-gpu.yml -p ./myenv
conda activate ./myenv
```

### Using with Docker

```dockerfile
FROM continuumio/miniconda3:latest

WORKDIR /app
COPY environment-gpu.yml .

RUN conda install -n base -c conda-forge mamba && \
    mamba env create -f environment-gpu.yml && \
    conda clean -afy

SHELL ["conda", "run", "-n", "agents_unplugged", "/bin/bash", "-c"]
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root"]
```

### Multiple CUDA Versions

You can have multiple environments with different CUDA versions:

```bash
# CUDA 11.8 environment
mamba create -n agents_cuda118 python=3.11 pytorch pytorch-cuda=11.8 -c pytorch -c nvidia

# CUDA 12.1 environment
mamba create -n agents_cuda121 python=3.11 pytorch pytorch-cuda=12.1 -c pytorch -c nvidia
```

## Migration from Pip

If you previously used `requirements.txt`:

1. Remove old virtual environment: `rm -rf .venv/`
2. Install conda/mamba (see above)
3. Run setup: `bash setup.sh`
4. Activate: `conda activate agents_unplugged`

Your old `requirements.txt` is kept for reference but is no longer used.

## Resources

- [Conda Documentation](https://docs.conda.io/)
- [Mamba Documentation](https://mamba.readthedocs.io/)
- [PyTorch Installation Guide](https://pytorch.org/get-started/locally/)
- [vLLM Documentation](https://vllm.readthedocs.io/)
