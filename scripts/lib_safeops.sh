#!/bin/sh
# Shared helpers for OpenClash SafeOps scripts.
# POSIX sh only. No network/dhcp/firewall writes.

SAFEOPS_VERSION="7.7"
OPENCLASH_CONFIG_DIR="${OPENCLASH_CONFIG_DIR:-/etc/openclash/config}"
OPENCLASH_ROOT_DIR="${OPENCLASH_ROOT_DIR:-/etc/openclash}"
OPENCLASH_UCI="${OPENCLASH_UCI:-/etc/config/openclash}"
SAFEOPS_BACKUP_ROOT="${SAFEOPS_BACKUP_ROOT:-/etc/openclash/safeops-backups}"

say() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

redact_stream() {
  sed -E \
    -e 's#(https?://)[^[:space:]"'"'<>]+#\1[REDACTED_URL]#g' \
    -e 's#([?&](token|key|secret|password|passwd|pwd)=)[^&[:space:]]+#\1[REDACTED]#Ig' \
    -e 's#(Bearer )[A-Za-z0-9._~+/-]+=*#\1[REDACTED]#g' \
    -e 's#(Authorization:[[:space:]]*)[^[:space:]]+#\1[REDACTED]#Ig' \
    -e 's#(secret|token|password|passwd|api[-_]?key)([[:space:]]*[:=][[:space:]]*)[^[:space:]"'"']+#\1\2[REDACTED]#Ig'
}

print_header() {
  say "============================================================"
  say "OpenClash SafeOps v${SAFEOPS_VERSION}: $1"
  say "============================================================"
}

is_openclash_path() {
  case "$1" in
    /etc/openclash/*|/etc/config/openclash|/tmp/openclash*|/tmp/*.yaml|/tmp/*.yml) return 0 ;;
    *) return 1 ;;
  esac
}

require_target_file() {
  [ -n "${TARGET_FILE:-}" ] || fail "TARGET_FILE is required. Example: TARGET_FILE=/etc/openclash/config/provider.yaml"
  case "$TARGET_FILE" in
    /etc/openclash/config/*.yaml|/etc/openclash/config/*.yml|/tmp/*.yaml|/tmp/*.yml) : ;;
    *) fail "TARGET_FILE must be a YAML file under /etc/openclash/config or /tmp for candidate validation." ;;
  esac
}

list_yaml_files() {
  if [ -d "$OPENCLASH_CONFIG_DIR" ]; then
    find "$OPENCLASH_CONFIG_DIR" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | sort
  fi
}

uci_get_safe() {
  if have uci; then
    uci -q get "$1" 2>/dev/null || true
  fi
}

service_status_safe() {
  svc="$1"
  if [ -x "/etc/init.d/$svc" ]; then
    "/etc/init.d/$svc" status 2>&1 || true
  else
    say "service $svc: init script not found"
  fi
}

require_apply_flag() {
  [ "${I_UNDERSTAND_SAFEOPS_WRITE:-}" = "1" ] || [ "${I_UNDERSTAND_TARGETED_WRITE:-}" = "1" ] || \
    fail "Refusing write. Set I_UNDERSTAND_SAFEOPS_WRITE=1 or I_UNDERSTAND_TARGETED_WRITE=1 after backup and review."
}

make_backup_dir() {
  ts="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo unknown-time)"
  dir="$SAFEOPS_BACKUP_ROOT/$ts"
  mkdir -p "$dir" || fail "Cannot create backup dir: $dir"
  printf '%s\n' "$dir"
}
