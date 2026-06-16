# Watchdog Usage

Use watchdog when applying medium-risk OpenClash changes such as DNS mode, Fake-IP/Redir-Host, overwrite files, or active YAML replacement.

## Start

```sh
sh openclash_backup.sh
sh openclash_watchdog.sh --start /root/openclash-safeops-backup-YYYYmmdd-HHMMSS --timeout 300 --interval 30 --failures 3
```

## Disarm

Only after verification succeeds:

```sh
sh openclash_verify_connectivity.sh
sh openclash_watchdog.sh --disarm
```

## Status

```sh
sh openclash_watchdog.sh --status
```

## Rollback scope

Watchdog restores OpenClash files only and restarts dnsmasq/uhttpd. It intentionally avoids network/dhcp/firewall changes.
