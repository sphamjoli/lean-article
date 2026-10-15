#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../lean"
python3 ../scripts/audit-project.py
for fixture in audit-fixtures/*.lean; do
  output="$(mktemp)"
  if lake env lean -DwarningAsError=true "$fixture" >"$output" 2>&1; then
    cat "$output"
    rm -f "$output"
    echo "Forbidden-axiom fixture unexpectedly passed: $fixture" >&2
    exit 1
  fi
  if ! grep -q 'Forbidden axiom dependency:' "$output" ||
      ! grep -q 'Project axiom audit failed' "$output"; then
    cat "$output"
    rm -f "$output"
    echo "Fixture failed for a reason other than the axiom audit" >&2
    exit 1
  fi
  rm -f "$output"
  echo "Rejected forbidden-axiom fixture: $fixture"
done
