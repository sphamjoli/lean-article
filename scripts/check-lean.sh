#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../lean"
python3 ../scripts/audit-project.py
for test_file in test/*.lean; do
  output="$(mktemp)"
  if lake env lean -DwarningAsError=true "$test_file" >"$output" 2>&1; then
    cat "$output"
    rm -f "$output"
    echo "Forbidden-axiom test_file unexpectedly passed: $test_file" >&2
    exit 1
  fi
  if ! grep -q 'Forbidden axiom dependency:' "$output" ||
      ! grep -q 'Project axiom audit failed' "$output"; then
    cat "$output"
    rm -f "$output"
    echo "Negative test failed for a reason other than the axiom audit" >&2
    exit 1
  fi
  rm -f "$output"
  echo "Rejected forbidden-axiom test_file: $test_file"
done
