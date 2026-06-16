# Reporting and Redaction

Use this reference whenever the user says the report is stale, missing, not updated, or when a workflow finishes.

## Required outputs

Every diagnosis, repair, binding audit, template application, or subscription workflow must produce both:

```text
openclash_fix_report.md
openclash_fix_report_YYYYmmdd-HHMMSS.md
```

`openclash_fix_report.md` is always the latest report. The timestamped file is a history snapshot.

## Required first lines

The report must include:

```text
Generated At: YYYY-MM-DD HH:MM:SS
Report Source: WorkBuddy local / Router SSH / user-provided output
Router: 192.168.1.1
```

## Redaction policy

Never print raw subscription URLs, passwords, dashboard secrets, tokens, or API keys. Run logs through:

```sh
python3 scripts/openclash_redact.py
```

or use equivalent sed redaction before writing reports.

## Writer command

```sh
python3 scripts/openclash_report_writer.py \
  --output-dir . \
  --report-source "WorkBuddy local" \
  --router 192.168.1.1 \
  --target-config "/etc/openclash/config/config-a(2).yaml" \
  --active-config "/etc/openclash/config/config-a(2).yaml" \
  --backup-dir "/root/openclash-safeops-backup-YYYYmmdd-HHMMSS" \
  --candidate "/tmp/config-a2.candidate.yaml" \
  --notes "summary goes here"
```

## Router vs local report

If a report is written on the router, copy or print it back to the user. If copying is unavailable, print the report content in the WorkBuddy response. Do not leave the user looking at an old local file.

## Local SSH helper scripts

Do not delete reusable local SSH helper scripts automatically. They may be needed for future OpenClash maintenance. Instead:

1. Report their paths.
2. Check whether they embed raw passwords, tokens, or subscription URLs.
3. Recommend moving credentials to a local credential manager or environment variable.
4. Delete only after the user explicitly asks.


## Implementation note

`openclash_report_writer.py` uses the same redaction logic as `openclash_redact.py`. Do not add separate report-only redaction patterns unless they are also added to the standalone redaction tool.

Agent must replace every `<fill from ...>` placeholder before presenting a report as final. If data is unknown, write `<unknown>` and explain why.
