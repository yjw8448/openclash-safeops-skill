#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "Aethersailor legacy-safe audit"
say "Legacy profile is retained for compatibility only. Prefer aethersailor-current-safe."
[ -f "$(dirname "$SCRIPT_DIR")/templates/aethersailor-legacy-safe-overlay.yaml" ] && say "Legacy template exists." || warn "Legacy template missing."
say "Do not run upstream scripts or remote installers. Generate local candidate only."
