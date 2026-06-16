# Playbook - `pqjc.yaml` Shows 无订阅信息

## Goal

Recover OpenClash subscription binding safely when LuCI shows:

```text
配置文件: pqjc.yaml
更新时间: <time>
无订阅信息
```

## Steps

### 1. Freeze writes

Do not update subscriptions, do not start one-click config, and do not overwrite YAML.

### 2. Backup bad state

```sh
BAD_DIR="/root/openclash-no-subinfo-pqjc-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BAD_DIR"
cp -a /etc/config/openclash "$BAD_DIR/openclash.uci" 2>/dev/null || true
cp -a /etc/openclash "$BAD_DIR/openclash-dir" 2>/dev/null || true
echo "BAD_STATE_BACKUP=$BAD_DIR"
```

### 3. Audit no-subscription state

```sh
sh scripts/openclash_no_subinfo_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
```

### 4. Quarantine suspicious YAML if needed

Dry-run first:

```sh
sh scripts/openclash_quarantine_unbound_config.sh /etc/openclash/config/pqjc.yaml
```

Apply only after user confirms:

```sh
sh scripts/openclash_quarantine_unbound_config.sh /etc/openclash/config/pqjc.yaml --apply
```

### 5. Find pre-merge backup

```sh
find /root /tmp /etc/openclash -maxdepth 5 -type d \
  \( -iname '*backup*' -o -iname '*safeops*' -o -iname '*merged*' -o -iname '*no-subinfo*' \) \
  2>/dev/null | sort
```

### 6. Restore only after confirmation

```sh
sh scripts/openclash_restore_multiconfig.sh <confirmed_pre_merge_backup>
sh scripts/openclash_restore_multiconfig.sh <confirmed_pre_merge_backup> --apply
```

## Validation

After recovery, verify:

- two subscription records exist if user expects two;
- each subscription maps to its own YAML;
- no full subscription URL is printed;
- OpenClash is not auto-started unless user selects a profile.
