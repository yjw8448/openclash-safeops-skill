# Emergency Mode

Use when SSH is available but OpenClash broke internet, DNS, or LuCI.

Dry-run:

```sh
sh openclash_emergency_restore.sh
```

Apply:

```sh
sh openclash_emergency_restore.sh --apply
```

This script:

- Stops OpenClash.
- Kills orphaned Clash/Mihomo cores after service stop.
- Restarts dnsmasq.
- Restarts uhttpd if LuCI is down.
- Runs basic route/DNS/HTTP verification.

It does not:

- Restart network.
- Change LAN IP.
- Change DHCP.
- Change firewall.
- Reboot.
