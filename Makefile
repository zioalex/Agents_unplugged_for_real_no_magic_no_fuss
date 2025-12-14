# Export presentation to HTML via Marp
.PHONY: presentation
presentation:
	@echo "Rendering presentation/Agents_for_Real_slides.md to HTML..."
	npx @marp-team/marp-cli presentation/Agents_for_Real_slides.md --html --allow-local-files -o presentation/Agents_for_Real_slides.html

# Install Marp CLI globally if not present
.PHONY: presentation-install
presentation-install:
	@echo "Checking Marp CLI availability..."
	@command -v marp >/dev/null 2>&1 && echo "Marp CLI is installed." || (echo "Installing Marp CLI globally..." && npm install -g @marp-team/marp-cli)
	@echo "Done. You can now run 'make presentation'"
.PHONY: help setup setup-cpu setup-gpu setup-gpu-vllm clean test jupyter activate doctor update compile-requirements

help:
	@echo "Agents Unplugged - Makefile Commands"
	@echo "====================================="
	@echo ""
	@echo "Setup (Unified script):"
	@echo "  make doctor         - Check system requirements before setup"
	@echo "  make setup          - Auto-detect GPU and install"
	@echo "  make setup-cpu      - Force CPU-only install"
	@echo "  make setup-gpu      - Force GPU install"
	@echo "  make setup-gpu-vllm - GPU install with optional vLLM extras"
	@echo ""
	@echo "Usage:"
	@echo "  make jupyter ENV=<env> - Start Jupyter (default ENV=agents_unplugged-gpu)"
	@echo "  make test ENV=<env>    - Run smoke tests inside an environment"
	@echo ""
	@echo "Maintenance:"
	@echo "  make compile-requirements - Regenerate .txt from .in files with pip-compile"
	@echo "  make update ENV=<env>     - Recompile and upgrade packages"
	@echo "  make clean                - Remove agents_unplugged-* environments"

doctor:
	@echo "================================================"
	@echo "  System Integrity Check"
	@echo "================================================"
	@echo ""
	@echo "Checking for conda or mamba..."
	@if command -v mamba >/dev/null 2>&1; then \
		echo "✓ mamba found"; \
	elif command -v conda >/dev/null 2>&1; then \
		echo "✓ conda found"; \
	else \
		echo "✗ conda or mamba not found. Please install and configure it in your PATH."; \
		exit 1; \
	fi
	@echo ""
	@echo "Checking disk space..."
	@if [ $$(df -k . | awk 'NR==2 {print $$4}') -lt 10000000 ]; then \
		echo "  ⚠ Less than 10GB disk space. May not be enough for GPU setup."; \
	else \
		echo "  ✓ Sufficient disk space"; \
	fi
	@echo ""
	@echo "Checking for GPU..."
	@if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then \
		echo "✓ GPU detected:"; \
		nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | sed 's/^/  /'; \
	else \
		echo "✗ No GPU detected (will install CPU-only environment)"; \
	fi
	@echo ""
	@echo "Checking for existing environment..."
	@if command -v conda >/dev/null 2>&1 && conda env list | awk '{print $$1}' | grep -q '^agents_unplugged-'; then \
		echo "⚠ One or more agents_unplugged-* environments already exist"; \
		echo "  Use 'make clean' to remove them before reinstalling"; \
		conda env list | awk '/agents_unplugged-/{print "    • " $$1}'; \
	else \
		echo "✓ No existing environment found"; \
	fi
	@echo ""
	@echo "================================================"
	@echo "  System check complete!"
	@echo "================================================"
	@echo ""
	@echo "Ready to install! Run: make setup"

setup:
	@bash setup.sh

setup-cpu:
	@bash setup.sh --cpu

setup-gpu:
	@bash setup.sh --gpu

setup-gpu-vllm:
	@bash setup.sh --gpu --with-vllm

clean:
	@echo "Removing conda environments matching agents_unplugged-* ..."
	@command -v mamba >/dev/null 2>&1 && CONDA_CMD=mamba || CONDA_CMD=conda; \
	FOUND=0; \
	for NAME in $$($$CONDA_CMD env list | awk '/agents_unplugged-/{print $$1}'); do \
		FOUND=1; \
		echo "  • Removing $$NAME"; \
		$$CONDA_CMD env remove -n $$NAME -y; \
	done; \
	if [ $$FOUND -eq 0 ]; then \
		echo "Nothing to clean."; \
	fi

ENV ?= agents_unplugged-gpu

update:
	@echo "Updating pip packages inside $(ENV)..."
	@bash -c 'source $$(conda info --base)/etc/profile.d/conda.sh && \
		conda activate $(ENV) && \
		CONSTRAINTS_ARG=""; \
		if [ -f $$PWD/constraints.txt ]; then \
			CONSTRAINTS_ARG="-c $$PWD/constraints.txt"; \
		fi; \
		if command -v pip-compile >/dev/null 2>&1; then \
			echo "Recompiling requirements with pip-tools..."; \
			pip-compile $$CONSTRAINTS_ARG requirements-core.in -o requirements-core.txt; \
			pip-compile $$CONSTRAINTS_ARG requirements-langflow.in -o requirements-langflow.txt; \
			if [ -f requirements-vllm.in ]; then \
				pip-compile $$CONSTRAINTS_ARG requirements-vllm.in -o requirements-vllm.txt; \
			fi; \
		fi && \
		pip install --upgrade $$CONSTRAINTS_ARG -r requirements-core.txt && \
		pip install --upgrade $$CONSTRAINTS_ARG -r requirements-langflow.txt && \
		if [ -f $$PWD/requirements-vllm.txt ] && grep -q "vllm" requirements-vllm.txt; then \
			pip install --upgrade $$CONSTRAINTS_ARG -r requirements-vllm.txt || true; \
		fi && \
		echo "✓ Packages updated!"'

jupyter:
	@if conda env list | awk '{print $$1}' | grep -q '^$(ENV)$$'; then \
		echo "Starting Jupyter notebook using environment $(ENV)..."; \
		echo "Run: conda activate $(ENV)"; \
		jupyter notebook; \
	else \
		echo "Error: Environment $(ENV) not found. Run 'make setup' first or set ENV=<name>."; \
		exit 1; \
	fi

test:
	@if conda env list | awk '{print $$1}' | grep -q '^$(ENV)$$'; then \
		echo "Running smoke test inside $(ENV)..."; \
		ENV_NAME=$(ENV) conda run -n $(ENV) python code/smoke_test.py; \
	else \
		echo "Error: Environment $(ENV) not found. Run 'make setup' first or set ENV=<name>."; \
		exit 1; \
	fi

activate:
	@echo "To activate the environment, run:"
	@echo "  conda activate <agents_unplugged-{cpu|gpu|-gpu-vllm}>"
	@echo ""
	@echo "Note: 'make activate' cannot activate in the current shell."
	@echo "You must run the command above directly."

compile-requirements:
	@echo "Compiling requirements from .in files..."
	@if ! command -v pip-compile >/dev/null 2>&1; then \
		echo "Installing pip-tools..."; \
		pip install pip-tools; \
	fi
	@if [ -f constraints.txt ]; then \
		CONSTRAINTS="-c constraints.txt"; \
	else \
		CONSTRAINTS=""; \
	fi; \
	pip-compile $$CONSTRAINTS requirements-core.in -o requirements-core.txt && \
	pip-compile $$CONSTRAINTS requirements-langflow.in -o requirements-langflow.txt && \
	pip-compile $$CONSTRAINTS requirements-vllm.in -o requirements-vllm.txt && \
	echo "✓ All requirements compiled!"
