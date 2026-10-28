#!/usr/bin/env bash
set -euo pipefail
curl -fsSL "${WORKDECK_GET_URL:-https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh}" | bash -s -- "$@"
