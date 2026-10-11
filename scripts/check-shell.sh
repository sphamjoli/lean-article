#!/usr/bin/env bash
set -euo pipefail
while IFS= read -r -d '' script; do
  case "$script" in *.sh|*.bash) bash -n "$script" ;; esac
done < <(git ls-files -z)
