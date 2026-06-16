#!/usr/bin/env python3
"""Detect strategy groups and rule targets in OpenClash/Mihomo YAML."""
from __future__ import annotations
import argparse
import re
from pathlib import Path

try:
    import yaml  # type: ignore
except Exception:
    yaml = None

BUILTIN = {"DIRECT", "REJECT", "REJECT-DROP", "PASS", "GLOBAL"}

def load(path: Path):
    text = path.read_text(encoding="utf-8", errors="replace")
    if yaml is None:
        # crude fallback
        names = re.findall(r"^\s*-\s*name:\s*['\"]?([^'\"\n]+)", text, re.M)
        rules = re.findall(r"^\s*-\s*([^#\n]+)", text, re.M)
        return {"proxy-groups": [{"name": n.strip()} for n in names], "rules": rules}
    data = yaml.safe_load(text) or {}
    return data if isinstance(data, dict) else {}

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    parser.add_argument("--env", action="store_true")
    args = parser.parse_args()
    rc = 0
    for f in args.files:
        path = Path(f)
        data = load(path)
        groups = []
        for g in data.get("proxy-groups") or []:
            if isinstance(g, dict) and g.get("name"):
                groups.append(str(g["name"]))
        group_set = set(groups) | BUILTIN
        print(f"== {path} ==")
        print("groups:")
        for g in groups:
            print(f"- {g}")
        if args.env:
            for i, g in enumerate(groups, 1):
                safe = re.sub(r"[^A-Za-z0-9_]", "_", g).upper()
                print(f"GROUP_{i}_{safe}={g}")
        missing = []
        for rule in data.get("rules") or []:
            if not isinstance(rule, str):
                continue
            parts = [p.strip() for p in rule.split(",")]
            if len(parts) >= 2:
                target = parts[-1]
                if target and target not in group_set and not target.startswith("no-resolve"):
                    missing.append(target)
        if missing:
            rc = 1
            print("missing rule targets:")
            for m in sorted(set(missing)):
                print(f"- {m}")
    return rc

if __name__ == "__main__":
    raise SystemExit(main())
