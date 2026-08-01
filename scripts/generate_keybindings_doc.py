#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys

from binding_contract import CONTRACT_PATH, DOC_PATH, ContractError, generate_markdown


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate KEYBINDINGS.md from the cross-platform contract"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail when KEYBINDINGS.md is not up to date",
    )
    args = parser.parse_args()

    try:
        generated = generate_markdown()
    except ContractError as exc:
        print(exc, file=sys.stderr)
        return 1

    if args.check:
        try:
            current = DOC_PATH.read_text(encoding="utf-8")
        except FileNotFoundError:
            current = ""
        if current != generated:
            print(
                f"{DOC_PATH.relative_to(CONTRACT_PATH.parents[1])} is stale; "
                "run scripts/generate_keybindings_doc.py",
                file=sys.stderr,
            )
            return 1
        print("KEYBINDINGS.md is up to date")
        return 0

    DOC_PATH.write_text(generated, encoding="utf-8")
    print(f"wrote {DOC_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
