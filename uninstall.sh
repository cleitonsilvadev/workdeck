#!/usr/bin/env bash
# Remove o bloco >>> workdeck >>> dos seus arquivos e os scripts de ~/.local/bin.
# Não apaga ~/.config/workdeck: a sua lista de projetos fica.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

strip_block() {
  local file="$1" tmp
  [ -f "$file" ] || return 0
  tmp="$(mktemp)"
  awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$file" > "$tmp"
  mv "$tmp" "$file"
  echo "  limpei o bloco em $file"
}

strip_block "$HOME/.config/kitty/kitty.conf"
strip_block "$HOME/.tmux.conf"
strip_block "$HOME/.zshrc"

for script in "$ROOT"/bin/*; do
  name="$(basename "$script")"
  if [ -f "$HOME/.local/bin/$name" ]; then
    rm -f "$HOME/.local/bin/$name"
    echo "  removi ~/.local/bin/$name"
  fi
done

echo
echo "Sua config em ~/.config/workdeck/ continua lá."
echo "Para apagar também:  rm -rf ~/.config/workdeck"
