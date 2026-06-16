# Multi-Subscription Isolation

Version 5 adds a hard rule: **one subscription boundary must not be crossed by automated repair**.

A user may intentionally maintain multiple OpenClash subscriptions and multiple generated configuration files, for example:

```text
Subscription A -> Config A.yaml
Subscription B -> Config B.yaml
```

A repair agent must not convert that into:

```text
Subscription A + Subscription B -> merged.yaml
```

unless the user explicitly asks for a merge and approves a merge plan after seeing the risk.

## Why this matters

OpenClash subscriptions are often converted into generated YAML files with different:

- proxy node names,
- proxy groups,
- rule providers,
- DNS sections,
- fake-ip filters,
- provider URLs,
- custom overwrite behavior.

Mixing two unrelated subscriptions can cause:

- duplicate node names,
- broken strategy-group references,
- unexpected fallback group selection,
- subscription update overwriting the wrong YAML,
- rule providers from one profile being applied to another,
- accidental credential leakage between profiles,
- inability to restore the user's intended active profile.

## Non-negotiable policy

Before any operation that writes OpenClash subscription/config data, run a multi-subscription audit or equivalent checks.

Required checks:

1. Count subscription-like URLs in `/etc/config/openclash` and `/etc/openclash`.
2. List YAML files under `/etc/openclash/config`, `/etc/openclash`, and known backup paths.
3. Identify active/selected config references from UCI where possible.
4. Fingerprint each YAML before writing.
5. If more than one subscription and more than one YAML/config profile exist, preserve the one-to-one mapping.
6. If the mapping cannot be proven, stop and ask the user.

## Allowed automated operations

Allowed without crossing subscription boundaries:

- Read-only audit.
- Backup current bad/merged state.
- Restore `/etc/config/openclash` and `/etc/openclash/` from a known pre-merge backup.
- Update only the currently active subscription when the active mapping is known.
- Generate rule snippets into `/etc/openclash/safeops/` without attaching them to a profile.
- Validate a single specified YAML file.

## Forbidden operations without explicit user approval

- Merge nodes from two subscriptions.
- Merge two `proxy-groups` sections.
- Merge two rule stacks.
- Replace two YAML files with one YAML file.
- Move a subscription URL from one config profile to another.
- Infer that two subscriptions should share one generated config.
- Delete the bad merged config before creating a backup.

## Recommended recovery flow after accidental merge

1. Stop all write operations.
2. Backup the current bad merged state:
   ```sh
   BAD_DIR="/root/openclash-bad-merged-$(date +%Y%m%d-%H%M%S)"
   mkdir -p "$BAD_DIR"
   cp -a /etc/config/openclash "$BAD_DIR/openclash.uci" 2>/dev/null || true
   cp -a /etc/openclash "$BAD_DIR/openclash-dir" 2>/dev/null || true
   echo "BAD_MERGED_BACKUP=$BAD_DIR"
   ```
3. Find SafeOps backup directories and old YAML files.
4. Compare config fingerprints.
5. Restore only `/etc/config/openclash` and `/etc/openclash/` from a confirmed pre-merge backup.
6. Do not restore `/etc/config/network`, `/etc/config/dhcp`, or `/etc/config/firewall`.
7. Verify that two subscription/config profiles exist again.
8. Ask the user which profile should be active.

## Naming convention for future operations

When creating new assets, never use generic names like `config.yaml` for multi-subscription repairs. Use explicit names:

```text
safeops-sub-a.generated.yaml
safeops-sub-b.generated.yaml
safeops-rules-common.yaml
safeops-rules-ai.yaml
safeops-rules-dev.yaml
```

If the original OpenClash version stores generated profiles with internal IDs, preserve those IDs and do not rename unless the user requests it.
