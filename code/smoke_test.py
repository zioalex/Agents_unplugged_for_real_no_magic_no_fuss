"""Smoke test to verify core dependencies inside a configured environment."""

from __future__ import annotations

import os
import sys
from importlib import import_module


def main() -> int:
    env_name = os.environ.get("ENV_NAME", "<unknown>")

    checks: list[tuple[str, bool]] = [
        ("torch", True),
        ("langchain", True),
        ("pandas", True),
        ("matplotlib", True),
    ]

    if "vllm" in env_name.lower():
        checks.append(("vllm", True))
    else:
        checks.append(("vllm", False))

    missing_required: list[str] = []
    optional_missing: list[str] = []

    for module_name, required in checks:
        try:
            import_module(module_name)
        except ModuleNotFoundError:
            if required:
                missing_required.append(module_name)
            else:
                optional_missing.append(module_name)

    if missing_required:
        print(
            f"[ERROR] Required modules missing in environment '{env_name}': "
            + ", ".join(sorted(missing_required)),
            file=sys.stderr,
        )
        return 1

    print(f"[OK] Core modules available in environment '{env_name}'.")

    if optional_missing:
        print(
            "[WARN] Optional modules not found: " + ", ".join(sorted(optional_missing))
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
