#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../lean"
lake build
lake env lean -DwarningAsError=true AxiomAudit.lean | python3 ../scripts/check-axioms.py
