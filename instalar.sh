#!/usr/bin/env bash
# workdeck — instalação numa linha, sem clonar o repositório à mão:
#
#   curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/instalar.sh | bash
#
# Clona o workdeck em ~/.local/share/workdeck, na versão publicada mais nova, e
# roda o install.sh de lá. As opções passam adiante: ... | bash -s -- --theme nord
set -euo pipefail

REPO="${WORKDECK_REPO:-https://github.com/thiagofeliperibeiro/workdeck.git}"
CODIGO="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    echo "O workdeck roda em macOS e Linux."
    exit 1 ;;
esac

if ! command -v git >/dev/null; then
  echo "O workdeck precisa do git."
  if [ "$(uname -s)" = Darwin ]; then
    echo "O macOS vai oferecer as ferramentas de desenvolvedor; aceite e rode este comando de novo."
    xcode-select --install 2>/dev/null || true
  else
    echo "Instale com o gerenciador da sua distribuição (sudo apt install git, por exemplo) e rode de novo."
  fi
  exit 1
fi

if [ -d "$CODIGO/.git" ]; then
  echo "workdeck já está em ${CODIGO/#$HOME/~}; buscando a versão mais nova."
  git -C "$CODIGO" fetch -q --tags --prune --prune-tags origin
else
  echo "baixando o workdeck para ${CODIGO/#$HOME/~}"
  rm -rf "$CODIGO"
  mkdir -p "$(dirname "$CODIGO")"
  git clone -q "$REPO" "$CODIGO"
fi

versao="${WORKDECK_VERSAO:-$(git -C "$CODIGO" tag -l 'v*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
  | awk -F'[v.]' '{printf "%09d%09d%09d %s\n", $2, $3, $4, $0}' | sort | tail -1 | cut -d' ' -f2 || true)}"
if [ -n "$versao" ]; then
  git -C "$CODIGO" checkout -q "$versao"
  echo "versão $versao"
fi

if (exec </dev/tty) 2>/dev/null; then
  exec bash "$CODIGO/install.sh" "$@" </dev/tty
fi
exec bash "$CODIGO/install.sh" "$@"
