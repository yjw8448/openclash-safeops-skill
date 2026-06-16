# Symptom Router

Use this table before running repair commands.

| Symptom | Read first | First safe action | Do not do |
|---|---|---|---|
| SSH unavailable | `20-safety-boundaries.md` | Stop. Use LuCI/failsafe guidance. | Do not pretend to SSH repair. |
| SSH works but clients cannot browse | `playbooks/emergency-restore.md`, `60-dns-decision-tree.md` | Stop OpenClash, restart dnsmasq/uhttpd, verify DNS. | Do not restart network. |
| LuCI refused but SSH works | `playbooks/emergency-restore.md` | Restart uhttpd only; stop OpenClash if it broke DNS. | Do not reboot first. |
| Subscription cannot update | `70-subscription-decision-tree.md`, `playbooks/subscription-repair.md` | Check time, DNS, CA, curl, subscription response type. | Do not replace config before checking URL response. |
| Subscription downloads HTML/403/login | `70-subscription-decision-tree.md` | Tell user subscription is invalid/expired/protected. | Do not convert HTML into YAML. |
| OpenClash starts then exits | `playbooks/config-lint-and-group-detect.md` | Lint YAML, check groups/rules/ports/core logs. | Do not change LAN/firewall. |
| DNS sometimes fails/leaks | `60-dns-decision-tree.md`, `50-ffani-redirhost-smartdns-profile.md` | Audit dnsmasq/OpenClash/SmartDNS/MosDNS/AdGuard. | Do not stack DNS plugins blindly. |
| Rules not matching | `80-rule-design-and-group-mapping.md`, `playbooks/rule-repair.md` | Detect real group names, check order, check MATCH. | Do not assume `Proxy` group exists. |
| Fake-IP breaks apps/NTP/DDNS/LAN | `40-aethersailor-fakeip-profile.md`, `60-dns-decision-tree.md` | Add fake-ip-filter/advanced DNS exceptions; consider Redir-Host profile. | Do not disable DHCP/DNS randomly. |
| Wants one-click setup | `40-aethersailor-fakeip-profile.md`, `50-ffani-redirhost-smartdns-profile.md` | Dry-run profile; backup; watchdog before apply. | Do not apply all guide settings blindly. |


## Config file shows 无订阅信息

Route to `76-unbound-config-decision-tree.md` and `playbooks/no-subscription-info-pqjc.md`. Stop all subscription writes, back up current OpenClash state, audit binding, and restore/rebuild one subscription -> one config mapping only after user confirmation.
