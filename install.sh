#!/usr/bin/env bash
# workdeck — instalador. macOS e Linux; no Windows, use WSL.
#
#   ./install.sh                      instala com o tema padrão
#   ./install.sh --theme nord         escolhe um tema de themes/
#   ./install.sh --terminal kitty     instala também os atalhos cmd do kitty
#   ./install.sh --no-deps            não instala nada pelo gerenciador de pacotes
#   ./install.sh --no-reload          não recarrega o tmux no fim
#   ./install.sh --dry-run            só mostra o que faria
#
# É idempotente: rodar de novo atualiza em vez de duplicar. O que ele escreve
# nos seus arquivos fica entre marcadores >>> workdeck >>>, e o uninstall.sh
# remove exatamente esse trecho.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck"
BIN_DIR="$HOME/.local/bin"
THEME="catppuccin-mocha"
TERMINAL=""
DEPS=1
RELOAD=1
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --theme) THEME="${2:?--theme precisa de um nome}"; shift 2 ;;
    --terminal) TERMINAL="${2:?--terminal precisa de um nome}"; shift 2 ;;
    --no-deps) DEPS=0; shift ;;
    --no-reload) RELOAD=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $1"; exit 1 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
run() { [ "$DRY" = 1 ] && { say "[dry-run] $*"; return 0; }; "$@"; }

