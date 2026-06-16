#!/bin/sh
# Simple keyword lookup for OpenClash SafeOps v4 KB.
# Usage: sh scripts/openclash_kb_lookup.sh dns
set -eu
TERM="${1:-}"
DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/docs/kb"
if [ -z "$TERM" ]; then
  echo "Usage: $0 <keyword>"
  echo "Examples: $0 dns | $0 subscription | $0 fake-ip | $0 redir-host | $0 group"
  exit 1
fi
if [ ! -d "$DIR" ]; then
  echo "KB directory not found: $DIR" >&2
  exit 2
fi
grep -RIn --exclude='*.png' --exclude='*.jpg' -- "$TERM" "$DIR" | sed -E 's#^.*/docs/kb/##' | head -80 || true
