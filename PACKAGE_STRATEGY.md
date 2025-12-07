# Package Installation Strategy

## Goals
- Keep conda environments small and deterministic.
- Layer pip installs with constraints to avoid clobbering conda packages.
- Make vLLM optional while keeping GPU stacks manageable.

## Layers

| Layer | Source | Purpose |
|-------|--------|---------|
| Base environment | conda (mamba) | Python 3.11, PyTorch (CPU or CUDA 12.1), Jupyter basics |
| `requirements-core.txt` | pip | LangChain suite, data science utilities, supporting libs |
| `requirements-langflow.txt` | pip | LangFlow UI and dependencies |
| `requirements-vllm.txt` | pip | Optional GPU inference (vLLM 0.6.5) |

`setup.sh` assembles these layers and snapshots the final state into `constraints.txt`.

## Why Not Full Conda?
- LangFlow is not on conda-forge.
- Solving 500+ downstream dependencies via conda requires >30 minutes and often fails.
- Duplication between conda and pip wastes bandwidth and introduces ABI mismatches.

Our approach installs only the CUDA/PyTorch stack via conda, then layers pip packages using constraints so the resolver respects the versions conda already provided.

## Constraints Workflow
1. Create minimal environment (`environment-minimal-cpu.yml` or `environment-minimal-gpu.yml`).
2. Generate constraints snapshot from that environment using `importlib.metadata`.
3. Install pip requirements with `pip install --no-cache-dir -c constraints.txt -r <file>`.
4. Regenerate constraints after pip layers to capture the final resolved versions.

`constraints.txt` is ignored by Git and intended for local reproducibility.

## Environment Naming
- `agents_unplugged-cpu` — CPU-only base + pip layers.
- `agents_unplugged-gpu` — CUDA 12.1 base + pip layers.
- `agents_unplugged-gpu-vllm` — GPU base plus optional vLLM extras.

All names are reflected in Makefile targets and `setup.sh` flags.

## Makefile Integration
- `make setup` / `make setup-{cpu,gpu,gpu-vllm}`
- `make update ENV=<name>` — Re-run pip installs with the current constraints snapshot.
- `make clean` — Remove all `agents_unplugged-*` environments.

## Updating Layers
- Edit `requirements-*.txt` with version pins.
- Rerun `make update ENV=<env>` to apply changes and regenerate constraints.
- Commit requirement changes; `constraints.txt` remains local.

## Optional Components
- LangFlow lives behind its own requirements file so developer machines without the UI can skip it.
- vLLM is installed only when `--with-vllm` flag is passed.

## Summary
- Minimal conda base keeps GPU/CPU dependencies stable.
- Pip layers provide flexibility for rapid iteration.
- Dynamic constraints reconcile the two worlds without duplicate installations.
- Unified `setup.sh` and Makefile targets ensure every path produces consistent environments.
