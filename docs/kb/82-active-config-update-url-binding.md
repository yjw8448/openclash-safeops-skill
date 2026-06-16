# Active Config and Auto-Update URL Binding

Use this when switching to one YAML causes OpenClash to automatically return to another config, such as selecting `config-a(2).yaml` and later returning to `config-b.yaml`.

## Likely cause

OpenClash may have:

```text
config_path       = selected active YAML
config_update_url = subscription URL used by auto-update
auto_update       = enabled
```

If `config_path` points to one provider but `config_update_url` belongs to another provider, the next auto-update may rewrite or reselect the other provider's YAML.

## Read-only audit

```sh
sh scripts/openclash_active_binding_audit.sh
```

Equivalent commands:

```sh
uci get openclash.config.config_path 2>/dev/null
uci get openclash.config.auto_update 2>/dev/null
uci get openclash.config.config_update_url 2>/dev/null | sed -E 's#(http|https)://.*#<SUB_URL_REDACTED>#g'
ls -lah /etc/openclash/config/
uci show openclash | sed -E 's#(http|https)://[^ ]+#<SUB_URL_REDACTED>#g'
```

## Safe handling

Do not blindly run `uci set openclash.config.config_update_url=<raw URL>`. First ask which provider should be the current auto-update target.

### Option A: use config-a2 as current target

Set `config_path` to `config-a(2).yaml` and set `config_update_url` to the config-a subscription, after user confirmation.

### Option B: use config-b as current target

Set `config_path` to `config-b.yaml` and set `config_update_url` to the config-b subscription, after user confirmation.

### Option C: disable auto-update temporarily

Only after user confirmation, disable auto-update to prevent switching while preserving both YAML files.

## Forbidden

- Do not merge subscriptions.
- Do not delete the other YAML.
- Do not modify network/dhcp/firewall.
- Do not print raw subscription URLs.
