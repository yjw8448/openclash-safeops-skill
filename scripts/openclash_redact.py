#!/usr/bin/env python3
"""Redact sensitive OpenClash diagnostic output."""
from __future__ import annotations
import argparse
import re
import sys
from pathlib import Path

PATTERNS = [
    (re.compile(r"https?://[^\s\"'<>]+", re.I), "https://[REDACTED_URL]"),
    (re.compile(r"(?i)([?&](?:token|key|secret|password|passwd|pwd)=)[^&\s]+"), r"\1[REDACTED]"),
    (re.compile(r"(?i)\b(Bearer\s+)[A-Za-z0-9._~+\-/]+=*"), r"\1[REDACTED]"),
    (re.compile(r"(?i)(Authorization:\s*)\S+"), r"\1[REDACTED]"),
    (re.compile(r"(?i)\b(secret|token|password|passwd|api[-_]?key)(\s*[:=]\s*)[^\s\"']+"), r"\1\2[REDACTED]"),
    (re.compile(r"(?i)(external-controller\s*:\s*)[^\s]+"), r"\1[REDACTED_CONTROLLER]"),
    (re.compile(r"(?i)(dashboard|yacd|zashboard)([^\n]{0,120})"), lambda m: m.group(1) + " [REDACTED_DASHBOARD_INFO]"),
]

def redact(text: str) -> str:
    for pat, repl in PATTERNS:
        text = pat.sub(repl, text)
    return text

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--input", "-i")
    p.add_argument("--output", "-o")
    p.add_argument("files", nargs="*")
    args = p.parse_args()
    chunks = []
    if args.input:
        chunks.append(Path(args.input).read_text(encoding="utf-8", errors="replace"))
    for f in args.files:
        chunks.append(Path(f).read_text(encoding="utf-8", errors="replace"))
    if not chunks:
        chunks.append(sys.stdin.read())
    out = redact("\n".join(chunks))
    if args.output:
        Path(args.output).write_text(out, encoding="utf-8")
    else:
        sys.stdout.write(out)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
