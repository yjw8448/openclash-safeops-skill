# Official Wiki Reference Map

This file maps OpenClash SafeOps actions to the official OpenClash Wiki areas.

## Home / positioning

OpenClash is treated as an OpenWrt LuCI client for Clash/Mihomo-style rule proxying. It supports strategy routing based on flexible rules.

Skill usage:
- Only administer routers the user owns or manages.
- Do not treat OpenClash as a general law-bypass tool.
- Prefer troubleshooting and safe configuration.

## Installation / uninstallation

Use for:
- OpenClash menu missing.
- `/etc/init.d/openclash` missing.
- Package installed but LuCI page absent.
- Core missing after installation.

SSH checks:

```sh
opkg list-installed | grep -i openclash || true
ls -l /etc/init.d/openclash /usr/lib/lua/luci/controller/openclash.lua 2>/dev/null || true
logread | grep -Ei 'openclash|opkg|luci' | tail -120
```

Do not auto-install packages unless the user explicitly asks and the device has internet/disk space.

## Status page

Use for:
- OpenClash is stopped.
- Core crashes.
- Dashboard cannot connect.
- Ports are not listening.

SSH checks:

```sh
/etc/init.d/openclash status || true
ps w | grep -Ei 'openclash|clash|mihomo' | grep -v grep || true
ss -lntup 2>/dev/null | grep -E '7890|7891|7892|7893|7895|9090|7874|53' || true
```

## Quick/general settings

Use for:
- Rule/Global/Direct mode questions.
- Fake-IP vs Redir-Host.
- TUN mode questions.
- Bypass mainland China.
- LAN device access control.

Safety notes:
- OpenClash settings can be medium risk because DNS/routing affects all clients.
- Do not change OpenWrt network/dhcp/firewall by default.

## Subscription settings

Use for:
- Subscription update fails.
- Subscription conversion template selection.
- Aethersailor-style templates.
- Node list empty after update.

SSH checks:

```sh
date
uci show openclash 2>/dev/null | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g'
nslookup github.com 127.0.0.1 || true
curl -I -L --connect-timeout 8 --max-time 20 https://github.com 2>&1 | head -40 || true
```

Never print full subscription URLs in user-visible output.

## Config file page

Use for:
- YAML parse errors.
- Wrong file name.
- Missing proxy-groups.
- Rules referencing nonexistent groups.

Key assumptions:
- Config should be YAML/YML.
- Common active names include `config.yaml` or `config.yml` depending on OpenClash version/config.
- Config section order matters: base settings -> proxies -> proxy groups -> rules.

SSH checks:

```sh
find /etc/openclash -maxdepth 3 -type f \( -name '*.yaml' -o -name '*.yml' \) -print
python3 - <<'PY' /etc/openclash/config/config.yaml
import sys, yaml
p=sys.argv[1]
with open(p, encoding='utf-8') as f:
    y=yaml.safe_load(f)
print('YAML OK', type(y).__name__)
PY
```

## DNS settings

Use for:
- Devices cannot browse after OpenClash starts.
- `nslookup` fails.
- Fake-IP conflict.
- SmartDNS/AdGuard/HomeProxy conflict.
- DNS leak complaints.

Primary rule:
- Coordinate DNS hijacking. dnsmasq should not have multiple competing upstream hijackers. If OpenClash local DNS hijack is enabled, other DNS hijack plugins should be disabled or moved upstream in a deliberate chain.

SSH checks:

```sh
uci show dhcp | grep -Ei 'dns|server|bogus|rebind|filter|aaaa' || true
ss -lnup 2>/dev/null | grep ':53 ' || true
ss -lntup 2>/dev/null | grep -E '7874|6053|6553|53' || true
nslookup openwrt.org 127.0.0.1 || true
nslookup baidu.com 127.0.0.1 || true
nslookup github.com 127.0.0.1 || true
```

## Rule/access-control settings

Use for:
- AI/GitHub/streaming rules.
- LAN/NAS direct rules.
- Devices force direct/proxy.
- Google Play regional exceptions.
- Rule order issues.

Rule order:
1. LAN/private direct.
2. Router/NAS/printer direct.
3. User force rules.
4. AI/dev/streaming proxy groups.
5. CN direct.
6. MATCH fallback.

## External control

Use for:
- Dashboard cannot open.
- RESTful API 9090 inaccessible.
- Secret/token mismatch.

SSH checks:

```sh
ss -lntup 2>/dev/null | grep 9090 || true
grep -R "external-controller\|secret\|external-ui" /etc/openclash 2>/dev/null | sed -E 's/(secret:).*/\1 ***REDACTED***/'
```

## Update page

Use for:
- Core missing/outdated.
- GEO/MMDB/geosite/rule-provider missing.
- OpenClash update interrupted.

SSH checks:

```sh
ls -lah /etc/openclash/core /etc/openclash 2>/dev/null || true
find /etc/openclash -maxdepth 3 -type f | grep -Ei 'Country|Geo|geosite|mmdb|metacubex|mihomo|clash' || true
```
