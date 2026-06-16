#!/bin/sh
# Schedule a delayed OpenClash rollback before medium-risk changes.
# Usage: sh openclash_delayed_rollback.sh /root/openclash-safeops-backup-YYYYmmdd-HHMMSS 180
# Cancel manually by killing the printed PID if verification succeeds.

set -eu
BACKUP_DIR="${1:-}"
DELAY="${2:-180}"
if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  echo "Usage: sh openclash_delayed_rollback.sh /root/openclash-safeops-backup-YYYYmmdd-HHMMSS [seconds]"
  exit 1
fi

ROLLBACK_SCRIPT="/tmp/openclash_delayed_rollback_$$.sh"
cat > "$ROLLBACK_SCRIPT" <<EOS
#!/bin/sh
sleep "$DELAY"
echo "SafeOps delayed rollback triggered at \$(date)" >> /tmp/openclash-safeops-delayed-rollback.log
if [ -f /tmp/openclash_rollback.sh ]; then
  sh /tmp/openclash_rollback.sh "$BACKUP_DIR" >> /tmp/openclash-safeops-delayed-rollback.log 2>&1
else
  echo "rollback script missing" >> /tmp/openclash-safeops-delayed-rollback.log
fi
EOS
chmod +x "$ROLLBACK_SCRIPT"
nohup sh "$ROLLBACK_SCRIPT" >/tmp/openclash-safeops-delayed-rollback.nohup 2>&1 &
PID=$!
echo "DELAYED_ROLLBACK_PID=$PID"
echo "Cancel after verification succeeds: kill $PID"
