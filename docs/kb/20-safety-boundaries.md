# Safety Boundaries

## Always allowed read-only operations

- `cat /etc/openwrt_release`
- `ip addr`, `ip route`
- `uci show openclash` with secrets redacted
- `logread | grep -i openclash`
- `netstat -lntup` or `ss -lntup`
- `nslookup`, `ping`, `curl -I --connect-timeout`
- list files under `/etc/openclash`, `/etc/config`

## Allowed low-risk repair after backup

- Stop/start/restart OpenClash.
- Restart dnsmasq after config audit.
- Restart uhttpd if LuCI is down.
- Kill orphaned `clash`/`mihomo` after OpenClash stop.
- Clear OpenClash temporary cache/log artifacts when documented.
- Validate config and switch to a known-good OpenClash config after backup.

## Medium-risk repair: backup + watchdog required

- OpenClash DNS mode change.
- Fake-IP/Redir-Host/TUN option change.
- OpenClash overwrite/rule-provider changes.
- Subscription conversion template changes.
- SmartDNS integration inside OpenClash.
- Replacing active OpenClash YAML.

## High-risk: explicit user confirmation required

- `/etc/config/network` edits.
- `/etc/config/dhcp` edits.
- `/etc/config/firewall` edits.
- LAN IP, WAN/LAN, bridge, Wi-Fi changes.
- `/etc/init.d/network restart`.
- `reboot`, `firstboot`, `sysupgrade`.
- firewall flush or default policy change.
- OpenWrt IPv6 RA/DHCPv6/WAN6 changes.

## Mandatory masking

Mask subscription URLs, proxy usernames/passwords, dashboard secret, UUIDs, node server hostnames if they identify the provider, and private topology when not necessary.
