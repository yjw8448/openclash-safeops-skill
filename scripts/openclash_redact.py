#!/usr/bin/env python3
"""Redact OpenClash/OpenWrt secrets from stdin, arguments, or files.

Usage:
  command | python3 scripts/openclash_redact.py
  python3 scripts/openclash_redact.py --file /path/to/log
"""
from __future__ import annotations
import argparse, re, sys
from pathlib import Path

PATTERNS = [
    (re.compile(r"(?i)(https?://)([^\s'\"<>]+)"), r"<SUB_URL_REDACTED>"),
    (re.compile(r"(?i)(password\s*[=:]\s*)[^\s'\"]+"), r"\1<REDACTED>"),
    (re.compile(r"(?i)(passwd\s*[=:]\s*)[^\s'\"]+"), r"\1<REDACTED>"),
    (re.compile(r"(?i)(secret\s*[=:]\s*)[^\s'\"]+"), r"\1<REDACTED>"),
    (re.compile(r"(?i)(token\s*[=:]\s*)[^\s'\"]+"), r"\1<REDACTED>"),
    (re.compile(r"(?i)(api[_-]?key\s*[=:]\s*)[^\s'\"]+"), r"\1<REDACTED>"),
    (re.compile(r"(?i)(Authorization:\s*Bearer\s+)[A-Za-z0-9._\-]+"), r"\1<REDACTED>"),
    (re.compile(r"(?i)(dash\.[^/\s]+/api/[^\s'\"]+)"), r"<SUB_URL_REDACTED>"),
]

def redact(text: str) -> str:
    for pat, repl in PATTERNS:
        text = pat.sub(repl, text)
    return text

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--file', action='append', default=[])
    ap.add_argument('text', nargs='*')
    args = ap.parse_args()
    chunks = []
    for f in args.file:
        try:
            chunks.append(Path(f).read_text(encoding='utf-8', errors='replace'))
        except Exception as e:
            chunks.append(f"[redact: failed to read {f}: {e}]\n")
    if args.text:
        chunks.append(' '.join(args.text))
    if not chunks:
        chunks.append(sys.stdin.read())
    sys.stdout.write(redact('\n'.join(chunks)))
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
