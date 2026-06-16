#!/bin/sh
# Validate an OpenClash/Mihomo YAML config and check rule target groups.
# Usage: sh openclash_validate_config.sh /path/to/config.yaml

set -eu
CONFIG="${1:-}"
if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
  echo "Usage: sh openclash_validate_config.sh /path/to/config.yaml"
  exit 1
fi

if command -v python3 >/dev/null 2>&1; then
  python3 - "$CONFIG" <<'PY'
import sys
p=sys.argv[1]
try:
    import yaml
except Exception as e:
    print('ERROR: python3 yaml module is missing:', e)
    sys.exit(2)
with open(p, 'r', encoding='utf-8') as f:
    data=yaml.safe_load(f)
if not isinstance(data, dict):
    print('ERROR: top-level YAML is not a mapping')
    sys.exit(3)
print('YAML OK:', p)
required_order=['proxies','proxy-groups','rules']
keys=list(data.keys())
print('top_level_keys:', ', '.join(keys))
missing=[k for k in required_order if k not in data]
if missing:
    print('WARN: missing common keys:', ', '.join(missing))
groups=[]
for g in data.get('proxy-groups') or []:
    if isinstance(g, dict) and 'name' in g:
        groups.append(str(g['name']))
print('proxy_group_count:', len(groups))
print('proxy_groups:', ', '.join(groups[:120]))
reserved={'DIRECT','REJECT','REJECT-DROP','PASS','GLOBAL'}
refs=[]
for r in data.get('rules') or []:
    if isinstance(r, str):
        parts=[x.strip() for x in r.split(',')]
        if len(parts)>=3:
            target=parts[-1]
            if target == 'no-resolve' and len(parts)>=4:
                target=parts[-2]
            refs.append(target)
missing_refs=sorted({x for x in refs if x and x not in reserved and x not in groups})
if missing_refs:
    print('ERROR: rules reference missing groups:', ', '.join(missing_refs))
    sys.exit(4)
print('Rule target group check OK')
PY
else
  echo "python3 not found; cannot perform full YAML validation."
  exit 2
fi
