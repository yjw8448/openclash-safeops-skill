# Official OpenClash Wiki Summary

## Scope

The official Wiki is the highest-priority reference for OpenClash behavior, UI areas, and configuration concepts.

## Key facts for this skill

- OpenClash is a Clash-style client that runs on OpenWrt and uses rule-based traffic policy routing.
- The Wiki includes pages for installation, status, quick setup, subscription settings, configuration file writing, general settings, DNS settings, rule/access-control settings, and external controller.
- Configuration files use YAML/YML. The expected major parts are basic settings, server/proxy information, strategy group information, and rules. Do not reorder or corrupt these sections.
- DNS is a high-risk area because OpenClash local DNS, dnsmasq, and other DNS plugins can conflict.
- Rule/access-control features depend on rule order and actual strategy group mapping.

## How to use this in troubleshooting

### Subscription problem

Route to subscription settings and check: subscription type, conversion need, URL reachability, system time, CA, DNS, and whether the response is YAML/base64 or an error page.

### Config problem

Route to config-file page and check: YAML validity, major sections, strategy group references, rule references, proxy-provider/rule-provider availability, and generated file path.

### DNS problem

Route to DNS settings and check: local DNS hijack, dnsmasq upstream, port 53 listener, OpenClash DNS listen port, and conflicts with SmartDNS/AdGuard/MosDNS/HomeProxy.

### Rule problem

Route to rule/access-control page and check: rule order, `MATCH`, custom rules versus subscription rules, and strategy group names.

### Dashboard/API problem

Route to external controller and check: external-controller bind address, port, secret, core status, and firewall exposure.
