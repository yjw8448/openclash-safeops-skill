# LuCI Click Guide

Some OpenClash settings change option names between versions. When unsure, do not blindly set UCI values. Use LuCI and document the target page.

Common locations:

- OpenClash → 运行状态: core status, dashboard/API, runtime logs.
- OpenClash → 全局设置 / 常规设置: running mode, core mode, bypass settings.
- OpenClash → DNS 设置: Fake-IP/Redir-Host DNS, dnsmasq forwarding, local DNS hijack.
- OpenClash → 规则设置（访问控制）: rules and access control.
- OpenClash → 覆写设置: custom overwrite snippets, GitHub address modification/CDN.
- OpenClash → 配置订阅: subscription URL and subscription conversion template.
- OpenClash → 配置文件管理: upload/switch/export generated YAML.
- OpenClash → 外部控制: dashboard listen address, port, secret.
- OpenClash → 运行日志: startup errors, rule-provider update errors, DNS errors.

When creating a one-click plan, output which LuCI page the user should verify rather than guessing unknown UCI keys.
