#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
query="${1:-}"
[ -n "$query" ] || { echo "Usage: $0 keyword"; exit 1; }
find "$ROOT/references" "$ROOT/docs/kb" -type f -name '*.md' 2>/dev/null | while IFS= read -r f; do
  if grep -qi -- "$query" "$f"; then
    echo "--- $f"
    grep -ni -- "$query" "$f" | head -n 8
  fi
done
