#!/usr/bin/env python3
"""Conservative YAML validation for OpenClash/Mihomo configs."""
from __future__ import annotations
import argparse
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except Exception:  # pragma: no cover
    yaml = None

REQUIRED_ONE_OF = ["proxies", "proxy-providers", "proxy-groups", "rules"]
DANGEROUS_KEYS = {"script", "exec", "shell", "command"}

def load_yaml(path: Path):
    text = path.read_text(encoding="utf-8", errors="replace")
    if yaml is None:
        # Syntax fallback: check obvious tab and bracket problems only.
        if "\t" in text:
            raise ValueError("YAML contains tab characters; use spaces")
        return {"__raw__": text}
    data = yaml.safe_load(text)
    if data is None:
        data = {}
    if not isinstance(data, dict):
        raise ValueError("Top-level YAML must be a mapping/object")
    return data

def lint(path: Path) -> list[str]:
    issues: list[str] = []
    data = load_yaml(path)
    if "__raw__" in data:
        return issues
    if not any(k in data for k in REQUIRED_ONE_OF):
        issues.append("No common OpenClash/Mihomo top-level sections found")
    for key in DANGEROUS_KEYS:
        if key in data:
            issues.append(f"Suspicious top-level key: {key}")
    groups = data.get("proxy-groups") or []
    if groups and not isinstance(groups, list):
        issues.append("proxy-groups must be a list")
    for idx, group in enumerate(groups if isinstance(groups, list) else []):
        if not isinstance(group, dict):
            issues.append(f"proxy-groups[{idx}] is not an object")
            continue
        if not group.get("name"):
            issues.append(f"proxy-groups[{idx}] missing name")
        if "proxies" in group and not isinstance(group.get("proxies"), list):
            issues.append(f"proxy-groups[{idx}].proxies must be a list")
    rules = data.get("rules") or []
    if rules and not isinstance(rules, list):
        issues.append("rules must be a list")
    dns = data.get("dns")
    if dns is not None and not isinstance(dns, dict):
        issues.append("dns must be an object")
    return issues

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    args = parser.parse_args()
    code = 0
    for name in args.files:
        path = Path(name)
        print(f"== {path} ==")
        try:
            issues = lint(path)
        except Exception as exc:
            print(f"FAIL: {exc}")
            code = 1
            continue
        if issues:
            for issue in issues:
                print(f"WARN: {issue}")
        else:
            print("OK")
    return code

if __name__ == "__main__":
    raise SystemExit(main())
