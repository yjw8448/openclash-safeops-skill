# OpenWrt Operational Safety

This document defines the OpenWrt-layer safety boundary for OpenClash SafeOps.

## Core rule

SafeOps repairs OpenClash. It does not perform general OpenWrt system network administration during normal workflows.

Normal OpenClash repair must not modify:

- `/etc/config/network`
- `/etc/config/dhcp`
- `/etc/config/firewall`
- LAN IP
- DHCP ranges
- WAN/LAN interface definitions
- bridge interfaces such as `br-lan`
- firewall zones
- Wi-Fi interface state

Normal OpenClash repair must not run:

- `/etc/init.d/network restart`
- `uci commit network`
- `uci commit dhcp`
- `uci commit firewall`
- `reboot`
- `firstboot`
- `jffs2reset`
- `sysupgrade`
- `mtd`
- mass firewall flush commands

## Allowed low-risk service operations

Emergency mode may use these when SSH is still available and the goal is basic recovery:

```sh
/etc/init.d/openclash stop
/etc/init.d/dnsmasq restart
/etc/init.d/uhttpd restart
```

Use them only after explaining the risk and preserving logs when possible.

## If SSH works

SafeOps may:

1. Stop OpenClash.
2. Kill orphaned Clash/OpenClash core processes if they keep hijacking traffic.
3. Restart dnsmasq and uhttpd.
4. Back up OpenClash config.
5. Read UCI OpenClash settings.
6. Read logs.
7. Generate candidate YAML.
8. Validate candidate YAML.
9. Write only the approved OpenClash target after backup and user approval.

SafeOps must not silently fix broken OpenWrt network configuration.

## If SSH does not work

SafeOps cannot safely perform remote repair.

Recommended escalation:

1. Try LuCI from the known router IP.
2. Try wired Ethernet to the LAN port.
3. Try the router's known fallback IP.
4. Enter OpenWrt failsafe mode if supported.
5. Use serial/recovery image/vendor recovery if the device is inaccessible.
6. Factory reset only as a last resort.

Do not pretend SSH commands can be executed when SSH is unavailable.

## Backup visibility

Before OpenClash writes, it is acceptable to copy or display checksums of these files for rollback visibility:

```text
/etc/config/openclash
/etc/openclash/
/etc/config/network
/etc/config/dhcp
/etc/config/firewall
```

But only OpenClash paths may be modified during normal workflows.

## DNS safety

DNS problems often involve dnsmasq, OpenClash, and additional DNS plugins.

Read-only audit first:

```sh
netstat -lntup 2>/dev/null | grep -E ':(53|7874|6053|6553)\b'
uci show openclash 2>/dev/null | sed -E 's#(http|https)://[^ ]+#<redacted-url>#g'
logread | grep -iE 'openclash|dnsmasq|smartdns|mosdns|adguard' | tail -n 120
```

Manual review is required before changing DHCP DNS forwarding, dnsmasq upstreams, SmartDNS, MosDNS, AdGuardHome, HomeProxy, or PassWall.

## Recovery wording

When the router is already inaccessible, say plainly:

```text
SSH is unavailable, so this Skill cannot safely repair the router remotely. Use LuCI if reachable, otherwise use wired LAN, failsafe, serial, vendor recovery, or physical reset workflow.
```
