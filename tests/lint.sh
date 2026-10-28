#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v shellcheck >/dev/null || { echo "install shellcheck: brew install shellcheck, or apt install shellcheck"; exit 1; }
shellcheck install.sh uninstall.sh get.sh instalar.sh bin/work bin/work-panel bin/workdeck-agent \
  config/panels/* integrations/*.sh tests/*.sh
shellcheck -e SC2034 lib/common.sh
echo "shellcheck: no issues"
