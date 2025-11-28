.PHONY: help setup setup-fast setup-old setup-gpu setup-cpu clean test jupyter activate

help:
	@echo "Agents Unplugged - Makefile Commands"
	@echo "====================================="
	@echo ""
	@echo "Setup (RECOMMENDED - Fast & Reliable):"
	@echo "  make setup-fast - Fast setup with minimal conda + pip (5-15 min)"
	@echo "  make setup      - Same as setup-fast (default)"
	@echo ""
	@echo "Setup (Old Method - May Hang!):"
	@echo "  make setup-old  - Old setup script (30+ min, may hang)"
	@echo "  make setup-gpu  - Full conda GPU environment (may hang!)"
	@echo "  make setup-cpu  - Full conda CPU environment (may hang!)"
	@echo ""
	@echo "Usage:"
	@echo "  make jupyter    - Start Jupyter notebook server"
	@echo "  make test       - Run basic tests to verify installation"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean      - Remove conda environment"
	@echo "  make update     - Update pip packages"
	@echo ""
	@echo "Note: After 'make setup', activate the environment with:"
	@echo "      conda activate agents_unplugged"

setup: setup-fast

setup-fast:
	@bash setup-fast.sh

setup-old:
	@bash setup.sh

setup-gpu:
	@echo "WARNING: This may consume a lot of memory and hang!"
	@echo "Consider using 'make setup-fast' instead."
	@read -p "Continue anyway? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
		$$CONDA_CMD env create -f environment-gpu.yml; \
	else \
		echo "Cancelled. Use 'make setup-fast' for a better experience."; \
	fi

setup-cpu:
	@echo "WARNING: This may consume a lot of memory and hang!"
	@echo "Consider using 'make setup-fast' instead."
	@read -p "Continue anyway? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
		$$CONDA_CMD env create -f environment-cpu.yml; \
	else \
		echo "Cancelled. Use 'make setup-fast' for a better experience."; \
	fi

clean:
	@echo "Removing conda environment 'agents_unplugged'..."
	@command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
	$$CONDA_CMD env remove -n agents_unplugged -y || true

update:
	@echo "Updating pip packages..."
	@bash -c 'source $$(conda info --base)/etc/profile.d/conda.sh && \
		conda activate agents_unplugged && \
		pip install --upgrade -r requirements-core.txt && \
		pip install --upgrade -r requirements-heavy.txt && \
		echo "✓ Packages updated!"'

jupyter:
	@if conda env list | grep -q "^agents_unplugged "; then \
		echo "Starting Jupyter notebook..."; \
		echo "Note: Make sure to run 'conda activate agents_unplugged' first!"; \
		jupyter notebook; \
	else \
		echo "Error: Environment not found. Run 'make setup' first."; \
		exit 1; \
	fi

test:
	@echo "Testing installation..."
	@bash -c 'source $$(conda info --base)/etc/profile.d/conda.sh && \
		conda activate agents_unplugged && \
		python -c "import torch; import langchain; import pandas; import matplotlib; \
		print(\"✓ Core packages installed\"); \
		print(f\"  Python: {__import__(\"sys\").version}\"); \
		print(f\"  PyTorch: {torch.__version__}\"); \
		print(f\"  LangChain: {langchain.__version__}\"); \
		print(f\"  CUDA available: {torch.cuda.is_available()}\")"'

activate:
	@echo "To activate the environment, run:"
	@echo "  conda activate agents_unplugged"
	@echo ""
	@echo "Note: 'make activate' cannot activate in the current shell."
	@echo "You must run the command above directly."
