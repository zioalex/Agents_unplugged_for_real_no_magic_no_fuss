# Agents for Real — Separate Files Package (Full)

[![CI Tests](https://github.com/zioalex/Agents_unplugged_for_real_no_magic_no_fuss/actions/workflows/ci.yml/badge.svg)](https://github.com/zioalex/Agents_unplugged_for_real_no_magic_no_fuss/actions/workflows/ci.yml)
[![PR Validation](https://github.com/zioalex/Agents_unplugged_for_real_no_magic_no_fuss/actions/workflows/pr-validation.yml/badge.svg)](https://github.com/zioalex/Agents_unplugged_for_real_no_magic_no_fuss/actions/workflows/pr-validation.yml)
[![Dependency Scan](https://github.com/zioalex/Agents_unplugged_for_real_no_magic_no_fuss/actions/workflows/dependency-scan.yml/badge.svg)](https://github.com/zioalex/Agents_unplugged_for_real_no_magic_no_fuss/actions/workflows/dependency-scan.yml)

Slides, notebooks, code, and assets demonstrating LangChain, LangFlow, LangGraph, and MCP patterns for building production-ready AI agents.

## Structure
- presentation/Agents_for_Real_slides.md — Presentation deck
- notebooks/llm_agents_langchain_langflow_demo.ipynb — Main LangChain walkthrough
- notebooks/mcp_addon_minimal.ipynb — MCP integration demo
- code/mcp_safe_server.py — Safe MCP server implementation
- TROUBLESHOOTING.md — Comprehensive troubleshooting guide

## Environments & Tooling
- environment-minimal-gpu.yml — CUDA 12.1 toolchain + PyTorch GPU base
- environment-minimal-cpu.yml — PyTorch CPU-only base
- environment-full-*.yml — Legacy full-conda environments (historical reference only)
- setup.sh — Unified installer with optional vLLM layer
- requirements-core.txt — Core pip stack (LangChain, data science, utilities)
- requirements-langflow.txt — LangFlow UI layer
- requirements-vllm.txt — Optional vLLM extras
- constraints.txt — Auto-generated snapshot of the active environment (gitignored)

## System Requirements
- RAM: 4 GB minimum (8 GB+ recommended), 16 GB+ for GPU + vLLM
- Disk: ~5 GB CPU install, ~15 GB GPU install (CUDA + models)
- OS: Linux, macOS, or Windows with WSL2
- Python: 3.11 (installed via conda)
- GPU (optional): NVIDIA GPU with CUDA 12.1 drivers for GPU + vLLM workflows

## Prerequisites
Install Miniforge (conda + mamba) and initialize your shell.

Linux/WSL:
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh
```

macOS (Intel or Apple Silicon):
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh
bash Miniforge3-MacOSX-$(uname -m).sh
```

Allow the installer to run `conda init` (or run it manually with `conda init <shell>`) and restart your terminal afterwards.

## Automated Setup (Recommended)
1. Optional preflight:
	 ```bash
	 make doctor
	 ```
2. Run the unified installer. It auto-detects GPUs, creates the correct environment, installs pip layers, regenerates constraints.txt, and runs smoke tests.
	 ```bash
	 bash setup.sh                    # Auto-detect CPU/GPU
	 bash setup.sh --cpu              # Force CPU environment (agents_unplugged-cpu)
	 bash setup.sh --gpu              # Force GPU environment (agents_unplugged-gpu)
	 bash setup.sh --gpu --with-vllm  # GPU + vLLM (agents_unplugged-gpu-vllm)
	 ```
	 Equivalent Makefile targets:
	 ```bash
	 make setup
	 make setup-cpu
	 make setup-gpu
	 make setup-gpu-vllm
	 ```

## Manual Setup (Advanced)
Replicate the script when you need custom tweaks.

```bash
# 1. Create the base environment
mamba env create -f environment-minimal-gpu.yml   # or environment-minimal-cpu.yml
conda activate agents_unplugged-gpu              # or agents_unplugged-cpu

# 2. Snapshot current packages for pip constraints
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

# 3. Install pip layers with the snapshot
pip install --no-cache-dir -c constraints.txt -r requirements-core.txt
pip install --no-cache-dir -c constraints.txt -r requirements-langflow.txt
pip install --no-cache-dir -c constraints.txt -r requirements-vllm.txt   # optional GPU extras

# 4. Refresh constraints and smoke test
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

## Configuration
```bash
cp notebooks/config.json.example notebooks/config.json
# Edit notebooks/config.json with your API keys
```

Example configuration:
```json
{
	"OPENAI_API_BASE": "https://api.openai.com/v1",
	"API_KEY": "your_openai_api_key_here",
	"LANGFLOW_API_KEY": "your_langflow_api_key_here"
}
```

## Running Notebooks
```bash
conda activate agents_unplugged-gpu   # or agents_unplugged-cpu / agents_unplugged-gpu-vllm
make jupyter
```
Open notebooks/llm_agents_langchain_langflow_demo.ipynb, choose your backend (`OPENAI` or `OLLAMA`), and run the cells.

## Optional Services
- LangFlow UI:
	```bash
	conda activate agents_unplugged-gpu
	langflow run --host 127.0.0.1 --port 7860
	```
- vLLM server (GPU only):
	```bash
	conda activate agents_unplugged-gpu-vllm
	vllm serve "swiss-ai/Apertus-8B-Instruct-2509" --gpu-memory-utilization 0.4
	```
- Local LLM with Ollama:
	```bash
	curl -fsSL https://ollama.com/install.sh | sh
	ollama pull llama3.1:8b
	```
- MCP server:
	```bash
	conda activate agents_unplugged-gpu
	python notebooks/safe_mcp_server.py
	```

## Verify Installation
```bash
make test ENV=agents_unplugged-gpu
# or
conda activate agents_unplugged-gpu
python -c "import torch; import langchain; print('✓ Installation successful!')"
```

## Troubleshooting
For comprehensive troubleshooting guidance, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

Quick tips:
- Clean and retry:
	```bash
	make clean
	make setup
	```
- Check GPU visibility:
	```bash
	conda activate agents_unplugged-gpu
	python -c "import torch; print(torch.cuda.is_available())"
	```
- Regenerate constraints after upgrades:
	```bash
	make update ENV=agents_unplugged-gpu
	```

## Makefile Commands
- make help — List available targets
- make doctor — Preflight resource and tool checks
- make setup — Run setup.sh with auto GPU detection
- make setup-cpu — Force CPU environment
- make setup-gpu — Force GPU environment
- make setup-gpu-vllm — GPU environment with vLLM layer
- make jupyter ENV=<env> — Launch Jupyter in the chosen environment
- make test ENV=<env> — Run smoke tests
- make compile-requirements — Regenerate .txt files from .in files with pip-compile
- make update ENV=<env> — Recompile and upgrade pip layers with constraints
- make clean — Remove agents_unplugged-* environments
- make activate — Print activation instructions for your shell

## Hybrid Package Strategy
- Conda supplies the heavy system pieces (CUDA, PyTorch, core Python runtime).
- Pip layers install the fast-moving LangChain, LangFlow, and optional vLLM packages.
- Constraints are regenerated before and after pip installs so follow-up upgrades respect the versions already resolved on your machine.
- constraints.txt is ignored by Git; keep it locally to anchor downstream `pip install -c constraints.txt` commands.

## Reproducible Builds with pip-tools
This project uses pip-tools to ensure reproducible installations:

### File Structure
- `requirements-*.in` — Human-editable, minimal dependencies (what you want)
- `requirements-*.txt` — Machine-generated, fully pinned (what gets installed)
- Both files are committed to Git for reproducibility

### Workflow
**Regular users:** Just run `./setup.sh` — it installs from the pinned `.txt` files

**Developers updating dependencies:**
```bash
# 1. Edit the .in file
vim requirements-core.in

# 2. Regenerate pinned versions
make compile-requirements

# 3. Test the changes
make setup-gpu

# 4. Commit both files
git add requirements-*.in requirements-*.txt
git commit -m "Update dependencies"
```

**Update a single package:**
```bash
# Install pip-tools if needed
pip install pip-tools

# Update just one package
pip-compile --upgrade-package langchain requirements-core.in

# Reinstall
pip install -c constraints.txt -r requirements-core.txt
```

The `compile-requirements` step in setup.sh automatically:
1. Checks for pip-tools (installs if missing)
2. Compiles `.in` → `.txt` with full dependency resolution
3. Applies constraints.txt to respect conda package versions
4. Falls back to existing `.txt` files if `.in` files are missing

## CI/CD and Quality Assurance

This project includes comprehensive GitHub Actions workflows for continuous integration and testing:

### Automated Workflows

1. **CI Tests** (`.github/workflows/ci.yml`)
   - Runs on every push and pull request
   - Tests CPU environment setup and dependency installation
   - Runs smoke tests to verify core imports
   - Validates YAML and requirement files
   - Performs basic security scanning

2. **PR Validation** (`.github/workflows/pr-validation.yml`)
   - Validates pull request format and content
   - Checks for merge conflicts
   - Reports PR size and statistics
   - Flags large files and TODO comments

3. **Dependency Security Scan** (`.github/workflows/dependency-scan.yml`)
   - Runs weekly on Mondays at 9 AM UTC
   - Scans dependencies for known vulnerabilities using pip-audit and safety
   - Checks code for security issues with bandit
   - Reports outdated packages
   - Automatically creates issues for vulnerabilities

### Branch Protection

For production use, enable branch protection on `main`/`master`:

- Require status checks: `test-cpu`, `lint-and-validate`, `validate-pr`
- Require pull request reviews (minimum 1 approval)
- Require conversation resolution before merging
- Prevent force pushes and deletions

See [.github/BRANCH_PROTECTION.md](.github/BRANCH_PROTECTION.md) for detailed setup instructions.

### Local Testing

Before pushing, test locally:
```bash
make doctor                              # Check system prerequisites
make setup-cpu                           # Create and test environment
make test ENV=agents_unplugged-cpu       # Run smoke tests
```

## References

[Python dependency management is a dumpster](https://nielscautaerts.xyz/python-dependency-management-is-a-dumpster-fire.html)
