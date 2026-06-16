# Unbound Config / “无订阅信息” Recovery

This document handles the OpenClash LuCI state where a profile, for example `config-a.yaml`, appears as a config file but shows **无订阅信息**.

## Meaning

In this skill, `无订阅信息` means the YAML exists as a config file but the skill must **not** assume it is still connected to the original OpenClash subscription record. It may be:

- a manual/local YAML;
- a generated YAML created by an assistant;
- a backup/restored YAML with lost UCI subscription metadata;
- a merged YAML containing data from multiple subscriptions;
- a correct YAML whose subscription binding needs to be re-created in LuCI.

## Hard rule

Do not update, overwrite, merge, delete, or make this YAML the sole active source until the subscription binding has been audited.

## Required workflow

1. Back up the current bad/no-subinfo state.
2. Run `openclash_no_subinfo_audit.sh`.
3. Run `openclash_subscription_binding_audit.sh`.
4. Determine whether there are zero, one, or multiple subscription URLs.
5. Determine whether the displayed YAML basename appears in `/etc/config/openclash`.
6. Look for pre-merge or pre-unbound backups.
7. Restore only `/etc/config/openclash` and `/etc/openclash/` from a confirmed good backup, or ask the user to re-add subscriptions in LuCI.

## Never do

- Do not merge two subscriptions into one YAML.
- Do not treat `config-a.yaml` as authoritative just because it is selected.
- Do not print full subscription URLs.
- Do not modify `/etc/config/network`, `/etc/config/dhcp`, or `/etc/config/firewall`.
- Do not restart network.
