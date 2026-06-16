# 76 - Unbound Config / 无订阅信息 Decision Tree

Use this when LuCI shows a config file such as `config-a.yaml` with **无订阅信息**.

## Symptoms

- Config file exists and has an update time.
- LuCI shows no subscription information.
- User expected one subscription -> one config mapping.
- Multiple subscriptions may have been merged into one local YAML.

## Decision tree

### 1. Is there a visible subscription URL in UCI or `/etc/openclash`?

Run:

```sh
sh scripts/openclash_no_subinfo_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
```

Outcomes:

- `subscription_url_count=0`: treat YAML as local/manual; re-add subscriptions or restore UCI backup.
- `subscription_url_count=1`: check whether selected YAML basename appears in UCI.
- `subscription_url_count>1`: multi-subscription risk; enforce one subscription -> one config.

### 2. Does the YAML basename appear in UCI?

- Yes: it may be bound; check exact subscription section and update settings.
- No: treat as unbound/orphan; do not update it as a subscription-managed config.

### 3. Is the YAML suspected to be merged?

Indicators:

- It contains nodes/groups from both subscription providers.
- It was modified at the same time WorkBuddy repaired subscriptions.
- Multiple original YAML files disappeared or now have identical checksums.
- LuCI shows only one config after a multi-subscription repair.

### 4. Recovery path

Prefer:

1. Restore pre-merge backup of `/etc/config/openclash` and `/etc/openclash/`.
2. If no backup exists, quarantine current YAML and re-add subscriptions in LuCI.
3. If user has both original subscription URLs, rebuild two separate subscription records.
4. Start only the user-selected profile after verification.

## Stop conditions

Stop and ask the user if:

- the skill cannot identify which YAML belongs to which subscription;
- only a no-subscription YAML remains;
- multiple subscription URLs exist but only one YAML exists;
- two YAMLs have identical fingerprints after a repair.
