#!/usr/bin/env python3
"""Apply a safe overlay template to exactly one OpenClash YAML config.

Default mode writes a candidate only. --apply requires I_UNDERSTAND_TARGETED_WRITE=1.
"""
from __future__ import annotations
import argparse
import copy
import os
import shutil
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except Exception as exc:
    print("PyYAML is required for template application", file=sys.stderr)
    raise

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_MAP = {
    "aethersailor-current-safe": ROOT / "templates/aethersailor-current-safe-overlay.yaml",
    "aethersailor-legacy-safe": ROOT / "templates/aethersailor-legacy-safe-overlay.yaml",
    "ffani-redirhost-smartdns": ROOT / "templates/ffani-redirhost-smartdns-overlay.yaml",
    "safe-basic": ROOT / "templates/overwrite-safe-basic.yaml",
    "ai-dev": ROOT / "templates/overwrite-ai-dev.yaml",
}
PRESERVE_KEYS = {"proxies", "proxy-groups", "proxy-providers"}
ALLOWED_TARGET_PREFIXES = ("/etc/openclash/config/", "/tmp/")

def load_yaml(path: Path) -> dict:
    data = yaml.safe_load(path.read_text(encoding="utf-8", errors="replace")) or {}
    if not isinstance(data, dict):
        raise ValueError(f"{path} top-level YAML must be object")
    return data

def deep_merge(base: dict, overlay: dict) -> dict:
    result = copy.deepcopy(base)
    for key, value in overlay.items():
        if key == "__safeops_meta__":
            continue
        if key in PRESERVE_KEYS and key in base:
            # preserve subscription-managed/proxy identity by default
            continue
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = copy.deepcopy(value)
    return result

def safe_target(path: Path) -> None:
    s = str(path)
    if not s.startswith(ALLOWED_TARGET_PREFIXES):
        raise ValueError("target must be under /etc/openclash/config/ or /tmp/")
    if path.name.startswith(".") or path.suffix not in {".yaml", ".yml"}:
        raise ValueError("target must be a .yaml/.yml file")

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--target", required=True)
    p.add_argument("--template", required=True, choices=sorted(TEMPLATE_MAP))
    p.add_argument("--candidate", required=True)
    p.add_argument("--apply", action="store_true")
    args = p.parse_args()
    target = Path(args.target)
    candidate = Path(args.candidate)
    safe_target(target)
    if not target.exists():
        raise SystemExit(f"target not found: {target}")
    template_path = TEMPLATE_MAP[args.template]
    base = load_yaml(target)
    overlay = load_yaml(template_path)
    merged = deep_merge(base, overlay)
    candidate.parent.mkdir(parents=True, exist_ok=True)
    candidate.write_text(yaml.safe_dump(merged, allow_unicode=True, sort_keys=False), encoding="utf-8")
    print(f"candidate written: {candidate}")
    if args.apply:
        if os.environ.get("I_UNDERSTAND_TARGETED_WRITE") != "1":
            raise SystemExit("Refusing apply without I_UNDERSTAND_TARGETED_WRITE=1")
        backup = target.with_suffix(target.suffix + ".safeops.bak")
        shutil.copy2(target, backup)
        shutil.copy2(candidate, target)
        print(f"applied to: {target}")
        print(f"backup: {backup}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
