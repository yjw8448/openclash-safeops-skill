#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "one-click profile candidate generator"
profile="${1:-safe-basic}"
candidate="${CANDIDATE_FILE:-/tmp/openclash-${profile}.candidate.yaml}"
case "$profile" in
  safe-basic) tmpl="$ROOT/templates/overwrite-safe-basic.yaml" ;;
  ai-dev) tmpl="$ROOT/templates/overwrite-ai-dev.yaml" ;;
  aethersailor-current-safe) tmpl="$ROOT/templates/aethersailor-current-safe-overlay.yaml" ;;
  ffani-redirhost-smartdns) tmpl="$ROOT/templates/ffani-redirhost-smartdns-overlay.yaml" ;;
  *) fail "Unknown profile: $profile" ;;
esac
[ -f "$tmpl" ] || fail "Template missing: $tmpl"
cp "$tmpl" "$candidate" || fail "Could not write $candidate"
say "Candidate generated: $candidate"
say "Validate and manually merge with a known single target YAML. This script does not write OpenClash config."
