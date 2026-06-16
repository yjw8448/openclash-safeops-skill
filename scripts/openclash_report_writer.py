#!/usr/bin/env python3
"""Write a redacted OpenClash fix report and a timestamped snapshot.

This script is intentionally local/report-only. It does not modify router settings.
It uses the same redaction logic as openclash_redact.py. Agent must replace all
`<fill from ...>` placeholders when final workflow data is available.
"""
from __future__ import annotations
import argparse, datetime as dt, re, sys
from pathlib import Path

try:
    from openclash_redact import redact  # keep report redaction consistent with the standalone tool
except Exception:
    # Fallback copy of openclash_redact.py patterns. Keep this list in sync.
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
    p = argparse.ArgumentParser(description='Write latest and timestamped OpenClash fix reports with secret redaction.')
    p.add_argument('--output-dir', default='.')
    p.add_argument('--report-source', default='WorkBuddy local')
    p.add_argument('--router', default='192.168.1.1')
    p.add_argument('--target-config', default='')
    p.add_argument('--backup-dir', default='')
    p.add_argument('--active-config', default='')
    p.add_argument('--candidate', default='')
    p.add_argument('--notes', default='')
    p.add_argument('--stdin-notes', action='store_true')
    args = p.parse_args()

    now = dt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    stamp = dt.datetime.now().strftime('%Y%m%d-%H%M%S')
    notes = args.notes
    if args.stdin_notes or not sys.stdin.isatty():
        extra = sys.stdin.read()
        if extra.strip():
            notes = (notes + '\n' + extra).strip()
    notes = redact(notes)
    outdir = Path(args.output_dir).expanduser().resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    body = f"""# OpenClash Fix Report

Generated At: {now}
Report Source: {redact(args.report_source)}
Router: {redact(args.router)}
Target Config: {redact(args.target_config) or '<not specified>'}
Active Config: {redact(args.active_config) or '<not specified>'}
Candidate File: {redact(args.candidate) or '<not specified>'}
Backup Directory: {redact(args.backup_dir) or '<not specified>'}

> Agent note: replace every `<fill from ...>` placeholder with real workflow data before treating this report as final.

## 1. Current Status

- OpenClash status: <fill from diagnosis>
- Current config_path: {redact(args.active_config) or '<unknown>'}
- Auto update: <fill from binding audit>
- Config update URL: <SUB_URL_REDACTED>
- YAML files: <fill from diagnosis>
- Subscription records: <fill from binding audit>

## 2. Diagnosis

- Problem found: <fill from workflow>
- Root cause: <fill from workflow>
- DNS status: <fill from workflow>
- Subscription status: <fill from workflow>
- Active config/update-url consistency: <fill from audit>
- Multi-subscription risk: <fill from audit>
- Unbound config risk: <fill from audit>

## 3. Actions Taken

- Modified files: <none unless explicitly filled>
- Commands executed: <fill from workflow>
- Commands skipped: <fill from workflow>
- High-risk actions avoided: network/dhcp/firewall/reboot/reset unless explicitly stated otherwise

## 4. Safety Check

- Modified /etc/config/network: no
- Modified /etc/config/dhcp: no
- Modified /etc/config/firewall: no
- Restarted network: no
- Rebooted router: no
- Merged subscriptions: no
- Printed raw subscription URLs: no

## 5. Verification

- SSH: <fill from workflow>
- LuCI: <fill from workflow>
- dnsmasq: <fill from workflow>
- OpenClash: <fill from workflow>
- DNS resolution: <fill from workflow>
- Subscription update: <fill from workflow>
- Active config: {redact(args.active_config) or '<unknown>'}

## 6. Rollback

- Backup path: {redact(args.backup_dir) or '<not specified>'}
- Rollback command: <fill from backup plan>

## 7. Notes

{notes or '<none>'}

## 8. Next Steps

- Need user confirmation: <fill from workflow>
- Recommended next action: <fill from workflow>
"""
    body = redact(body)
    latest = outdir / 'openclash_fix_report.md'
    snap = outdir / f'openclash_fix_report_{stamp}.md'
    latest.write_text(body, encoding='utf-8')
    snap.write_text(body, encoding='utf-8')
    print(f"REPORT_LATEST={latest}")
    print(f"REPORT_SNAPSHOT={snap}")
    print(f"Generated At: {now}")
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
