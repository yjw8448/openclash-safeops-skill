# Version Compatibility Notes

OpenClash behavior depends on OpenWrt version, firewall backend, core type, and DNS plugins.

Record these before fixing:

```sh
cat /etc/openwrt_release
uname -a
opkg list-installed | grep -Ei 'openclash|mihomo|clash|dnsmasq|dnsmasq-full|nft|iptables|smartdns|adguard|mosdns'
uci show openclash | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g'
```

Compatibility areas:

- OpenWrt 21.02/22.03/23.05/24.x.
- iptables vs nftables firewall backend.
- dnsmasq vs dnsmasq-full.
- Mihomo/Meta core vs older Clash core.
- Fake-IP, Redir-Host, TUN, mixed mode.
- Whether SmartDNS/AdGuardHome/MosDNS/HomeProxy is installed.

Do not assume UCI option names are identical across OpenClash versions. Prefer LuCI mapping notes and generated overwrite files when unsure.
