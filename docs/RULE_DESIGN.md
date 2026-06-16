# Rule Design

## Principle

Rules must be ordered from most specific and safest to most general. Never place `MATCH` before custom rules.

## Recommended order

```yaml
rules:
  # 1. LAN/private direct
  - DOMAIN-SUFFIX,local,DIRECT
  - DOMAIN-SUFFIX,lan,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
  - IP-CIDR,127.0.0.0/8,DIRECT,no-resolve

  # 2. User force direct/proxy
  - DOMAIN-SUFFIX,example-direct.com,DIRECT
  - DOMAIN-SUFFIX,example-proxy.com,Proxy

  # 3. AI/dev
  - DOMAIN-SUFFIX,openai.com,AI
  - DOMAIN-SUFFIX,chatgpt.com,AI
  - DOMAIN-SUFFIX,anthropic.com,AI
  - DOMAIN-SUFFIX,claude.ai,AI
  - DOMAIN-SUFFIX,github.com,Proxy
  - DOMAIN-SUFFIX,githubusercontent.com,Proxy
  - DOMAIN-SUFFIX,docker.com,Proxy
  - DOMAIN-SUFFIX,docker.io,Proxy

  # 4. Domestic direct
  - GEOSITE,cn,DIRECT
  - GEOIP,CN,DIRECT

  # 5. Fallback
  - MATCH,Proxy
```

## Validate strategy groups

Before applying, verify the target group names exist:

```sh
grep -n '^proxy-groups:' -A220 /etc/openclash/config/config.yaml | sed -n '1,220p'
```

If the YAML contains `AI` or `Proxy` rules, `AI` and `Proxy` groups must exist.

## Rule-provider payload example

```yaml
payload:
  - DOMAIN-SUFFIX,openai.com
  - DOMAIN-SUFFIX,chatgpt.com
  - DOMAIN-SUFFIX,anthropic.com
  - DOMAIN-SUFFIX,claude.ai
```

Then use it in rules with your chosen behavior, if supported by the current core/OpenClash setup.

## Common mistakes

- Putting custom rules after `MATCH`.
- Using group names that do not exist.
- Mixing Clash classical rules and domain-only payloads incorrectly.
- Placing local/LAN IP ranges after proxy rules.
- Editing generated YAML directly without preserving section order.
