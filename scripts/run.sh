#!/usr/bin/env bash
set -euo pipefail

exec guile "$(dirname "$0")/../bin/sla-ledger.scm" "$@"
