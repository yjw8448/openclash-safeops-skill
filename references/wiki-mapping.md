# Official Wiki mapping

Map symptoms before repairing:

- OpenClash missing/menu not shown -> Installation/uninstallation.
- Core stopped or not running -> Status page and update page.
- Subscription cannot update -> Subscription settings, system time, DNS, CA certificates, curl/wget reachability.
- YAML parse error -> Config-file page; verify file name, YAML syntax, section order, proxies, proxy groups, rule-providers, and rules.
- DNS fails or devices cannot browse -> DNS settings; check dnsmasq upstream, local DNS hijack, SmartDNS/AdGuard/HomeProxy/MosDNS conflicts.
- Rules do not work -> Rule/access-control settings; check rule order, `MATCH` position, rule-provider names, and strategy-group names.
- Dashboard/API cannot open -> External controller; check listen address, port, secret, firewall, and core status.
- Config shows `无订阅信息` -> Treat as unbound YAML; audit subscription records before updating.
