# Scripts Reference

Read-only scripts: diagnose, dns_audit, subscription_health, multisub_audit, binding audits, rule_test, config_fingerprint.

Write-capable scripts require explicit `--apply` plus `I_UNDERSTAND_SAFEOPS_WRITE=1` or `I_UNDERSTAND_TARGETED_WRITE=1`.

## Shared library

`scripts/lib_safeops.sh` — POSIX sh function library sourced by other scripts. Provides:

- `redact_stream()` — pipe-through redaction for command output
- `print_header()` — consistent section formatting
- `is_openclash_path()` — path safety validation
- `require_target_file()` — enforce single-target mode
- `list_yaml_files()` — discover OpenClash config YAML/yml files
- `uci_get_safe()` — read-only UCI access
- `service_status_safe()` — read-only service status
- `require_apply_flag()` — enforce `--apply` + `I_UNDERSTAND_SAFEOPS_WRITE=1` gate
- `make_backup_dir()` — create timestamped backup directory
- `say()`, `warn()`, `fail()` — consistent output helpers
- `have()` — portable command existence check
