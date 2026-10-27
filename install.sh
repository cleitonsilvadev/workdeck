#!/usr/bin/env bash
# workdeck — instalador.
#
#   ./install.sh                  instala com o tema padrão (catppuccin-mocha)
#   ./install.sh --theme nord     escolhe outro tema de themes/
#   ./install.sh --no-brew        não instala nada pelo Homebrew
#   ./install.sh --no-reload      não recarrega o tmux no fim
#   ./install.sh --dry-run        só mostra o que faria
#
# É idempotente: rodar de novo atualiza em vez de duplicar. Tudo o que ele
# escreve nos seus arquivos fica entre marcadores >>> workdeck >>>, e o
# uninstall.sh remove exatamente esse trecho.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck"
BIN_DIR="$HOME/.local/bin"
THEME="catppuccin-mocha"
USE_BREW=1
RELOAD=1
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --theme) THEME="${2:?--theme precisa de um nome}"; shift 2 ;;
    --no-brew) USE_BREW=0; shift ;;
    --no-reload) RELOAD=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $1"; exit 1 ;;
  esac
done

[ -f "$ROOT/themes/$THEME.conf" ] || {
  echo "tema '$THEME' não existe. Disponíveis:"
  ls "$ROOT/themes"/*.conf | xargs -n1 basename | sed 's/\.conf$/  /' | sed 's/^/  /'
  exit 1
}

say() { printf '  %s\n' "$*"; }
run() { [ "$DRY" = 1 ] && { say "[dry-run] $*"; return 0; }; "$@"; }

# Troca o bloco entre os marcadores, ou acrescenta se ainda não existir.
write_block() { # arquivo, conteúdo
  local file="$1" body="$2" tmp
  [ "$DRY" = 1 ] && { say "[dry-run] atualizaria o bloco workdeck em $file"; return 0; }
  mkdir -p "$(dirname "$file")"
  touch "$file"
  tmp="$(mktemp)"
  awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$file" > "$tmp"
  # tira linhas em branco sobrando no fim
  awk 'BEGIN{n=0} {lines[n++]=$0} END{while(n>0 && lines[n-1]~/^[[:space:]]*$/) n--; for(i=0;i<n;i++) print lines[i]}' "$tmp" > "$tmp.2"
  { cat "$tmp.2"; [ -s "$tmp.2" ] && echo; echo "$body"; } > "$file"
  rm -f "$tmp" "$tmp.2"
}

echo "workdeck → instalando (tema: $THEME)"
echo

# ---- 1. dependências -------------------------------------------------------
echo "[1/5] dependências"
if [ "$USE_BREW" = 1 ] && command -v brew >/dev/null; then
  for f in tmux git-delta; do
    if brew list --formula "$f" >/dev/null 2>&1; then say "$f já instalado"
    else say "instalando $f"; run brew install "$f"; fi
  done
  if [ ! -d "/Applications/kitty.app" ]; then say "instalando kitty"; run brew install --cask kitty
  else say "kitty já instalado"; fi
  if ! ls ~/Library/Fonts 2>/dev/null | grep -qi jetbrains; then
    say "instalando a fonte JetBrains Mono"; run brew install --cask font-jetbrains-mono
  else say "JetBrains Mono já instalada"; fi
else
  say "pulando o Homebrew; garanta tmux, git-delta, kitty e a fonte JetBrains Mono"
fi
echo

# ---- 2. scripts ------------------------------------------------------------
echo "[2/5] scripts em $BIN_DIR"
run mkdir -p "$BIN_DIR"
for script in "$ROOT"/bin/*; do
  name="$(basename "$script")"
  run install -m 755 "$script" "$BIN_DIR/$name"
  say "$name"
done
echo

# ---- 3. config do usuário --------------------------------------------------
echo "[3/5] config em $CONFIG_DIR"
run mkdir -p "$CONFIG_DIR"
if [ -f "$CONFIG_DIR/projects.conf" ]; then
  say "projects.conf já existe — não toquei nele"
else
  run cp "$ROOT/projects.example.conf" "$CONFIG_DIR/projects.conf"
  say "projects.conf criado a partir do exemplo — edite com os seus projetos"
fi
run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
run cp "$ROOT/config/git-review-lesskey" "${XDG_CONFIG_HOME:-$HOME/.config}/git-review/lesskey"
say "lesskey do git-review"
if command -v tclock >/dev/null; then
  run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/tclock"
  if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/tclock/config.toml" ]; then
    say "config do tclock já existe — não toquei nela"
  else
    run cp "$ROOT/config/tclock.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/tclock/config.toml"
    say "config do tclock criada"
  fi
else
  say "tclock não encontrado — o painel é opcional, veja o README"
fi
echo

# ---- 4. kitty e tmux -------------------------------------------------------
echo "[4/5] kitty e tmux"
write_block "$HOME/.config/kitty/kitty.conf" \
  "$(sed '$d' "$ROOT/config/kitty.conf" | sed '/^# O tema entra aqui/d'; cat "$ROOT/themes/$THEME.conf"; echo '# <<< workdeck <<<')"
say "kitty.conf"
write_block "$HOME/.tmux.conf" \
  "$(sed '$d' "$ROOT/config/tmux.conf" | sed '/^# O tema entra aqui/d'; cat "$ROOT/themes/$THEME.tmux"; echo '# <<< workdeck <<<')"
say "tmux.conf"
echo

# ---- 5. zsh ----------------------------------------------------------------
echo "[5/5] zsh"
write_block "$HOME/.zshrc" "$(cat "$ROOT/config/zshrc-snippet.zsh")"
say ".zshrc"
echo

# Recarregar um tmux que já está rodando aplica ESTE $HOME nele. Ao instalar
# num HOME de teste, use --no-reload para não mexer na sessão de verdade.
if [ "$RELOAD" = 1 ] && command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
  run tmux source-file "$HOME/.tmux.conf" && say "tmux recarregado"
fi

cat <<'FIM'

Pronto. Faltam três passos que são seus:

  1. Edite os seus projetos:
       $EDITOR ~/.config/workdeck/projects.conf

  2. Recarregue o shell:
       source ~/.zshrc

  3. Abra:
       work

  O kitty só pega a config nova ao reabrir, ou com ctrl+shift+f5.
FIM
