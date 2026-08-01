#!/usr/bin/env python3
"""Load and validate the cross-platform keybinding contract.

`bindings/actions.yaml` intentionally uses JSON syntax. JSON is a strict subset
of YAML, which keeps the file readable while allowing the CI to use only the
Python standard library.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "bindings" / "actions.yaml"
DOC_PATH = ROOT / "KEYBINDINGS.md"


class ContractError(RuntimeError):
    """Raised when the keybinding contract or an annotation is invalid."""


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ContractError(f"missing file: {path.relative_to(ROOT)}") from exc
    except json.JSONDecodeError as exc:
        raise ContractError(
            f"invalid JSON-compatible YAML in {path.relative_to(ROOT)}: {exc}"
        ) from exc


def normalize_token(value: str) -> str:
    return value.strip().lower().replace(" ", "")


def normalize_binding(binding: dict[str, str]) -> tuple[str, str]:
    return (
        normalize_token(binding["context"]),
        normalize_token(binding["key"]),
    )


def resolve_repo_path(relative_path: str) -> Path:
    resolved = (ROOT / relative_path).resolve()
    try:
        resolved.relative_to(ROOT)
    except ValueError as exc:
        raise ContractError(f"path escapes repository: {relative_path}") from exc
    return resolved


def load_contract() -> dict[str, Any]:
    contract = load_json(CONTRACT_PATH)
    if contract.get("version") != 1:
        raise ContractError("bindings/actions.yaml: unsupported version")

    platforms = contract.get("platforms")
    if not isinstance(platforms, list) or not platforms:
        raise ContractError("bindings/actions.yaml: platforms must be a non-empty list")

    manifests = contract.get("manifests")
    if set(manifests or {}) != set(platforms):
        raise ContractError("bindings/actions.yaml: manifests must cover every platform")

    actions = contract.get("actions")
    if not isinstance(actions, list) or not actions:
        raise ContractError("bindings/actions.yaml: actions must be a non-empty list")

    return contract


def load_annotations(contract: dict[str, Any]) -> dict[str, list[dict[str, str]]]:
    result: dict[str, list[dict[str, str]]] = {}
    for platform, relative_path in contract["manifests"].items():
        entries = load_json(resolve_repo_path(relative_path))
        if not isinstance(entries, list):
            raise ContractError(f"{relative_path}: annotation manifest must be a list")
        result[platform] = entries
    return result


def validate_contract() -> dict[str, int]:
    contract = load_contract()
    annotations = load_annotations(contract)
    platforms = contract["platforms"]

    errors: list[str] = []
    actions_by_id: dict[str, dict[str, Any]] = {}
    expected_pairs = 0
    documented_divergences = 0

    for action in contract["actions"]:
        action_id = action.get("id")
        if not action_id or action_id in actions_by_id:
            errors.append(f"duplicate or empty action id: {action_id!r}")
            continue
        actions_by_id[action_id] = action

        canonical = action.get("canonical")
        bindings = action.get("bindings", {})
        required = action.get("required_platforms", [])
        divergence_reasons = action.get("divergence_reasons", {})

        if not canonical:
            errors.append(f"{action_id}: canonical binding is missing")
            continue

        unknown_required = set(required) - set(platforms)
        if unknown_required:
            errors.append(
                f"{action_id}: unknown required platforms: {sorted(unknown_required)}"
            )

        for platform in required:
            expected_pairs += 1
            binding = bindings.get(platform)
            if not binding:
                errors.append(f"{action_id}: missing expected binding for {platform}")
                continue
            if normalize_binding(binding) != normalize_binding(canonical):
                if not divergence_reasons.get(platform):
                    errors.append(
                        f"{action_id}: {platform} differs from canonical without a reason"
                    )
                else:
                    documented_divergences += 1

        extra_reasons = set(divergence_reasons) - set(bindings)
        if extra_reasons:
            errors.append(
                f"{action_id}: divergence reason without binding: {sorted(extra_reasons)}"
            )

    annotated_pairs: dict[tuple[str, str], dict[str, str]] = {}
    occupied_bindings: dict[tuple[str, str, str], str] = {}
    evidence_checks = 0

    for platform, entries in annotations.items():
        for index, entry in enumerate(entries):
            prefix = f"{contract['manifests'][platform]}[{index}]"
            action_id = entry.get("action")
            if action_id not in actions_by_id:
                errors.append(f"{prefix}: unknown action {action_id!r}")
                continue

            pair = (platform, action_id)
            if pair in annotated_pairs:
                errors.append(f"{prefix}: duplicate annotation for {action_id}")
                continue
            annotated_pairs[pair] = entry

            context = normalize_token(entry.get("context", ""))
            key = normalize_token(entry.get("key", ""))
            occupied = (platform, context, key)
            previous_action = occupied_bindings.get(occupied)
            if previous_action:
                errors.append(
                    f"{prefix}: duplicate binding {context}:{key}; "
                    f"already used by {previous_action}"
                )
            else:
                occupied_bindings[occupied] = action_id

            expected = actions_by_id[action_id].get("bindings", {}).get(platform)
            if not expected:
                errors.append(
                    f"{prefix}: {action_id} is not declared for platform {platform}"
                )
            elif (context, key) != normalize_binding(expected):
                errors.append(
                    f"{prefix}: binding mismatch for {action_id}; "
                    f"expected {normalize_binding(expected)}, got {(context, key)}"
                )

            source = entry.get("source", "")
            evidence = entry.get("evidence", "")
            if not source or not evidence:
                errors.append(f"{prefix}: source and evidence are required")
                continue

            source_path = resolve_repo_path(source)
            try:
                source_text = source_path.read_text(encoding="utf-8")
            except FileNotFoundError:
                errors.append(f"{prefix}: missing source file {source}")
                continue

            evidence_checks += 1
            if evidence not in source_text:
                errors.append(
                    f"{prefix}: evidence not found in {source}: {evidence!r}"
                )

    for action_id, action in actions_by_id.items():
        for platform in action.get("required_platforms", []):
            if (platform, action_id) not in annotated_pairs:
                errors.append(f"{action_id}: missing {platform} annotation")

    if errors:
        message = "\n".join(f"- {error}" for error in errors)
        raise ContractError(f"keybinding consistency errors:\n{message}")

    return {
        "actions": len(actions_by_id),
        "required_pairs": expected_pairs,
        "annotations": len(annotated_pairs),
        "evidence_checks": evidence_checks,
        "documented_divergences": documented_divergences,
        "duplicate_bindings": 0,
    }


def display_binding(binding: dict[str, str] | None) -> str:
    if not binding:
        return "—"

    context, key = normalize_binding(binding)
    key_names = {
        "alt": "Alt",
        "ctrl": "Ctrl",
        "shift": "Shift",
        "cmd": "Cmd",
        "meta": "Meta",
        "space": "Space",
    }
    formatted_key = "+".join(key_names.get(part, part.upper()) for part in key.split("+"))
    if context == "global":
        return f"`{formatted_key}`"
    return f"`{context} → {formatted_key}`"


def generate_markdown() -> str:
    contract = load_contract()
    labels = contract["platform_labels"]
    platforms = contract["platforms"]

    lines = [
        "# Cross-platform Keybindings",
        "",
        "> このファイルは `bindings/actions.yaml` から生成されます。直接編集せず、",
        "> 操作契約または各platformのannotation manifestを更新してください。",
        "",
        "## 操作一覧",
        "",
        "| Action | 動作 | "
        + " | ".join(labels[platform] for platform in platforms)
        + " |",
        "|---|---|" + "|".join("---" for _ in platforms) + "|",
    ]

    for action in contract["actions"]:
        cells = [
            f"`{action['id']}`",
            action["description"],
            *[
                display_binding(action.get("bindings", {}).get(platform))
                for platform in platforms
            ],
        ]
        lines.append("| " + " | ".join(cells) + " |")

    divergences: list[tuple[str, str, str]] = []
    for action in contract["actions"]:
        for platform, reason in action.get("divergence_reasons", {}).items():
            divergences.append((action["id"], labels[platform], reason))

    lines.extend(["", "## 意図的な差異", ""])
    if divergences:
        for action_id, platform_label, reason in divergences:
            lines.append(f"- `{action_id}` / {platform_label}: {reason}")
    else:
        lines.append("- なし")

    lines.extend(
        [
            "",
            "## CIで検査する内容",
            "",
            "- 必須platformの実装漏れ",
            "- 操作契約とannotationのキー・context不一致",
            "- 同一platform/context内のキー衝突",
            "- annotationが示す実装断片の消失",
            "- 理由のないcanonical bindingからの差異",
            "- この生成ドキュメントの更新漏れ",
            "",
        ]
    )
    return "\n".join(lines)
