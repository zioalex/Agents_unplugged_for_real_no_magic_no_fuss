# Troubleshooting Guide

Common issues and solutions for Agents Unplugged setup.

## Installation Issues

### Conda Hangs During Setup

**Symptom:** Running `bash setup.sh` or `make setup-old` hangs indefinitely, consuming 10+ GB RAM.

**Cause:** Conda's dependency resolver struggles with 500+ dependencies from langflow.

**Solution:**
```bash
# Use the fast setup instead (minimal conda + pip)
bash setup-fast.sh
# Or
make setup-fast
```

**Why it works:** Fast setup installs only essential packages via conda (CUDA, PyTorch, Jupyter), then uses pip for the rest.

---

### "mamba: command not found"

**Symptom:** Error message when running setup scripts.

**Solution:**
```bash
# Install Miniforge (includes mamba)
# Linux/WSL:
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh

# macOS:
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh
bash Miniforge3-MacOSX-$(uname -m).sh

# Restart terminal after installation
```

---

### "conda: command not found" (after installation)

**Symptom:** Conda installed but command not found.

**Solution:**
```bash
# Restart your terminal
# Or manually activate conda:
source ~/miniforge3/bin/activate  # Adjust path if different
# Or
source ~/.bashrc
```

---

## GPU/CUDA Issues

### CUDA Not Available

**Symptom:** `torch.cuda.is_available()` returns `False`

**Check GPU Drivers:**
```bash
nvidia-smi
```

**If nvidia-smi works:**
```bash
# Reinstall with GPU environment
conda deactivate
make clean
make setup-fast  # Will auto-detect GPU
```

**If nvidia-smi doesn't work:**
- Install/update NVIDIA drivers
- Restart system
- Run setup again

---

### CUDA Version Mismatch

**Symptom:** Error like `RuntimeError: CUDA error: no kernel image is available`

**Solution:**
```bash
# Check your CUDA version
nvidia-smi  # Look at top right for CUDA version

# If you need different CUDA version, edit environment-minimal-gpu.yml:
# Change line: - pytorch::pytorch-cuda=12.1
# To match your CUDA version (e.g., 11.8, 12.1, etc.)

# Then reinstall
make clean
make setup-fast
```

---

### vLLM Import Error

**Symptom:** `ImportError: cannot import name 'vllm'`

**Cause:** vLLM requires GPU and CUDA.

**Solution for GPU users:**
```bash
conda activate agents_unplugged
pip install vllm==0.6.5
```

**Solution for CPU users:**
vLLM doesn't work on CPU. Use Ollama instead:
```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.1:8b
# Set BACKEND = "OLLAMA" in notebook
```

---

## Package Issues

### ModuleNotFoundError

**Symptom:** `ModuleNotFoundError: No module named 'X'`

**Solution:**
```bash
# Ensure environment is activated
conda activate agents_unplugged

# If still not found, reinstall packages
pip install -r requirements-core.txt
pip install -r requirements-heavy.txt
```

---

### LangFlow Import Error

**Symptom:** `ImportError: No module named 'langflow'`

**Solution:**
```bash
conda activate agents_unplugged
pip install langflow>=1.1
```

---

### Package Conflict Errors

**Symptom:** Pip reports dependency conflicts during installation.

**Solution:**
```bash
# Clean reinstall
make clean
make setup-fast
```

---

## Jupyter Issues

### Kernel Not Found

**Symptom:** Jupyter can't find the `agents_unplugged` kernel.

**Solution:**
```bash
conda activate agents_unplugged
python -m ipykernel install --user --name agents_unplugged --display-name "Python (agents_unplugged)"
```

---

### Jupyter Won't Start

**Symptom:** `make jupyter` fails or Jupyter won't start.

**Solution:**
```bash
# Ensure environment is activated
conda activate agents_unplugged

# Reinstall Jupyter
pip install --upgrade jupyter notebook ipykernel

# Start manually
jupyter notebook
```

---

## Memory Issues

### Out of Memory During Installation

**Symptom:** System freezes or installation killed due to OOM.

**Cause:** Using full conda environment files (`environment-gpu.yml` or `environment-cpu.yml`).

**Solution:**
```bash
# Use minimal conda + pip approach
make clean
bash setup-fast.sh  # Uses much less memory
```

---

### Out of Memory Running Notebooks

**Symptom:** Kernel dies or system hangs when running notebooks.

**Solution for vLLM:**
```bash
# Use smaller model or reduce GPU memory usage
vllm serve "model-name" --gpu-memory-utilization 0.3  # Reduce from 0.4
```

**Solution for LangFlow:**
```bash
# Don't run LangFlow and notebooks simultaneously
# Close LangFlow server when not using it
```

---

## Configuration Issues

### API Keys Not Working

**Symptom:** OpenAI or LangFlow API errors.

**Check config file:**
```bash
# Ensure config exists
ls notebooks/config.json

# If not, create from example
cp notebooks/config.json.example notebooks/config.json
# Edit with your keys
nano notebooks/config.json
```

**Verify format:**
```json
{
  "OPENAI_API_BASE": "https://api.openai.com/v1",
  "API_KEY": "sk-...",
  "LANGFLOW_API_KEY": "..."
}
```

---

### Ollama Connection Error

**Symptom:** Can't connect to Ollama in notebook.

**Solution:**
```bash
# Check Ollama is running
ollama list

# If not installed
curl -fsSL https://ollama.com/install.sh | sh

# Pull a model
ollama pull llama3.1:8b

# In notebook, set BACKEND = "OLLAMA"
```

---

## Performance Issues

### Installation Too Slow

**Symptom:** Setup taking 30+ minutes.

**Solution:**
```bash
# If using old setup.sh, switch to fast setup
# Ctrl+C to cancel current installation
make clean
bash setup-fast.sh  # 5-15 minutes instead
```

---

### Conda Resolver Taking Forever

**Symptom:** Conda stuck on "Solving environment".

**Solution:**
```bash
# Ctrl+C to cancel
# Use fast setup instead
bash setup-fast.sh
```

---

## Platform-Specific Issues

### macOS: "Command Line Tools Required"

**Solution:**
```bash
xcode-select --install
```

---

### Windows/WSL: Line Ending Issues

**Symptom:** `setup.sh: bad interpreter: /bin/bash^M`

**Solution:**
```bash
# Convert line endings
dos2unix setup-fast.sh
# Or
sed -i 's/\r$//' setup-fast.sh
```

---

## Still Having Issues?

1. **Check existing issues:** Look at GitHub issues for similar problems
2. **Provide details:** When reporting, include:
   - OS and version
   - Python version: `python --version`
   - Conda version: `conda --version`
   - GPU: `nvidia-smi` output (if applicable)
   - Full error message
   - Setup method used (fast vs old)

3. **Quick diagnostics:**
```bash
# Run this and share output
conda activate agents_unplugged
python -c "import sys, torch, langchain; print(f'Python: {sys.version}'); print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}'); print(f'LangChain: {langchain.__version__}')"
```
