# Report Generation and Sync Decision Tree

Use this when `openclash_fix_report.md` does not update or the user sees an old report.

## Diagnose

1. Find local reports:
   ```sh
   find . -name "openclash_fix_report*.md" 2>/dev/null
   find "$HOME" -name "openclash_fix_report*.md" 2>/dev/null | head -50
   ```
2. Find router reports:
   ```sh
   find /tmp /root /etc/openclash -name "openclash_fix_report*.md" 2>/dev/null
   ```
3. Check first line and modification time:
   ```sh
   ls -lh openclash_fix_report*.md 2>/dev/null
   head -n 5 openclash_fix_report.md 2>/dev/null
   ```

## Fix

Generate both latest and timestamped report:

```sh
python3 scripts/openclash_report_writer.py --output-dir . --report-source "WorkBuddy local" --router 192.168.1.1
```

## Rules

- `openclash_fix_report.md` must always be latest.
- A timestamped snapshot must be created for history.
- Reports must redact secrets.
- Report failure is not an OpenClash repair failure, but it must be disclosed.
- Do not modify OpenClash or OpenWrt settings just to refresh a report.
