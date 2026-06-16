# Mihomo Schema Compatibility

This document defines how SafeOps handles Mihomo/OpenClash core YAML fields.

## Core rule

A template field must be supported by the user's current OpenClash core. If the core version is unknown, SafeOps may generate a candidate file but must not directly apply it.

## Version-sensitive DNS fields

Treat these fields as compatibility-sensitive:

```yaml
dns:
  enhanced-mode:
  fake-ip-filter-mode:
  fake-ip-filter:
  respect-rules:
  proxy-server-nameserver:
  proxy-server-nameserver-policy:
  direct-nameserver:
  direct-nameserver-follow-policy:
  nameserver-policy:
  fallback:
  fallback-filter:
```

## Special checks

### `respect-rules`

If a template enables:

```yaml
dns:
  respect-rules: true
```

then it must also consider `proxy-server-nameserver`, because DNS traffic following routing rules needs a nameserver path for resolving proxy node domains.

Do not combine `respect-rules` and `prefer-h3` blindly.

### `fake-ip-filter-mode: rule`

This changes fake-ip filtering logic to rule-like top-down matching. It may require newer core support.

If version is unknown:

- Candidate generation: allowed.
- Direct apply: not allowed.
- Report: must warn that runtime compatibility needs verification.

### `nameserver-policy`

`nameserver-policy` is powerful but can cause unexpected DNS routing.

Before adding or changing it:

1. Preserve existing policy entries.
2. Avoid overwriting user rules.
3. Ensure entries are domain/geosite-compatible.
4. Explain whether values are CN DNS, overseas DNS, or local plugin listeners.

### `fallback` and `fallback-filter`

Fallback DNS should not be blindly disabled or enabled. It changes how domain results are classified and can affect DNS leak behavior.

For Aethersailor current-safe Fake-IP profile, conservative candidate generation may disable fallback only if documented by the template and clearly reported.

For Redir-Host + SmartDNS profile, fallback and SmartDNS listeners should be treated as manual compatibility decisions.

## Protected sections

Template application should preserve these unless the user explicitly asks otherwise:

```yaml
proxies:
proxy-groups:
proxy-providers:
```

Never merge proxy lists from multiple subscription-managed YAML files.

## Candidate report checklist

For every generated candidate, report:

- Detected core type if available.
- Detected core version if available.
- DNS mode before and after.
- Whether `respect-rules` is used.
- Whether `proxy-server-nameserver` is present.
- Whether `fake-ip-filter-mode: rule` is used.
- Whether `fallback` or `fallback-filter` changes.
- Whether protected proxy sections were preserved.
- Whether direct apply is safe or candidate-only.

## Safe default

When unsure:

```text
Generate candidate only. Lint YAML. Show diff. Do not apply until the user confirms the core version and approves the write.
```
