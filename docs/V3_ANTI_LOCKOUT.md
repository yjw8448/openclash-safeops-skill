# v3 Anti-Lockout Design

v3 assumes the most dangerous failure mode is not “OpenClash does not start,” but “OpenClash starts and the user loses LuCI, DNS, client internet, or SSH.”

## Protection layers

1. Read-only diagnosis first.
2. Backup before writes.
3. Watchdog before medium-risk changes.
4. Emergency restore that stops OpenClash and restarts dnsmasq/uhttpd only.
5. No default changes to network/dhcp/firewall.
6. Verify before disarming watchdog.

## Standard guarded flow

```sh
sh openclash_backup.sh
sh openclash_watchdog.sh --start /root/openclash-safeops-backup-YYYYmmdd-HHMMSS --timeout 300
# apply scoped OpenClash-only change
sh openclash_verify_connectivity.sh
sh openclash_watchdog.sh --disarm
```

## What watchdog restores

By default, watchdog restores only:

- `/etc/config/openclash`
- `/etc/openclash`

It also stops OpenClash and restarts dnsmasq/uhttpd. It does **not** restore network/dhcp/firewall because that may worsen lockout unless explicitly chosen by a human.
