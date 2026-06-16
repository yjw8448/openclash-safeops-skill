# Source Map

## Official OpenClash Wiki

URL: https://github.com/vernesong/OpenClash/wiki

Authority level: highest for OpenClash plugin behavior and UI concepts.

Operational takeaways:

- OpenClash is an OpenWrt Clash client with rule-based traffic policy routing.
- The manual covers installation, status, quick setup, subscription settings, config file writing, general settings, DNS settings, rule/access-control settings, external controller, and updates.
- Use official Wiki areas to route symptoms: subscription problems to subscription settings; DNS failures to DNS settings; rule failures to rule/access-control; YAML/config failures to config file; dashboard/API failures to external controller.

Safety translation:

- Treat official settings as UI-level guidance, not permission to rewrite OpenWrt network files.
- Prefer LuCI or OpenClash UCI options over editing `/etc/config/network`, `/etc/config/dhcp`, or `/etc/config/firewall`.

## OpenClash Config File Wiki

URL: https://raw.githubusercontent.com/wiki/vernesong/OpenClash/%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.md

Operational takeaways:

- Config files are YAML/YML and should be named `config.yaml` or `config.yml` when uploaded.
- Major sections are basic settings, proxies/server information, proxy groups/server-group information, and rules.
- The order of those sections matters; a malformed or reordered config can make OpenClash behave abnormally.
- Strategy group and rules sections must be kept valid; rules target strategy groups, so group names must match real groups.

Safety translation:

- Always lint YAML before applying.
- Always detect actual group names before adding AI/dev/streaming rules.
- Do not replace a user's config with a template until the current config is backed up.

## OpenClash DNS Wiki

URL: https://raw.githubusercontent.com/wiki/vernesong/OpenClash/DNS%E8%AE%BE%E7%BD%AE.md

Operational takeaways:

- OpenClash uses local DNS hijacking by default because the Clash core includes a DNS server.
- OpenClash should be the only upstream DNS server for dnsmasq, or DNS hijacking/forwarding by other plugins must be carefully coordinated.
- Fake-IP and Redir-Host modes have different DNS recommendations.
- IPv6 DNS parsing should not be enabled blindly; environments without public IPv6/NAT can break DNS or connectivity.
- Fake-IP advanced settings/fake-ip-filter can be needed for services that break under fake IP responses.

Safety translation:

- Audit port 53/7874/6053/6553 before changing DNS.
- Treat SmartDNS, MosDNS, AdGuardHome, HomeProxy, PassWall DNS interception as potential conflicts.
- DNS repair should usually stop OpenClash, restart dnsmasq, verify router DNS, then re-enable OpenClash after config passes.

## OpenClash Subscription Wiki

URL: https://raw.githubusercontent.com/wiki/vernesong/OpenClash/%E8%AE%A2%E9%98%85%E8%AE%BE%E7%BD%AE.md

Operational takeaways:

- OpenClash accepts Clash-type subscriptions and can use API conversion for Surge/V2Ray-type subscriptions.
- Third-party rule subscriptions only take effect when the relevant third-party rules feature is enabled.
- GEOIP database subscriptions are used for fallback IP classification after earlier rules fail.

Safety translation:

- First identify whether the subscription is Clash YAML, base64/V2Ray, Surge, converted YAML, or an error HTML page.
- Check time, DNS, CA certificates, curl/wget, and conversion endpoint before modifying OpenClash.

## OpenClash Rule/Access-Control Wiki

URL: https://raw.githubusercontent.com/wiki/vernesong/OpenClash/%E8%A7%84%E5%88%99%E8%AE%BE%E7%BD%AE%EF%BC%88%E8%AE%BF%E9%97%AE%E6%8E%A7%E5%88%B6%EF%BC%89.md

Operational takeaways:

- Custom rules can be added alongside subscription/managed config and are not affected by subscription updates.
- Rule order matters; earlier rules take priority.
- Rules can match DOMAIN-SUFFIX, DOMAIN-KEYWORD, DOMAIN, IP-CIDR, SRC-IP-CIDR, DST-PORT, and SRC-PORT.
- Third-party rules require uploading/downloading a config first so OpenClash can read server strategy group information, then mapping each rule category to an actual strategy group.

Safety translation:

- Do not assume `Proxy`, `AI`, or `Auto` group names.
- Never add final/MATCH above specific rules.
- Put LAN/private/router direct rules before proxy rules.

## Aethersailor Custom_OpenClash_Rules Wiki

URL: https://github.com/Aethersailor/Custom_OpenClash_Rules/wiki/OpenClash-%E8%AE%BE%E7%BD%AE%E6%96%B9%E6%A1%88

Authority level: useful community baseline for Fake-IP and template/overwrite design; not official OpenClash behavior.

Operational takeaways:

- Uses Fake-IP mode.
- Relies on OpenClash mainland-bypass behavior.
- Recommends template + overwrite instead of hand-written incomplete YAML.
- Emphasizes reducing DNS plugin nesting and using OpenClash itself where possible.
- Main-router scenario is the assumed baseline; side-router setups need extra caution.

Safety translation:

- Use as a profile, not a universal rule.
- Do not apply its network or IPv6 assumptions blindly to side-router or unusual topologies.
- Good for one-click profile generation when user wants Fake-IP and maintainable rules.

## FFAni OpenClash Recommended Config Guide

URL: https://ffani.com/post/openwrt-openclash-recommended-config-guide/

Authority level: community compatibility guide, especially for Redir-Host, SmartDNS, IPv6, and DNS leak checks.

Operational takeaways:

- Recommends Redir-Host compatibility mode.
- Focuses on IPv6 optimization, SmartDNS integration, DNS leak prevention, and optional ad blocking.
- Uses Dnsmasq forwarding and SmartDNS CN/GW grouping in the guide.
- Mentions DNS leak verification using external leak-test websites.

Safety translation:

- Treat IPv6, SmartDNS, and DHCP/DNS changes as medium/high risk.
- Do not change OpenWrt IPv6 WAN/LAN/DHCP settings from this skill unless user explicitly approves.
- Use this as an optional profile when Fake-IP causes compatibility problems or SmartDNS already exists.

## Local Policy Additions

### v5
- `docs/MULTI_SUBSCRIPTION_ISOLATION.md` - Local SafeOps policy for preserving user-defined subscription/config boundaries.
- `docs/kb/75-multi-subscription-decision-tree.md` - Decision tree for multi-subscription audits and accidental merge recovery.


### v7.4

- `docs/kb/81-report-generation-and-sync.md` - Report freshness, latest-report plus timestamped snapshot policy, and local/router report sync handling.
- `docs/kb/82-active-config-update-url-binding.md` - Active `config_path`, `config_update_url`, and `auto_update` consistency checks for cases where selecting one YAML automatically switches back to another provider.
- `docs/kb/83-local-ssh-helper-hygiene.md` - Local WorkBuddy SSH helper handling policy: audit for embedded secrets, do not delete reusable helper scripts unless the user explicitly asks.
