#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec make rust-lint rust-test rust-doc lean-check
