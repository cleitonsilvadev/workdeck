#!/usr/bin/env bash
# Remove o bloco >>> workdeck >>> dos seus arquivos e os scripts de ~/.local/bin.
# Não apaga ~/.config/workdeck: a sua lista de projetos e seus painéis ficam.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

strip_block() {
  local file="$1" tmp
  [ -f "$file" ] || return 0
  grep -q "^# >>> workdeck >>>$" "$file" || return 0
  tmp="$(mktemp)"
  awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$file" > "$tmp"
  mv "$tmp" "$file"
  echo "  limpei o bloco em $file"
}

for f in "$HOME/.tmux.conf" "$HOME/.config/kitty/kitty.conf" \
         "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  strip_block "$f"
done

for script in "$ROOT"/bin/*; do
  name="$(basename "$script")"
  alvo="$HOME/.local/bin/$name"
  if [ -f "$alvo" ] && cmp -s "$script" "$alvo"; then
    rm -f "$alvo"
    echo "  removi $alvo"
  elif [ -f "$alvo" ]; then
    echo "  deixei $alvo: o arquivo foi alterado desde a instalação"
  fi
done

echo
echo "Sua config em ~/.config/workdeck/ continua lá (projetos e painéis)."
echo "Para apagar também:  rm -rf ~/.config/workdeck"
