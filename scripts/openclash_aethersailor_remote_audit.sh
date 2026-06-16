#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "Aethersailor remote source audit"
say "Remote sources are reference-only. SafeOps must not curl|sh or execute remote content."
say "Use references/aethersailor-source-snapshot.md and references/upstream-sources.md."
