# LuCI Navigation Map

Use this when UCI option names vary by version or the agent is not confident editing files.

## OpenClash

- OpenClash → 运行状态: service/core/dashboard/log status.
- OpenClash → 全局设置 → 常规设置: mode, ports, core, traffic control, Fake-IP/Redir-Host/TUN related UI.
- OpenClash → 全局设置 → DNS 设置: local DNS hijack, custom DNS, enhanced mode, fake-ip filters, IPv6 DNS parsing.
- OpenClash → 全局设置 → 规则设置（访问控制）: custom rules and third-party rule mapping.
- OpenClash → 全局设置 → 外部控制: dashboard/API bind, port, secret.
- OpenClash → 配置订阅: subscription URL, conversion, update schedule.
- OpenClash → 配置文件管理: upload/download/switch config.
- OpenClash → 覆写设置: overwrite snippets and generated YAML behavior.
- OpenClash → 运行日志: startup, subscription, DNS, rule, and core errors.

## OpenWrt base UI: high-risk, do not change automatically

- 网络 → 接口: WAN/LAN/IP/IPv6 settings.
- 网络 → DHCP/DNS: dnsmasq, DHCP, DNS forwarding, rebind, IPv6 DNS announcement.
- 网络 → 防火墙: zones, NAT, redirect, rules.
- 系统 → 管理权 → SSH 访问: dropbear settings.

Use LuCI guidance for these pages but do not mutate them without confirmation.
