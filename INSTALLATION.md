git clone <repo-url>
-# Installation Guide

## Overview

The project ships with a unified `setup.sh` that provisions a minimal conda base and layered pip installs. GPU support and optional vLLM extras are available via flags.

## Prerequisites
- Miniforge (includes conda + mamba)
- Restart your shell after running `conda init`
- NVIDIA GPU with CUDA 12.1 drivers for GPU + vLLM workflows

Install Miniforge:

Linux/WSL:
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh
```

macOS:
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh
bash Miniforge3-MacOSX-$(uname -m).sh
```

## Automated Setup (Recommended)
```bash
make doctor        # Optional preflight checks
bash setup.sh      # Auto-detect CPU/GPU

# Variants
bash setup.sh --cpu
bash setup.sh --gpu
bash setup.sh --gpu --with-vllm
```

Equivalent Makefile targets:
```bash
make setup
make setup-cpu
make setup-gpu
make setup-gpu-vllm
```

`setup.sh` creates environments named:
- agents_unplugged-cpu
- agents_unplugged-gpu
- agents_unplugged-gpu-vllm (when `--with-vllm` is used)

The script then:
1. Generates a `constraints.txt` snapshot from the fresh conda environment
2. Installs layered pip requirements with those constraints
3. Refreshes `constraints.txt` after pip installs
4. Runs smoke tests (torch, langchain, langflow, and vllm when requested)

## Manual Setup (Advanced)
```bash
# Create the base environment
mamba env create -f environment-minimal-gpu.yml   # or environment-minimal-cpu.yml
conda activate agents_unplugged-gpu              # or agents_unplugged-cpu

# Snapshot existing packages for pip constraints
python - <<'PY'
from importlib import metadata
from pathlib import Path
records = {}
for dist in metadata.distributions():
        name = dist.metadata.get('Name')
        version = dist.version
        if not name or not version:
                continue
        normalized = name.strip().replace(' ', '-')
        records[normalized.lower()] = (normalized, version)
constraints = Path('constraints.txt')
with constraints.open('w', encoding='utf-8') as handle:
        handle.write('# Auto-generated constraints file - DO NOT COMMIT\n')
        for _, (name, version) in sorted(records.items()):
                handle.write(f"{name}=={version}\n")
PY

# Install pip layers
pip install --no-cache-dir -c constraints.txt -r requirements-core.txt
pip install --no-cache-dir -c constraints.txt -r requirements-langflow.txt
pip install --no-cache-dir -c constraints.txt -r requirements-vllm.txt   # optional

# Refresh constraints and verify
python - <<'PY'
from importlib import metadata
from pathlib import Path
records = {}
for dist in metadata.distributions():
        name = dist.metadata.get('Name')
        version = dist.version
        if not name or not version:
                continue
        normalized = name.strip().replace(' ', '-')
        records[normalized.lower()] = (normalized, version)
constraints = Path('constraints.txt')
with constraints.open('w', encoding='utf-8') as handle:
        handle.write('# Auto-generated constraints file - DO NOT COMMIT\n')
        for _, (name, version) in sorted(records.items()):
                handle.write(f"{name}=={version}\n")
PY
python -c "import torch, langchain, langflow"
```

## Environment Files
- environment-minimal-gpu.yml — CUDA 12.1, PyTorch GPU, Jupyter basics
- environment-minimal-cpu.yml — PyTorch CPU, Jupyter basics
- environment-full-*.yml — Legacy full-conda environments (use only if you need historical parity)

## Verification
```bash
make test ENV=agents_unplugged-gpu
# or
conda activate agents_unplugged-gpu
python -c "import torch; import langchain; print('✓ Installation successful!')"
```

## Troubleshooting
- Install/enable mamba solver:
    ```bash
    conda install -n base mamba -c conda-forge
    conda install -n base conda-libmamba-solver
    conda config --set solver libmamba
    ```
- Remove existing environments before reinstalling:
    ```bash
    make clean
    ```
- Check GPU visibility:
    ```bash
    conda activate agents_unplugged-gpu
    python -c "import torch; print(torch.cuda.is_available())"
    ```
- Recreate constraints after upgrades:
    ```bash
    make update ENV=agents_unplugged-gpu
    ```

If the solver hangs, clear caches and retry:
```bash
conda clean --all -y
make clean
make setup
```

## Maintenance
- List environments: `conda env list | grep agents_unplugged`
- Remove environment: `make clean`
- Upgrade pip layers: `make update ENV=<env>`
- Launch Jupyter: `make jupyter ENV=<env>`

## Resources
- [Conda Documentation](https://docs.conda.io/)
- [Mamba Documentation](https://mamba.readthedocs.io/)
- [PyTorch Installation Guide](https://pytorch.org/get-started/locally/)
- [vLLM Documentation](https://vllm.readthedocs.io/)
