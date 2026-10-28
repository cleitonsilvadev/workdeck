#!/usr/bin/env bash
# workdeck one-line install, without cloning the repository by hand:
#
#   curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh | bash
#
# Clones workdeck into ~/.local/share/workdeck at the latest published version
# and runs install.sh from there. Options are passed through: ... | bash -s -- --theme nord
set -euo pipefail

REPO="${WORKDECK_REPO:-https://github.com/thiagofeliperibeiro/workdeck.git}"
CODE="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck"

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

if [ -d "$CODE/.git" ]; then
  echo "workdeck já está em ${CODE/#$HOME/~}; buscando a versão mais nova."
  git -C "$CODE" fetch -q --tags --prune --prune-tags origin
else
  echo "baixando o workdeck para ${CODE/#$HOME/~}"
  rm -rf "$CODE"
  mkdir -p "$(dirname "$CODE")"
  git clone -q "$REPO" "$CODE"
fi

version="${WORKDECK_VERSION:-$(git -C "$CODE" tag -l 'v*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
  | awk -F'[v.]' '{printf "%09d%09d%09d %s\n", $2, $3, $4, $0}' | sort | tail -1 | cut -d' ' -f2 || true)}"
if [ -n "$version" ]; then
  git -C "$CODE" checkout -q "$version"
  echo "versão $version"
fi

if (exec </dev/tty) 2>/dev/null; then
  exec bash "$CODE/install.sh" "$@" </dev/tty
fi
exec bash "$CODE/install.sh" "$@"
