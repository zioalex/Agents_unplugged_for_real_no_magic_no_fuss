.PHONY: help setup setup-gpu setup-cpu clean test jupyter activate

help:
	@echo "Agents Unplugged - Makefile Commands"
	@echo "====================================="
	@echo ""
	@echo "Setup:"
	@echo "  make setup      - Auto-detect GPU and install appropriate environment"
	@echo "  make setup-gpu  - Install GPU environment (with CUDA)"
	@echo "  make setup-cpu  - Install CPU-only environment (lighter)"
	@echo ""
	@echo "Usage:"
	@echo "  make jupyter    - Start Jupyter notebook server"
	@echo "  make test       - Run basic tests to verify installation"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean      - Remove conda environment"
	@echo "  make update     - Update environment with latest packages"
	@echo ""
	@echo "Note: After 'make setup', activate the environment with:"
	@echo "      conda activate agents_unplugged"

setup:
	@bash setup.sh

setup-gpu:
	@command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
	$$CONDA_CMD env create -f environment-gpu.yml

setup-cpu:
	@command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
	$$CONDA_CMD env create -f environment-cpu.yml

clean:
	@echo "Removing conda environment 'agents_unplugged'..."
	@command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
	$$CONDA_CMD env remove -n agents_unplugged -y || true

update:
	@echo "Updating environment..."
	@command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
	if nvidia-smi >/dev/null 2>&1; then \
		$$CONDA_CMD env update -n agents_unplugged -f environment-gpu.yml --prune; \
	else \
		$$CONDA_CMD env update -n agents_unplugged -f environment-cpu.yml --prune; \
	fi

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
