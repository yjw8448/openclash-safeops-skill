# Rule Design and Group Mapping

## Mandatory rule-design checks

1. LAN/private/router direct rules first.
2. User force-direct/force-proxy rules before broad domestic/fallback rules.
3. AI/dev/streaming rules before domestic direct and `MATCH`.
4. `GEOIP,CN,DIRECT` near the end, before final `MATCH`.
5. Final `MATCH` must be last or near-last depending on syntax.
6. Every rule target must be an existing strategy group or built-in target such as DIRECT/REJECT.

## Group detection

Run:

```sh
python3 scripts/openclash_group_detect.py /etc/openclash/config/*.yaml --env
```

If unavailable, inspect:

```sh
grep -n "name:" /etc/openclash/config/*.yaml | head -80
```

Map likely groups:

- AI group: `AI`, `OpenAI`, `ChatGPT`, `🤖 AI`, `人工智能`.
- Main proxy group: `Proxy`, `节点选择`, `🚀 节点选择`, `GLOBAL`, `手动切换`.
- Auto group: `Auto`, `♻️ 自动选择`, `自动选择`, `url-test` groups.
- Fallback group: `Final`, `MATCH`, `漏网之鱼`, `🐟 漏网之鱼`, or main proxy.

## Safe custom rule pattern

```yaml
rules:
  - DOMAIN-SUFFIX,local,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
  - DOMAIN-SUFFIX,openai.com,<AI_GROUP>
  - DOMAIN-SUFFIX,chatgpt.com,<AI_GROUP>
  - DOMAIN-SUFFIX,github.com,<PROXY_GROUP>
  - GEOIP,CN,DIRECT
  - MATCH,<FALLBACK_GROUP>
```

Replace placeholder group names with detected real names before applying.
