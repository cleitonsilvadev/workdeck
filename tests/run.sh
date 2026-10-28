#!/usr/bin/env bash
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$RAIZ/tests/lib.sh"

command -v tmux >/dev/null || { echo "os testes precisam do tmux"; exit 1; }
command -v git >/dev/null || { echo "os testes precisam do git"; exit 1; }

filtro="${1:-}"
preparar_repo
trap 'rm -rf "$TESTE_TMP"' EXIT

passaram=0
falharam=()
for arquivo in "$RAIZ"/tests/*.test.sh; do
  while IFS= read -r teste; do
    if [ -n "$filtro" ]; then
      case "$teste" in *"$filtro"*) ;; *) continue ;; esac
    fi
    log="$TESTE_TMP/$teste.log"
    if ( . "$arquivo"; preparar_home "$teste"; trap limpar_tmux EXIT; "$teste" ) < /dev/null > "$log" 2>&1; then
      printf '  \033[32m✓\033[0m %s\n' "$teste"
      passaram=$((passaram + 1))
    else
      printf '  \033[31m✗\033[0m %s\n' "$teste"
      sed 's/^/      /' "$log" | tail -n 25
      falharam+=("$teste")
    fi
  done < <(grep -oE '^teste_[a-z0-9_]+' "$arquivo")
done

echo
if [ ${#falharam[@]} -gt 0 ]; then
  echo "$passaram passaram, ${#falharam[@]} falharam: ${falharam[*]}"
  exit 1
fi
echo "$passaram passaram"
