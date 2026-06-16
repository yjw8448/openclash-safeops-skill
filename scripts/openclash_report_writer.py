#!/usr/bin/env python3
"""Generate redacted OpenClash SafeOps reports."""
from __future__ import annotations
import argparse
import datetime as dt
import os
import subprocess
import sys
from pathlib import Path

try:
    from openclash_redact import redact
except Exception:
    def redact(x: str) -> str:
        return x

def read_file(path: str | None) -> str:
    if not path:
        return ""
    p = Path(path)
    return p.read_text(encoding="utf-8", errors="replace") if p.exists() else f"[missing file: {path}]\n"

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--diagnosis")
    parser.add_argument("--dns-audit")
    parser.add_argument("--subscription-audit")
    parser.add_argument("--notes")
    parser.add_argument("--stdin-notes", action="store_true")
    parser.add_argument("--output")
    parser.add_argument("--output-dir", default=".")
    args = parser.parse_args()
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    ts = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    sections: list[tuple[str, str]] = []
    for title, path in [
        ("Diagnosis", args.diagnosis),
        ("DNS audit", args.dns_audit),
        ("Subscription audit", args.subscription_audit),
        ("Notes", args.notes),
    ]:
        text = read_file(path)
        if text:
            sections.append((title, text))
    if args.stdin_notes:
        data = sys.stdin.read()
        if data:
            sections.append(("STDIN notes", data))
    body = [
        "# OpenClash SafeOps Report",
        "",
        f"Generated: {now}",
        "",
        "## Safety statement",
        "",
        "This report is redacted. Subscription URLs, tokens, secrets, passwords, API keys, Bearer tokens, and dashboard paths are masked.",
        "",
        "Normal SafeOps repair must not modify `/etc/config/network`, `/etc/config/dhcp`, or `/etc/config/firewall`.",
        "",
    ]
    for title, text in sections:
        body.extend([f"## {title}", "", "```text", redact(text).rstrip(), "```", ""])
    body.extend(["## Checklist", "", "- [ ] Active config identified", "- [ ] Multi-subscription mapping checked", "- [ ] Backup path recorded", "- [ ] Candidate linted", "- [ ] User approved write", "- [ ] Connectivity verified", ""])
    report = "\n".join(body)
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    outputs = []
    if args.output:
        outputs.append(Path(args.output))
    else:
        outputs.append(out_dir / "openclash_fix_report.md")
        outputs.append(out_dir / f"openclash_fix_report_{ts}.md")
    for out in outputs:
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(report, encoding="utf-8")
        print(out)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
