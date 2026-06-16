# Aethersailor Source Snapshot for Safe Config Generation

Use this reference when applying `aethersailor-current-safe` to one existing OpenClash YAML.

## Current source judgment

- `yjw8448/Aethersailor-Custom_OpenClash_Rules` is a preserved fork/snapshot that still exposes `cfg/`, `overwrite/`, `rule/`, `wiki/`, and the `cfg/Custom_Clash.ini` subscription-conversion template.
- The source describes itself as an OpenClash configuration scheme and anti-DNS-leak rule/template example. Treat it as design guidance, not an executable installer.
- The setup scheme explicitly uses `Fake-IP` and states that it is not suitable for Redir-Host.
- The source advises using OpenClash's bypass-mainland-China behavior and OpenClash/LuCI settings instead of hand-written full YAML.
- The ad-block/Dnsmasq trick is marked deprecated/not recommended. Do not apply it automatically.
- Remote CDN/raw rules and subscription-conversion services must be health-checked before being written into a config.

## Recommended YAML-level approach

Use local candidate generation:

```text
one target YAML -> local candidate -> lint/group check -> user confirmation -> write back to same YAML only
```

Do not merge subscriptions, do not modify `proxies`, `proxy-groups`, `proxy-providers`, or subscription URLs.

## Fake-IP and DNS

Recommended direction:

```yaml
dns:
  enable: true
  listen: 127.0.0.1:7874
  ipv6: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  respect-rules: true
  use-hosts: true
  nameserver:
    - system
  fallback: []
  default-nameserver: []
```

Operational interpretation:

- Nameserver should usually use the ISP/WAN DNS appended by OpenClash, `system`, or a verified local upstream.
- If ISP DNS is unstable, list AliDNS/DNSPod DoH as a manual/LuCI option rather than blindly writing it.
- Fallback should be empty by default so non-direct domains can resolve on the outbound side.
- Avoid nesting SmartDNS/MosDNS/AdGuardHome unless the user intentionally runs that architecture.

## Sniffer

Safe candidate settings:

```yaml
sniffer:
  enable: true
  force-dns-mapping: true
  parse-pure-ip: true
  override-destination: true
  sniff:
    HTTP:
      ports: [80, 8080-8880]
      override-destination: true
    TLS:
      ports: [443, 8443]
    QUIC:
      ports: [443, 8443]
```

Only write if the user's current Mihomo/OpenClash core supports the fields, or generate as candidate only.

## Rules from Custom_Clash.ini

Core rule order from the template:

```yaml
rules:
  - GEOSITE,private,DIRECT
  - GEOIP,private,DIRECT,no-resolve
  - GEOSITE,google-cn,DIRECT
  - GEOSITE,category-games@cn,DIRECT
  - GEOSITE,category-game-platforms-download,DIRECT
  - GEOSITE,category-public-tracker,DIRECT
  - GEOSITE,openai,ChatGPT
  - GEOSITE,category-ai-!cn,AI服务
  - GEOSITE,github,GitHub
  - GEOSITE,cn,DIRECT
  - GEOIP,CN,DIRECT,no-resolve
  - MATCH,漏网之鱼
```

Map `ChatGPT`, `AI服务`, `GitHub`, `Steam`, media, and final groups to real groups already present in the user's target YAML. Never invent missing strategy groups without user approval.

## External rule URLs

The source template references CDN/raw rules such as custom direct/proxy domains, Steam CDN rules, and port-direct rules. Treat them as optional remote dependencies.

Before writing any remote `rule-providers`, run:

```sh
sh scripts/openclash_aethersailor_remote_audit.sh
```

If a URL returns 404, HTML, a login page, or timeout, skip it and use built-in local rules only.

## Subscription conversion template

The source's main subscription template is `cfg/Custom_Clash.ini`. Related variants may exist in the repo, but the skill should not depend on a remote conversion backend. When asked to generate a config, use local overlay/candidate logic unless the user explicitly provides a working converter and approves remote dependency use.
