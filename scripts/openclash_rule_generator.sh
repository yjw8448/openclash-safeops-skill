#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "rule generator"
type="${1:-ai}"
case "$type" in
  ai)
    cat <<'EOF'
# AI service rules - candidate only
- DOMAIN-SUFFIX,openai.com,AI
- DOMAIN-SUFFIX,chatgpt.com,AI
- DOMAIN-SUFFIX,oaistatic.com,AI
- DOMAIN-SUFFIX,oaiusercontent.com,AI
- DOMAIN-SUFFIX,anthropic.com,AI
- DOMAIN-SUFFIX,claude.ai,AI
EOF
    ;;
  dev)
    cat <<'EOF'
# Developer rules - candidate only
- DOMAIN-SUFFIX,github.com,PROXY
- DOMAIN-SUFFIX,githubusercontent.com,PROXY
- DOMAIN-SUFFIX,githubassets.com,PROXY
- DOMAIN-SUFFIX,docker.com,PROXY
EOF
    ;;
  *) fail "Usage: $0 ai|dev" ;;
esac
