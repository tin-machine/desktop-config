#!/usr/bin/env python3
from __future__ import annotations

import sys

from binding_contract import ContractError, validate_contract


def main() -> int:
    try:
        summary = validate_contract()
    except ContractError as exc:
        print(exc, file=sys.stderr)
        return 1

    print("Keybinding consistency report")
    print(f"Actions:                 {summary['actions']}")
    print(f"Required implementations:{summary['required_pairs']:>4}")
    print(f"Annotations:             {summary['annotations']:>4}")
    print(f"Evidence checks:         {summary['evidence_checks']:>4}")
    print(f"Documented divergences:  {summary['documented_divergences']:>4}")
    print(f"Duplicate bindings:      {summary['duplicate_bindings']:>4}")
    print()
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
