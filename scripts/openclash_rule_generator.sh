#!/bin/sh
# Generate safe OpenClash custom rules.
# Usage:
#   AI_GROUP=AI DEFAULT_GROUP=Proxy sh openclash_rule_generator.sh > rules.yaml

set -eu
AI_GROUP="${AI_GROUP:-AI}"
DEV_GROUP="${DEV_GROUP:-Proxy}"
DEFAULT_GROUP="${DEFAULT_GROUP:-Proxy}"
STREAM_GROUP="${STREAM_GROUP:-Proxy}"

cat <<EOF2
# SafeOps custom rules
# Verify these strategy groups exist before applying:
# - AI_GROUP=$AI_GROUP
# - DEV_GROUP=$DEV_GROUP
# - STREAM_GROUP=$STREAM_GROUP
# - DEFAULT_GROUP=$DEFAULT_GROUP
rules:
  # LAN/private direct first
  - DOMAIN-SUFFIX,local,DIRECT
  - DOMAIN-SUFFIX,lan,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
  - IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,224.0.0.0/4,DIRECT,no-resolve
  - IP-CIDR6,fc00::/7,DIRECT,no-resolve
  - IP-CIDR6,fe80::/10,DIRECT,no-resolve

  # AI services
  - DOMAIN-SUFFIX,openai.com,$AI_GROUP
  - DOMAIN-SUFFIX,chatgpt.com,$AI_GROUP
  - DOMAIN-SUFFIX,anthropic.com,$AI_GROUP
  - DOMAIN-SUFFIX,claude.ai,$AI_GROUP
  - DOMAIN-SUFFIX,ai.com,$AI_GROUP

  # Developer services
  - DOMAIN-SUFFIX,github.com,$DEV_GROUP
  - DOMAIN-SUFFIX,githubusercontent.com,$DEV_GROUP
  - DOMAIN-SUFFIX,githubassets.com,$DEV_GROUP
  - DOMAIN-SUFFIX,ghcr.io,$DEV_GROUP
  - DOMAIN-SUFFIX,docker.com,$DEV_GROUP
  - DOMAIN-SUFFIX,docker.io,$DEV_GROUP
  - DOMAIN-SUFFIX,npmjs.org,$DEV_GROUP
  - DOMAIN-SUFFIX,pypi.org,$DEV_GROUP
  - DOMAIN-SUFFIX,pythonhosted.org,$DEV_GROUP

  # Common streaming examples; adjust by region/service
  - DOMAIN-SUFFIX,netflix.com,$STREAM_GROUP
  - DOMAIN-SUFFIX,nflxvideo.net,$STREAM_GROUP
  - DOMAIN-SUFFIX,disneyplus.com,$STREAM_GROUP
  - DOMAIN-SUFFIX,spotify.com,$STREAM_GROUP

  # Domestic direct, if your core supports GEOSITE/GEOIP
  - GEOSITE,cn,DIRECT
  - GEOIP,CN,DIRECT

  # Fallback
  - MATCH,$DEFAULT_GROUP
EOF2
