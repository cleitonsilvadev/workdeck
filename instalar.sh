#!/usr/bin/env bash
set -euo pipefail
curl -fsSL "${WORKDECK_GET_URL:-https://raw.githubusercontent.com/workdeckdev/workdeck/main/get.sh}" | bash -s -- "$@"
