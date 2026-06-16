# Troubleshooting Matrix: symptom -> checks -> repair path

## 1. Router can be pinged, SSH works, but clients cannot browse

Risk: low to medium.

Checks:

```sh
ip route
/etc/init.d/openclash status || true
/etc/init.d/dnsmasq status || true
ss -lntup 2>/dev/null | grep -E ':53 |7874|7890|7891|7892|7893|7895|9090' || true
nslookup openwrt.org 127.0.0.1 || true
nslookup baidu.com 127.0.0.1 || true
nslookup github.com 127.0.0.1 || true
tail -n 160 /tmp/openclash.log 2>/dev/null || true
```

Low-risk repair:

```sh
sh /tmp/openclash_backup.sh
/etc/init.d/openclash stop
/etc/init.d/dnsmasq restart
nslookup openwrt.org 127.0.0.1
curl -I -L --connect-timeout 5 --max-time 12 https://openwrt.org
```

Leave OpenClash stopped until config/log root cause is clear.

## 2. OpenClash starts, then internet dies

Likely causes:
- DNS hijack conflict.
- Fake-IP incompatibility.
- Core starts but crashes after setting firewall rules.
- YAML valid but group/rule invalid at runtime.

Checks:

```sh
tail -n 220 /tmp/openclash.log 2>/dev/null || true
logread | grep -Ei 'openclash|clash|mihomo|dnsmasq|firewall' | tail -220
ps w | grep -Ei 'openclash|clash|mihomo' | grep -v grep || true
```

Repair path:
1. Stop OpenClash.
2. Restart dnsmasq.
3. Validate DNS.
4. Validate YAML.
5. Switch only OpenClash profile/mode after backup.
6. Do not restart network.

## 3. LuCI cannot open, SSH still works

Likely causes:
- Browser proxy issue.
- uhttpd stopped.
- Port conflict.

Checks:

```sh
/etc/init.d/uhttpd status || true
ss -lntup 2>/dev/null | grep -E ':80 |:443 |uhttpd' || true
logread | grep -i uhttpd | tail -80
```

Low-risk repair:

```sh
/etc/init.d/uhttpd restart
```

Do not change LAN IP.

## 4. SSH and LuCI both unavailable

This skill cannot execute SSH repair. Give physical recovery steps:

1. Connect by Ethernet directly to LAN.
2. Disable computer proxy/VPN.
3. Try likely gateways shown by OS network details.
4. Try failsafe mode if OpenWrt supports it.
5. Restore backup or reset network from serial/failsafe.

Do not provide more SSH commands as if SSH were available.

## 5. Subscription update fails

Likely causes:
- System time wrong.
- DNS broken.
- CA certificates missing.
- Subscription URL blocked/down.
- Subconverter/template unavailable.
- Node protocol unsupported by current core.

Checks:

```sh
date
nslookup github.com 127.0.0.1 || true
curl -I -L --connect-timeout 8 --max-time 20 https://github.com 2>&1 | head -40 || true
opkg list-installed | grep -Ei 'ca-bundle|ca-certificates|curl|wget-ssl' || true
uci show openclash 2>/dev/null | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g'
```

Repair path:
- Fix time/DNS first.
- Use LuCI subscription update after DNS works.
- Do not expose full subscription URLs.

## 6. YAML parse error or policy group error

Checks:

```sh
find /etc/openclash -maxdepth 3 -type f \( -name '*.yaml' -o -name '*.yml' \) -print
python3 /tmp/openclash_yaml_lint.py /etc/openclash/config/config.yaml
```

Repair path:
- Restore previous backup or use known-good generated config.
- Verify every rule's target group exists.
- Verify rule-provider paths and behavior.
- Avoid manual direct edits to generated YAML unless necessary.

## 7. AI/GitHub rules do not take effect

Checks:
- Rule order: custom rules must appear before CN direct/MATCH.
- Group names: `AI`, `Proxy`, `DIRECT` must exist.
- Domain format: use DOMAIN-SUFFIX or rule-provider payload correctly.
- Cache: restart OpenClash after rule-provider update.

Repair path:
- Use `scripts/openclash_rule_generator.sh` to generate a snippet.
- Apply through overwrite/rule-provider.
- Restart OpenClash only, not network.

## 8. SmartDNS integration breaks DNS

Risk: medium.

Checks:

```sh
/etc/init.d/smartdns status || true
ss -lntup 2>/dev/null | grep -E '6053|6553|53|7874'
uci show smartdns 2>/dev/null | sed -E 's/(password|token|secret)=.*/\1=***REDACTED***/'
```

Repair path:
- Decide single DNS chain.
- Do not let OpenClash, SmartDNS, AdGuardHome, and dnsmasq all hijack port 53 at once.
- If uncertain, stop OpenClash and SmartDNS, restart dnsmasq, then rebuild.

## 9. IPv6 only works sometimes

Risk: high if changing OpenWrt network/dhcp.

Checks:

```sh
ip -6 addr
ip -6 route
uci show network | grep -Ei 'ip6|delegate|wan6|prefix|ra|dhcpv6' || true
uci show dhcp | grep -Ei 'ra|dhcpv6|ndp|dns|aaaa' || true
```

Repair path:
- For OpenClash-only IPv6 toggles, treat as medium risk.
- For OpenWrt WAN/LAN IPv6-PD/RA/DHCPv6, ask for explicit confirmation.
