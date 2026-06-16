#!/usr/bin/env python3
"""Generate redacted fingerprints for OpenClash YAML configs."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path

try:
    from openclash_redact import redact
except Exception:
    def redact(x: str) -> str:
        return x

def fingerprint(path: Path) -> dict:
    data = path.read_bytes()
    text = data.decode("utf-8", errors="replace")
    redacted = redact(text).encode("utf-8")
    stat = path.stat()
    return {
        "path": str(path),
        "size": stat.st_size,
        "sha256_redacted": hashlib.sha256(redacted).hexdigest(),
        "mtime": int(stat.st_mtime),
        "line_count": text.count("\n") + 1,
    }

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    rows = []
    for f in args.files:
        p = Path(f)
        if p.exists() and p.is_file():
            rows.append(fingerprint(p))
    if args.json:
        print(json.dumps(rows, ensure_ascii=False, indent=2))
    else:
        for r in rows:
            print(f"{r['path']} size={r['size']} lines={r['line_count']} sha256_redacted={r['sha256_redacted']}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
