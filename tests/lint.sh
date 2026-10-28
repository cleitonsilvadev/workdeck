#!/usr/bin/env bash
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"
command -v shellcheck >/dev/null || { echo "instale o shellcheck: brew install shellcheck, ou apt install shellcheck"; exit 1; }
shellcheck install.sh uninstall.sh instalar.sh bin/work bin/work-panel bin/workdeck-agent \
  config/panels/* integrations/*.sh tests/*.sh
shellcheck -e SC2034 lib/comum.sh
echo "shellcheck: nenhum problema"
