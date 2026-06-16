#!/usr/bin/env python3
"""Fingerprint and summarize OpenClash YAML files.

This script is safe and read-only. It masks URLs and credentials.
It works with PyYAML when available, but also provides a regex fallback.
"""
from __future__ import annotations
import hashlib
import json
import os
import re
import sys
from pathlib import Path
from typing import Any

URL_RE = re.compile(r"https?://[^\s'\"<>]+")
SECRET_RE = re.compile(r"(?i)(secret|password|passwd|token|key)\s*[:=]\s*[^\s'\"]+")


def mask(text: str) -> str:
    text = URL_RE.sub("<SUB_URL_REDACTED>", text)
    return SECRET_RE.sub(lambda m: m.group(1) + "=<REDACTED>", text)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()[:16]


def try_yaml_load(text: str) -> Any:
    try:
        import yaml  # type: ignore
    except Exception:
        return None
    try:
        return yaml.safe_load(text)
    except Exception as exc:
        return {"__yaml_error__": str(exc)}


def count_from_yaml(obj: Any) -> dict[str, Any]:
    if not isinstance(obj, dict):
        return {}
    out: dict[str, Any] = {}
    for key in ["proxies", "proxy-groups", "rules", "proxy-providers", "rule-providers", "dns"]:
        val = obj.get(key)
        if isinstance(val, list):
            out[key] = len(val)
        elif isinstance(val, dict):
            out[key] = len(val)
        elif val is not None:
            out[key] = "present"
        else:
            out[key] = 0
    groups = obj.get("proxy-groups")
    if isinstance(groups, list):
        names = []
        for g in groups:
            if isinstance(g, dict) and "name" in g:
                names.append(str(g.get("name")))
        out["group_names_sample"] = names[:20]
    return out


def count_fallback(text: str) -> dict[str, Any]:
    out: dict[str, Any] = {}
    for key in ["proxies", "proxy-groups", "rules", "proxy-providers", "rule-providers", "dns"]:
        out[key + "_section"] = bool(re.search(rf"(?m)^{re.escape(key)}:\s*$", text))
    out["name_lines_sample"] = [mask(x.strip()) for x in re.findall(r"(?m)^\s*-?\s*name:\s*(.+)$", text)[:20]]
    return out


def summarize(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    text = data.decode("utf-8", errors="replace")
    obj = try_yaml_load(text)
    summary: dict[str, Any] = {
        "file": str(path),
        "size": len(data),
        "sha256_16": sha256(data),
        "url_count": len(set(URL_RE.findall(text))),
        "masked_url_hosts": sorted({re.sub(r"^[a-z]+://([^/:?]+).*", r"\1", u) for u in URL_RE.findall(text)})[:20],
    }
    if isinstance(obj, dict) and "__yaml_error__" not in obj:
        summary["yaml_parse"] = "ok"
        summary.update(count_from_yaml(obj))
    elif isinstance(obj, dict) and "__yaml_error__" in obj:
        summary["yaml_parse"] = "error"
        summary["yaml_error"] = mask(str(obj["__yaml_error__"]))
        summary.update(count_fallback(text))
    else:
        summary["yaml_parse"] = "not_checked_no_pyyaml_or_not_yaml"
        summary.update(count_fallback(text))
    return summary


def main(argv: list[str]) -> int:
    if not argv:
        print("Usage: openclash_config_fingerprint.py <yaml files...>", file=sys.stderr)
        return 2
    paths: list[Path] = []
    for arg in argv:
        for p in Path().glob(arg) if any(ch in arg for ch in "*?[]") else [Path(arg)]:
            if p.exists() and p.is_file():
                paths.append(p)
    if not paths:
        print("No readable YAML/config files found.")
        return 1
    for p in paths:
        try:
            print(json.dumps(summarize(p), ensure_ascii=False, indent=2))
        except Exception as exc:
            print(json.dumps({"file": str(p), "error": mask(str(exc))}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
