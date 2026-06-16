#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "safe repair coordinator"
say "This coordinator runs diagnosis and prints safe next steps. It does not write by default."
sh "$SCRIPT_DIR/openclash_diagnose.sh"
say ""
sh "$SCRIPT_DIR/openclash_dns_audit.sh"
say ""
sh "$SCRIPT_DIR/openclash_multisub_audit.sh"
say ""
say "Next step: choose one specific workflow: DNS repair, subscription repair, single-config template candidate, or emergency restore."
