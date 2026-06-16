# SSH Repair Runbook

## First response when the user says "OpenClash broke my network"

Ask or determine:
- Can they SSH?
- Can they open LuCI?
- What is the current gateway IP shown on their computer/phone?
- Are they connected by Ethernet or Wi-Fi?

If SSH works, run:

```sh
sh /tmp/openclash_diagnose.sh | tee /tmp/openclash-diagnose.txt
```

If the user has not uploaded scripts, give this minimal first-aid block:

```sh
/etc/init.d/openclash stop 2>/dev/null || true
killall clash 2>/dev/null || true
killall mihomo 2>/dev/null || true
/etc/init.d/dnsmasq restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true
ip route
nslookup openwrt.org 127.0.0.1
```

Do not run `/etc/init.d/network restart`.

## Backup before repair

```sh
sh /tmp/openclash_backup.sh
```

Record the returned path:

```text
BACKUP_DIR=/root/openclash-safeops-backup-YYYYmmdd-HHMMSS
```

## Low-risk repair

```sh
sh /tmp/openclash_safe_repair.sh --apply
```

This stops OpenClash, clears orphan processes, restarts dnsmasq/uhttpd if needed, and verifies DNS/HTTP. It leaves OpenClash stopped by default.

## Start OpenClash only after checks

```sh
/etc/init.d/openclash start
sleep 8
tail -n 160 /tmp/openclash.log 2>/dev/null || true
nslookup github.com 127.0.0.1 || true
curl -I -L --connect-timeout 5 --max-time 12 https://openwrt.org
```

## Rollback OpenClash files

```sh
sh /tmp/openclash_rollback.sh /root/openclash-safeops-backup-YYYYmmdd-HHMMSS
```

This intentionally restores only OpenClash files by default. Network/DHCP/firewall restore requires explicit confirmation.

## High-risk restore of network/dhcp/firewall

Only if user confirms and understands lockout risk:

```sh
cp -a "$BACKUP_DIR/etc/config/network" /etc/config/network
cp -a "$BACKUP_DIR/etc/config/dhcp" /etc/config/dhcp
cp -a "$BACKUP_DIR/etc/config/firewall" /etc/config/firewall
/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
# Avoid /etc/init.d/network restart unless physically present or failsafe/serial available.
```
