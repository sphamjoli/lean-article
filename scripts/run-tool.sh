#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.cargo/bin:${HOME}/.elan/bin:${HOME}/.bun/bin:/opt/homebrew/bin:/usr/local/bin:${PATH}"
exec "$@"
