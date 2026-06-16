# Playbook: Restore Two Subscriptions After Accidental Merge

Use when an agent accidentally merged two subscriptions/configs.

## Step 0: freeze writes

Do not update subscriptions, start OpenClash, or run one-click config.

## Step 1: backup bad state

```sh
BAD_DIR="/root/openclash-bad-merged-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BAD_DIR"
cp -a /etc/config/openclash "$BAD_DIR/openclash.uci" 2>/dev/null || true
cp -a /etc/openclash "$BAD_DIR/openclash-dir" 2>/dev/null || true
echo "BAD_MERGED_BACKUP=$BAD_DIR"
```

## Step 2: audit current state

```sh
sh scripts/openclash_multisub_audit.sh
python3 scripts/openclash_config_fingerprint.py /etc/openclash/config/*.yaml /etc/openclash/*.yaml 2>/dev/null
```

## Step 3: locate backups

```sh
find /root /tmp /etc/openclash -type d \( -iname '*backup*' -o -iname '*bad-merged*' \) 2>/dev/null | sort
```

## Step 4: inspect a candidate backup

```sh
BACKUP_DIR='/root/openclash-safeops-backup-YYYYmmdd-HHMMSS'
find "$BACKUP_DIR" -maxdepth 4 -type f 2>/dev/null | sort
```

## Step 5: dry-run restore

```sh
sh scripts/openclash_restore_multiconfig.sh "$BACKUP_DIR"
```

## Step 6: apply restore only after confirmation

```sh
sh scripts/openclash_restore_multiconfig.sh "$BACKUP_DIR" --apply
```

This restores only:

- `/etc/config/openclash`
- `/etc/openclash/`

It does not restore:

- `/etc/config/network`
- `/etc/config/dhcp`
- `/etc/config/firewall`

## Step 7: post-restore verify

```sh
sh scripts/openclash_multisub_audit.sh
/etc/init.d/openclash status 2>/dev/null || true
/etc/init.d/dnsmasq status 2>/dev/null || true
logread | grep -i openclash | tail -n 80 || true
```

Ask the user which profile should be active before starting OpenClash.
