# Playbook: Subscription Repair

## Preconditions

- SSH works.
- Router can resolve DNS and reach HTTPS.
- Backup exists before writing.

## Diagnose

1. Check time and CA.
2. Check subscription host DNS.
3. Fetch with curl header first.
4. Identify content type.
5. If conversion is used, test conversion endpoint.
6. Lint converted YAML.

## Repair branches

- Wrong time: fix NTP/time source if safe; do not change network.
- CA missing: install or repair CA only if opkg works and user agrees.
- Expired URL/403/login page: ask user for valid subscription; do not guess.
- Conversion unavailable: switch converter only after user approves.
- YAML group mismatch: run group detect + lint and repair OpenClash config/rules.

## Verification

- Subscription updates successfully.
- Config contains proxies/proxy-groups/rules.
- OpenClash logs no parse errors.
