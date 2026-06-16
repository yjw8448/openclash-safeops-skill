#!/usr/bin/env python3
"""Detect strategy group names in an OpenClash/Mihomo config.

Usage:
  python3 openclash_group_detect.py /etc/openclash/config.yaml
  python3 openclash_group_detect.py /etc/openclash/config.yaml --env

This script is read-only.
"""
from __future__ import annotations
import argparse, re, sys, shlex
from pathlib import Path

PATTERNS = {
    "AI_GROUP": [r"(?i)ai", r"(?i)openai", r"(?i)chatgpt", r"(?i)claude", r"🤖"],
    "PROXY_GROUP": [r"(?i)^proxy$", r"(?i)节点选择", r"(?i)手动", r"(?i)select", r"(?i)proxy", r"🚀", r"国外"],
    "AUTO_GROUP": [r"(?i)auto", r"(?i)自动", r"(?i)url-test", r"(?i)fallback", r"♻"],
    "FINAL_GROUP": [r"(?i)final", r"(?i)match", r"(?i)漏网", r"(?i)兜底", r"🐟"],
    "STREAMING_GROUP": [r"(?i)stream", r"(?i)media", r"(?i)netflix", r"(?i)disney", r"(?i)youtube", r"流媒体", r"奈飞"],
    "DIRECT_GROUP": [r"(?i)^direct$", r"(?i)直连", r"🎯"],
}


def load(path: Path):
    try:
        import yaml  # type: ignore
    except Exception as exc:
        print("ERROR: Python module 'yaml' is missing. Install PyYAML.", file=sys.stderr)
        print(str(exc), file=sys.stderr)
        return None
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def score(name, patterns):
    s = 0
    for i, pat in enumerate(patterns):
        if re.search(pat, name):
            s += 100 - i
    return s


def choose(groups, key):
    candidates = [(score(g, PATTERNS[key]), g) for g in groups]
    candidates = [x for x in candidates if x[0] > 0]
    if not candidates:
        return ""
    candidates.sort(reverse=True)
    return candidates[0][1]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("config")
    ap.add_argument("--env", action="store_true", help="print shell env assignments")
    args = ap.parse_args()
    path = Path(args.config)
    data = load(path)
    if not isinstance(data, dict):
        print("ERROR: config root is not a mapping", file=sys.stderr)
        return 2
    group_defs = data.get("proxy-groups") or []
    groups = []
    if isinstance(group_defs, list):
        for g in group_defs:
            if isinstance(g, dict) and g.get("name"):
                groups.append(str(g["name"]))
    if not groups:
        print("ERROR: no proxy-groups found", file=sys.stderr)
        return 2

    result = {k: choose(groups, k) for k in PATTERNS}
    # fallbacks
    if not result["PROXY_GROUP"]:
        result["PROXY_GROUP"] = groups[0]
    if not result["FINAL_GROUP"]:
        result["FINAL_GROUP"] = result["PROXY_GROUP"]
    if not result["AI_GROUP"]:
        result["AI_GROUP"] = result["PROXY_GROUP"]
    if not result["DIRECT_GROUP"]:
        result["DIRECT_GROUP"] = "DIRECT"

    if args.env:
        for k, v in result.items():
            print(f"{k}={shlex.quote(v)}")
    else:
        print("# Strategy group detection")
        print("Detected groups:")
        for g in groups:
            print(f"- {g}")
        print("\nSuggested role mapping:")
        for k, v in result.items():
            print(f"- {k}: {v}")
        print("\nUse these names when generating rules. Do not assume AI/Proxy groups exist.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
