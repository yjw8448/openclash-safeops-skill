#!/bin/sh
# Watchdog-backed anti-lockout guard for medium-risk OpenClash changes.
# Usage:
#   sh openclash_watchdog.sh --start /root/openclash-safeops-backup-YYYYmmdd-HHMMSS --timeout 300
#   sh openclash_watchdog.sh --disarm
#   sh openclash_watchdog.sh --status
#
# This watchdog does NOT restore network/dhcp/firewall by default.

set -eu
PID_FILE="/tmp/openclash_safeops_watchdog.pid"
DISARM_FILE="/tmp/openclash_safeops_watchdog.disarm"
LOG_FILE="/tmp/openclash_safeops_watchdog.log"
MODE="${1:-}"

usage() {
  sed -n '1,26p' "$0"
}

restore_openclash_only() {
  BACKUP_DIR="$1"
  echo "$(date '+%F %T') rollback triggered from $BACKUP_DIR" >> "$LOG_FILE"
  [ -x /etc/init.d/openclash ] && /etc/init.d/openclash stop >> "$LOG_FILE" 2>&1 || true
  for p in $(pidof clash 2>/dev/null || true) $(pidof mihomo 2>/dev/null || true) $(pidof clash_meta 2>/dev/null || true); do
    kill "$p" >> "$LOG_FILE" 2>&1 || true
  done
  if [ -e "$BACKUP_DIR/etc/config/openclash" ]; then
    rm -rf /etc/config/openclash
    cp -a "$BACKUP_DIR/etc/config/openclash" /etc/config/openclash
  fi
  if [ -e "$BACKUP_DIR/etc/openclash" ]; then
    rm -rf /etc/openclash
    cp -a "$BACKUP_DIR/etc/openclash" /etc/openclash
  fi
  [ -x /etc/init.d/dnsmasq ] && /etc/init.d/dnsmasq restart >> "$LOG_FILE" 2>&1 || true
  [ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd restart >> "$LOG_FILE" 2>&1 || true
  echo "$(date '+%F %T') rollback finished; OpenClash remains stopped" >> "$LOG_FILE"
}

health_check() {
  # Return 0 healthy, 1 unhealthy.
  ip route | grep -q '^default' || return 1
  [ -x /etc/init.d/dropbear ] && /etc/init.d/dropbear status >/dev/null 2>&1 || true
  [ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd status >/dev/null 2>&1 || true
  nslookup openwrt.org 127.0.0.1 >/dev/null 2>&1 || return 1
  return 0
}

monitor() {
  BACKUP_DIR="$1"
  TIMEOUT="$2"
  INTERVAL="$3"
  FAIL_LIMIT="$4"
  rm -f "$DISARM_FILE"
  echo $$ > "$PID_FILE"
  echo "$(date '+%F %T') watchdog started backup=$BACKUP_DIR timeout=$TIMEOUT interval=$INTERVAL fail_limit=$FAIL_LIMIT" >> "$LOG_FILE"
  elapsed=0
  failures=0
  while [ "$elapsed" -lt "$TIMEOUT" ]; do
    if [ -f "$DISARM_FILE" ]; then
      echo "$(date '+%F %T') watchdog disarmed" >> "$LOG_FILE"
      rm -f "$PID_FILE" "$DISARM_FILE"
      exit 0
    fi
    if health_check; then
      failures=0
      echo "$(date '+%F %T') health ok elapsed=$elapsed" >> "$LOG_FILE"
    else
      failures=$((failures + 1))
      echo "$(date '+%F %T') health failed count=$failures elapsed=$elapsed" >> "$LOG_FILE"
      if [ "$failures" -ge "$FAIL_LIMIT" ]; then
        restore_openclash_only "$BACKUP_DIR"
        rm -f "$PID_FILE" "$DISARM_FILE"
        exit 2
      fi
    fi
    sleep "$INTERVAL"
    elapsed=$((elapsed + INTERVAL))
  done
  echo "$(date '+%F %T') watchdog timeout reached without rollback" >> "$LOG_FILE"
  rm -f "$PID_FILE" "$DISARM_FILE"
}

case "$MODE" in
  --start)
    BACKUP_DIR="${2:-}"
    [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ] || { echo "Backup dir missing or invalid"; usage; exit 1; }
    TIMEOUT=300
    INTERVAL=30
    FAIL_LIMIT=3
    shift 2
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --timeout) TIMEOUT="$2"; shift 2 ;;
        --interval) INTERVAL="$2"; shift 2 ;;
        --failures) FAIL_LIMIT="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
      esac
    done
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Watchdog already running pid=$(cat "$PID_FILE")"
      exit 1
    fi
    nohup sh "$0" --monitor "$BACKUP_DIR" "$TIMEOUT" "$INTERVAL" "$FAIL_LIMIT" >/dev/null 2>&1 &
    echo "Watchdog started. PID file: $PID_FILE. Log: $LOG_FILE"
    echo "Disarm after successful verification: sh $0 --disarm"
    ;;
  --monitor)
    monitor "$2" "$3" "$4" "$5"
    ;;
  --disarm)
    touch "$DISARM_FILE"
    echo "Disarm requested. Watchdog will exit on next interval."
    ;;
  --status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "running pid=$(cat "$PID_FILE")"
    else
      echo "not running"
    fi
    [ -f "$LOG_FILE" ] && tail -n 80 "$LOG_FILE" || true
    ;;
  --help|-h|*)
    usage
    ;;
esac