[ -f "$ROOT/themes/$THEME.conf" ] || {
  echo "tema '$THEME' não existe. Disponíveis:"
  ls "$ROOT/themes"/*.conf | xargs -n1 basename | sed 's/\.conf$//; s/^/  /'
  exit 1
}

# ---- qual sistema ----------------------------------------------------------
case "$(uname -s)" in
  Darwin) SO="macOS"; GERENCIADOR="brew" ;;
  Linux)
    SO="Linux"
    if grep -qi microsoft /proc/version 2>/dev/null; then SO="Linux (WSL)"; fi
    for g in apt-get dnf pacman zypper apk; do
      command -v "$g" >/dev/null && { GERENCIADOR="$g"; break; }
    done
    GERENCIADOR="${GERENCIADOR:-}"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    cat <<'FIM'
Este é o Windows nativo, onde o tmux não roda.

Use o WSL:

  wsl --install                      no PowerShell, como administrador
  wsl                                entra no Linux
  git clone <este repositório>
  cd workdeck && ./install.sh

Dentro do WSL tudo funciona igual ao Linux. O seu terminal do Windows
(Windows Terminal, por exemplo) continua sendo o terminal; quem gerencia
as janelas é o tmux, lá dentro.
FIM
    exit 1
    ;;
  *) SO="$(uname -s)"; GERENCIADOR="" ;;
esac

echo "workdeck → $SO, tema $THEME"
echo

# ---- 1. dependências -------------------------------------------------------
echo "[1/5] dependências"
falta=()
command -v tmux >/dev/null || falta+=(tmux)
command -v delta >/dev/null || falta+=(git-delta)

if [ ${#falta[@]} -eq 0 ]; then
  say "tmux e git-delta já instalados"
elif [ "$DEPS" = 0 ]; then
  say "faltando: ${falta[*]} — instale por conta (--no-deps)"
else
  case "$GERENCIADOR" in
    brew)    run brew install "${falta[@]}" ;;
    apt-get) run sudo apt-get update -qq && run sudo apt-get install -y tmux git-delta ;;
    dnf)     run sudo dnf install -y tmux git-delta ;;
    pacman)  run sudo pacman -S --needed --noconfirm tmux git-delta ;;
    zypper)  run sudo zypper install -y tmux git-delta ;;
    apk)     run sudo apk add tmux delta ;;
    *)       say "não reconheci o gerenciador de pacotes; instale: ${falta[*]}" ;;
  esac
fi

if [ "$SO" = "macOS" ] && [ "$DEPS" = 1 ] && command -v brew >/dev/null; then
  ls ~/Library/Fonts 2>/dev/null | grep -qi jetbrains \
    || run brew install --cask font-jetbrains-mono
fi
echo

# ---- 2. scripts ------------------------------------------------------------
echo "[2/5] scripts em $BIN_DIR"
run mkdir -p "$BIN_DIR"
for script in "$ROOT"/bin/*; do
  nome="$(basename "$script")"
  alvo="$BIN_DIR/$nome"
  # Se já existe um arquivo diferente com esse nome, ele é de outra pessoa
  # (ou seu, de antes). Guarda uma cópia antes de substituir.
  if [ -f "$alvo" ] && ! cmp -s "$script" "$alvo"; then
    backup="$alvo.antes-do-workdeck"
    run cp "$alvo" "$backup"
    say "$nome — já existia e era diferente; guardei em $(basename "$backup")"
  else
    say "$nome"
  fi
  run install -m 755 "$script" "$alvo"
done
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) say "atenção: $BIN_DIR não está no PATH — o bloco do shell resolve isso" ;;
esac
echo

# ---- 3. config do usuário --------------------------------------------------
echo "[3/5] config em $CONFIG_DIR"
run mkdir -p "$CONFIG_DIR/panels"
if [ -f "$CONFIG_DIR/projects.conf" ]; then
  say "projects.conf já existe — não toquei nele"
else
  run cp "$ROOT/projects.example.conf" "$CONFIG_DIR/projects.conf"
  say "projects.conf criado — edite com os seus projetos"
fi
for painel in "$ROOT"/config/panels/*; do
  nome="$(basename "$painel")"
  if [ -f "$CONFIG_DIR/panels/$nome" ]; then
    say "painel $nome já existe — não toquei nele"
  else
    run install -m 755 "$painel" "$CONFIG_DIR/panels/$nome"
    say "painel $nome"
  fi
done
run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
run cp "$ROOT/config/git-review-lesskey" "${XDG_CONFIG_HOME:-$HOME/.config}/git-review/lesskey"
say "lesskey do git-review"
echo

# ---- 4. tmux e terminal ----------------------------------------------------
# Troca o bloco entre os marcadores, ou acrescenta se ainda não existir.
write_block() { # arquivo, conteúdo
  local file="$1" body="$2" tmp
  [ "$DRY" = 1 ] && { say "[dry-run] atualizaria o bloco em $file"; return 0; }
  mkdir -p "$(dirname "$file")"
  touch "$file"
  tmp="$(mktemp)"
  awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$file" > "$tmp"
  awk 'BEGIN{n=0} {l[n++]=$0} END{while(n>0 && l[n-1]~/^[[:space:]]*$/) n--; for(i=0;i<n;i++) print l[i]}' "$tmp" > "$tmp.2"
  { cat "$tmp.2"; [ -s "$tmp.2" ] && echo; echo "$body"; } > "$file"
  rm -f "$tmp" "$tmp.2"
}

echo "[4/5] tmux"
write_block "$HOME/.tmux.conf" \
  "$(sed '$d' "$ROOT/config/tmux.conf" | sed '/^# O tema entra aqui/d'; cat "$ROOT/themes/$THEME.tmux"; echo '# <<< workdeck <<<')"
say "tmux.conf — atalhos em Alt, que funcionam em qualquer terminal"

case "$TERMINAL" in
  "")
    say "nenhum terminal escolhido; os atalhos em Alt já funcionam onde você está"
    ;;
  kitty)
    write_block "$HOME/.config/kitty/kitty.conf" \
      "$(sed '$d' "$ROOT/terminals/kitty.conf" | sed '/^# O tema entra aqui/d'; cat "$ROOT/themes/$THEME.conf"; echo '# <<< workdeck <<<')"
    say "kitty.conf — atalhos em cmd e as cores do tema"
    ;;
  wezterm|alacritty)
    say "o adaptador do $TERMINAL é um trecho para colar, não instalo automático:"
    say "  $ROOT/terminals/$TERMINAL.*"
    say "o instalador não edita Lua nem TOML de terceiros — veja terminals/README.md"
    ;;
  *)
    say "não tenho adaptador para '$TERMINAL'. Disponíveis: kitty, wezterm, alacritty"
    ;;
esac
echo

# ---- 5. shell --------------------------------------------------------------
echo "[5/5] shell"
rc=""
case "$(basename "${SHELL:-/bin/bash}")" in
  zsh)  rc="$HOME/.zshrc" ;;
  bash) [ "$SO" = "macOS" ] && rc="$HOME/.bash_profile" || rc="$HOME/.bashrc" ;;
  *)    rc="" ;;
esac
if [ -n "$rc" ]; then
  write_block "$rc" "$(cat "$ROOT/config/shell-snippet.sh")"
  say "$(basename "$rc")"
else
  say "shell '$SHELL' não reconhecido — adicione à mão:"
  say "  source $ROOT/config/shell-snippet.sh"
fi
echo

if [ "$RELOAD" = 1 ] && command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
  run tmux source-file "$HOME/.tmux.conf" && say "tmux recarregado"
fi

cat <<FIM

Pronto. Faltam três passos que são seus:

  1. Edite os seus projetos:
       \$EDITOR $CONFIG_DIR/projects.conf

  2. Recarregue o shell:
       source ${rc:-seu arquivo de shell}

  3. Abra:
       work

  Os atalhos são Alt+número para trocar de janela e Alt+Shift+letra para as
  ações. Se instalou um adaptador de terminal, ele precisa reabrir.
FIM
