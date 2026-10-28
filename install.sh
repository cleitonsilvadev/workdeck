#!/usr/bin/env bash
# workdeck — instalador. macOS e Linux.
#
#   ./install.sh                      instala com o tema padrão
#   ./install.sh --theme nord         escolhe um tema de themes/
#   ./install.sh --agent claude       define o seu agente de IA
#   ./install.sh --zsh                instala o oh-my-zsh e o zinit sem perguntar
#   ./install.sh --with ai-memory     ativa integrações opcionais (vírgula separa)
#   ./install.sh --list-integrations  mostra as integrações disponíveis e sai
#   ./install.sh --yes                não pergunta nada; usa os padrões
#   ./install.sh --no-deps            não instala nada pelo gerenciador de pacotes
#   ./install.sh --no-reload          não recarrega o tmux no fim
#   ./install.sh --dry-run            só mostra o que faria
#
# É idempotente: rodar de novo atualiza em vez de duplicar. O que ele escreve
# nos seus arquivos fica entre marcadores >>> workdeck >>>, e o uninstall.sh
# remove exatamente esse trecho.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/common.sh"

CONFIG_DIR="$WORKDECK_CONFIG"
BIN_DIR="$WORKDECK_BIN"
CODE="$WORKDECK_CODE"
BACKUPS="$CONFIG_DIR/.backups"
MANIFEST="$CONFIG_DIR/.install-manifest"
ZSH_CHOICE="$CONFIG_DIR/zsh"
ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck-zsh"
ZINIT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
INTEGRATIONS_CHOICE="$CONFIG_DIR/integrations"

THEME=""
WANT_ZSH=0
RESTART_SHELL=0
AGENT=""
WITH=""
YES=0
DEPS=1
RELOAD=1
DRY=0

OS_NAME=""
PKG_MANAGER=""
SUDO=""
FONTS_DIR=""
FONT=""
ZSH_SUMMARY=""
CHOSEN=0

FANCY=0
green=""; yellow=""; red=""; purple=""; dim=""; bold=""; reset=""
LOG=""
UPDATING="${WORKDECK_UPDATING:-${WORKDECK_ATUALIZANDO:-}}"
STEP=""; SUMMARY=""; WARNINGS=(); SPINNER=""

parse_options() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --theme) THEME="${2:?--theme precisa de um nome}"; shift 2 ;;
      --agent) AGENT="${2:?--agent precisa de um comando}"; shift 2 ;;
      --with) WITH="${2:?--with precisa de um nome}"; shift 2 ;;
      --yes|-y) YES=1; shift ;;
      --list-integrations) list_integrations; exit 0 ;;
      --no-deps) DEPS=0; shift ;;
      --zsh) WANT_ZSH=1; shift ;;
      --no-reload) RELOAD=0; shift ;;
      --dry-run) DRY=1; shift ;;
      -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
      *) echo "opção desconhecida: $1"; exit 1 ;;
    esac
  done
}

list_integrations() {
  local f
  for f in "$ROOT"/integrations/*.sh; do
    [ "$(basename "$f")" = "example.sh" ] && continue
    ( . "$f"; printf '  %s\n' "$(describe | head -1)"
      describe | tail -n +2 | sed 's/^/      /' )
    echo
  done
}

record() {
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$MANIFEST")"
  grep -qxF "$1|$2|${3:-}" "$MANIFEST" 2>/dev/null || echo "$1|$2|${3:-}" >> "$MANIFEST"
}

backup_file() {
  local file="$1" name dest
  [ -f "$file" ] || return 0
  has_block "$file" && return 0
  name="$(echo "${file#"$HOME"/}" | tr '/' '-' | sed 's/^\.//')"
  dest="$BACKUPS/$name.$(date +%Y%m%d-%H%M%S)"
  [ "$DRY" = 1 ] && { echo ""; return 0; }
  mkdir -p "$BACKUPS"
  cp "$file" "$dest"
  echo "$dest"
}

write_block() {
  local file="$1" body="$2" tmp backup
  if [ -e "$file" ] && [ ! -f "$file" ]; then
    warn "$(short_path "$file") não é um arquivo comum; não mexi nele"
    return 0
  fi
  backup="$(backup_file "$file")"
  [ -n "$backup" ] && say "cópia do original em ${backup#"$HOME"/}"
  [ -e "$file" ] || backup=":created"
  grep -qF "block|$file|" "$MANIFEST" 2>/dev/null || record block "$file" "$backup"
  [ "$DRY" = 1 ] && { say "[dry-run] atualizaria o bloco em $file"; return 0; }
  mkdir -p "$(dirname "$file")"
  touch "$file"
  tmp="$(mktemp)"
  without_block "$file" > "$tmp"
  awk 'BEGIN{n=0} {l[n++]=$0} END{while(n>0 && l[n-1]~/^[[:space:]]*$/) n--; for(i=0;i<n;i++) print l[i]}' "$tmp" > "$tmp.2"
  { cat "$tmp.2"; [ -s "$tmp.2" ] && echo; echo "$body"; } > "$file"
  rm -f "$tmp" "$tmp.2"
}

can_ask() {
  [ -t 0 ] || return 1
  [ "$YES" = 0 ] || [ -n "$UPDATING" ]
}

say() {
  if [ "$FANCY" = 1 ]; then printf '%s\n' "$*" >> "$LOG"; else printf '  %s\n' "$*"; fi
}
warn() {
  [ "$FANCY" = 1 ] && WARNINGS+=("$*")
  say "$*"
}
summary() { SUMMARY="$*"; }
run() {
  [ "$DRY" = 1 ] && { say "[dry-run] $*"; return 0; }
  if [ "$FANCY" = 1 ]; then "$@" >> "$LOG" 2>&1; else "$@"; fi
}

spin() {
  [ "$FANCY" = 1 ] || return 0
  (
    frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏); i=0
    while :; do
      printf '\r  %s%s%s %s' "$purple" "${frames[$((i % 10))]}" "$reset" "$STEP"
      i=$((i + 1)); sleep 0.08
    done
  ) &
  SPINNER=$!
}
stop_spin() {
  if [ -n "$SPINNER" ]; then
    kill "$SPINNER" 2>/dev/null || true
    wait "$SPINNER" 2>/dev/null || true
    SPINNER=""
    printf '\r\033[K'
  fi
  return 0
}
step() {
  STEP="$2"; SUMMARY=""; WARNINGS=()
  if [ "$FANCY" = 1 ]; then spin; else echo "[$1/7] $2"; fi
}
finish_step() {
  local a mark width
  if [ "$FANCY" = 1 ]; then
    stop_spin
    mark="${green}✓${reset}"
    [ ${#WARNINGS[@]} -gt 0 ] && mark="${yellow}!${reset}"
    width=$(printf '%s' "$STEP" | LC_ALL=C tr -d '\200-\277' | wc -c)
    printf '  %s %s%*s %s%s%s\n' "$mark" "$STEP" $((14 - width)) "" "$dim" "$SUMMARY" "$reset"
    for a in ${WARNINGS[@]+"${WARNINGS[@]}"}; do printf '      %s%s%s\n' "$yellow" "$a" "$reset"; done
  else
    echo
  fi
  STEP=""
}
on_exit() {
  local status=$?
  stop_spin
  if [ "$status" != 0 ] && [ "$FANCY" = 1 ] && [ -n "$STEP" ]; then
    printf '  %s✗%s %s\n' "$red" "$reset" "$STEP"
    tail -n 15 "$LOG" | sed 's/^/      /'
  fi
  [ "$FANCY" = 1 ] && printf '\033[?25h'
  rm -f "$LOG"
}

setup_output() {
  if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != dumb ] && [ "$DRY" = 0 ]; then FANCY=1; fi
  if [ "$FANCY" = 1 ]; then
    green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; purple=$'\033[35m'
    dim=$'\033[2m'; bold=$'\033[1m'; reset=$'\033[0m'
  fi
  LOG="$(mktemp)"
  trap on_exit EXIT
  if [ "$FANCY" = 1 ]; then exec 2>>"$LOG"; fi
}

choose_theme() {
  if [ -z "$THEME" ]; then
    THEME="$(cat "$CONFIG_DIR/theme" 2>/dev/null || true)"
    [ -f "$ROOT/themes/${THEME:-_}.conf" ] || THEME="catppuccin-mocha"
  fi
  if [ ! -f "$ROOT/themes/$THEME.conf" ]; then
    local t
    echo "tema '$THEME' não existe. Disponíveis:"
    for t in "$ROOT"/themes/*.conf; do t="$(basename "$t")"; echo "  ${t%.conf}"; done
    exit 1
  fi
  [ "$DRY" = 1 ] || { mkdir -p "$CONFIG_DIR"; echo "$THEME" > "$CONFIG_DIR/theme"; }
}

detect_system() {
  local g
  case "$(uname -s)" in
    Darwin) OS_NAME="macOS"; PKG_MANAGER="brew" ;;
    Linux)
      OS_NAME="Linux"
      if grep -qi microsoft /proc/version 2>/dev/null; then OS_NAME="Linux (WSL)"; fi
      for g in apt-get dnf pacman zypper apk; do
        command -v "$g" >/dev/null && { PKG_MANAGER="$g"; break; }
      done
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "O workdeck roda em macOS e Linux."
      exit 1
      ;;
    *) OS_NAME="$(uname -s)" ;;
  esac
  [ "$(id -u)" != 0 ] && SUDO="sudo"
  if [ "$OS_NAME" = macOS ]; then FONTS_DIR="$HOME/Library/Fonts"; else FONTS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"; fi
}

show_header() {
  if [ "$FANCY" = 1 ]; then
    if [ -n "$UPDATING" ]; then
      printf '\033[?25l'
    else
      printf '\033[?25l\n  %sworkdeck%s %s· %s · %s%s\n\n' "$bold" "$reset" "$dim" "$OS_NAME" "$THEME" "$reset"
    fi
  else
    echo "workdeck → $OS_NAME, tema $THEME"
    echo
  fi
}

in_kitty() { [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = xterm-kitty ]; }

kitty_from_other_account() {
  case "$1" in
    "$HOME"/*) return 1 ;;
    /Users/*|/home/*) return 0 ;;
  esac
  return 1
}

kitty_installed() {
  local k
  [ -d /Applications/kitty.app ] || [ -d "$HOME/Applications/kitty.app" ] \
    || [ -x "$HOME/.local/kitty.app/bin/kitty" ] && return 0
  k="$(command -v kitty 2>/dev/null)" || return 1
  ! kitty_from_other_account "$k"
}

install_kitty() {
  local app dest
  if kitty_installed; then say "kitty já instalado"; return 0; fi
  rm -f "$CONFIG_DIR/kitty"
  if [ "$DEPS" = 0 ]; then warn "kitty não instalado (--no-deps): https://sw.kovidgoyal.net/kitty/binary/"; return 1; fi
  [ "$DRY" = 1 ] && { say "[dry-run] instalaria o kitty pelo instalador oficial"; return 0; }
  if ! command -v curl >/dev/null; then warn "sem curl; instale o kitty: https://sw.kovidgoyal.net/kitty/binary/"; return 1; fi
  if [ "$OS_NAME" = macOS ]; then dest="$HOME/Applications"; else dest="$HOME/.local"; fi
  mkdir -p "$dest"
  if ! curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest="$dest" launch=n >> "$LOG" 2>&1; then
    warn "não consegui instalar o kitty; instale por https://sw.kovidgoyal.net/kitty/binary/ e rode a instalação de novo"
    return 1
  fi
  app="$dest/kitty.app"
  if [ "$OS_NAME" != macOS ]; then
    mkdir -p "$BIN_DIR" "$HOME/.local/share/applications"
    ln -sf "$app/bin/kitty" "$app/bin/kitten" "$BIN_DIR/"
    cp "$app/share/applications/kitty.desktop" "$app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"
    sed -i "s|Icon=kitty|Icon=$app/share/icons/hicolor/256x256/apps/kitty.png|g; s|Exec=kitty|Exec=$app/bin/kitty|g" \
      "$HOME/.local/share/applications"/kitty*.desktop
  fi
  record kitty "$app"
  say "kitty instalado em $(short_path "$app")"
}

apply_kitty() {
  local bloco
  bloco="$(sed '$d' "$ROOT/terminals/kitty.conf" | sed '/^# The theme is appended here/d')"
  [ "$OS_NAME" = macOS ] || bloco="$(printf '%s\n' "$bloco" | grep -v '^map cmd\|^macos_')"
  write_block "$HOME/.config/kitty/kitty.conf" "$(printf '%s\n' "$bloco"; cat "$ROOT/themes/$THEME.conf"; echo '# <<< workdeck <<<')"
  say "kitty.conf — tema, fonte e atalhos"
}

has_font() {
  local f
  for f in "$FONTS_DIR"/*[Jj]et[Bb]rains[Mm]ono* /Library/Fonts/*[Jj]et[Bb]rains[Mm]ono*; do
    [ -e "$f" ] && return 0
  done
  command -v fc-list >/dev/null && fc-list 2>/dev/null | grep -qi 'JetBrains Mono' && return 0
  return 1
}

install_font() {
  local zip
  if has_font; then
    FONT="JetBrains Mono"
  elif [ "$DEPS" = 0 ]; then
    say "fonte JetBrains Mono não instalada (--no-deps)"
  elif [ "$DRY" = 1 ]; then
    say "[dry-run] baixaria a fonte JetBrains Mono para $FONTS_DIR"
  elif ! command -v curl >/dev/null || ! command -v unzip >/dev/null; then
    warn "sem curl ou unzip; a fonte JetBrains Mono fica para depois"
  else
    zip="$(mktemp)"
    if curl -fsSL -o "$zip" https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip >> "$LOG" 2>&1 \
       && mkdir -p "$FONTS_DIR" && unzip -qo -j "$zip" 'fonts/ttf/*.ttf' -d "$FONTS_DIR" >> "$LOG" 2>&1; then
      if command -v fc-cache >/dev/null; then fc-cache -f "$FONTS_DIR" >> "$LOG" 2>&1; fi
      record font "$FONTS_DIR"
      FONT="JetBrains Mono instalada"
    else
      warn "não consegui baixar a fonte JetBrains Mono; o resto segue normal"
    fi
    rm -f "$zip"
  fi
}

install_dependencies() {
  local missing=() package setup versions=""
  step 1 "dependências"
  command -v tmux >/dev/null || missing+=(tmux)
  if [ ${#missing[@]} -eq 0 ]; then
    say "tmux já instalado"
  elif [ "$DEPS" = 0 ]; then
    warn "faltando: ${missing[*]} — instale por conta (--no-deps)"
  else
    if [ -n "$SUDO" ] && [ "$PKG_MANAGER" != brew ] && [ "$FANCY" = 1 ]; then
      stop_spin; sudo -v; spin
    fi
    [ "$PKG_MANAGER" = apt-get ] && { run ${SUDO:+"$SUDO"} apt-get update -qq || true; }
    for package in "${missing[@]}"; do
      case "$PKG_MANAGER" in
        brew)    setup=(brew install "$package") ;;
        apt-get) setup=(${SUDO:+"$SUDO"} apt-get install -y "$package") ;;
        dnf)     setup=(${SUDO:+"$SUDO"} dnf install -y "$package") ;;
        pacman)  setup=(${SUDO:+"$SUDO"} pacman -S --needed --noconfirm "$package") ;;
        zypper)  setup=(${SUDO:+"$SUDO"} zypper install -y "$package") ;;
        apk)     setup=(${SUDO:+"$SUDO"} apk add "$package") ;;
        *)       warn "não reconheci o gerenciador de pacotes; instale: ${missing[*]}"; break ;;
      esac
      run "${setup[@]}" || warn "não consegui instalar $package pelo $PKG_MANAGER"
    done
  fi
  install_font
  if command -v tmux >/dev/null; then versions="tmux $(tmux -V | awk '{print $2}')"; fi
  summary "${versions}${FONT:+ · $FONT}"
  finish_step
}

install_code() {
  local origin_url
  if [ "$ROOT" = "$CODE" ]; then
    record code "$CODE"
  elif git -C "$ROOT" rev-parse >/dev/null 2>&1; then
    origin_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
    run rm -rf "$CODE"
    run mkdir -p "$(dirname "$CODE")"
    run git clone -q "$ROOT" "$CODE"
    [ -n "$origin_url" ] && run git -C "$CODE" remote set-url origin "$origin_url"
    run git -C "$CODE" checkout -q "$(git -C "$ROOT" rev-parse HEAD)"
    record code "$CODE"
    say "cópia do código em $(short_path "$CODE"), para o work update"
  else
    warn "$ROOT não é um clone do git; o work update não vai funcionar"
  fi
}

remove_old_scripts() {
  local tipo target
  [ -f "$MANIFEST" ] && [ "$DRY" = 0 ] || return 0
  while IFS='|' read -r tipo target _; do
    [ "$tipo" = script ] || continue
    [ "$(basename "$target")" = work ] && continue
    rm -f "$target"
    grep -vxF "script|$target|" "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
    say "$(basename "$target") saiu de $(short_path "$BIN_DIR"): só o work fica no PATH"
  done < <(grep '^script|' "$MANIFEST" || true)
}

install_scripts() {
  local target="$BIN_DIR/work"
  step 2 "scripts"
  run mkdir -p "$BIN_DIR"
  if [ -f "$target" ] && ! same_file "$ROOT/bin/work" "$target" && ! grep -qxF "script|$target|" "$MANIFEST" 2>/dev/null; then
    warn "work — já existe um work que não é do workdeck; não substituí"
  else
    say "work"
    run install -m 755 "$ROOT/bin/work" "$target"
    record script "$target"
  fi
  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) say "atenção: $BIN_DIR não está no PATH — o bloco do shell resolve isso" ;;
  esac
  install_code
  remove_old_scripts
  summary "work em $(short_path "$BIN_DIR")"
  finish_step
}

is_shipped_version() {
  local target="$1" path="$2" current c
  current="$(cksum < "$target")"
  git -C "$ROOT" rev-parse >/dev/null 2>&1 || return 1
  for c in $(git -C "$ROOT" log --format=%h -- "$path" 2>/dev/null); do
    [ "$(git -C "$ROOT" show "$c:$path" 2>/dev/null | cksum)" = "$current" ] && return 0
  done
  return 1
}

install_panels() {
  local old f panel name target
  for old in 10-maquina 00-comece-aqui 20-git; do
    f="$CONFIG_DIR/panels/$old"
    if [ -f "$f" ] && is_shipped_version "$f" "config/panels/$old"; then
      run rm -f "$f"
      say "painel antigo $old removido"
    fi
  done
  for panel in "$ROOT"/config/panels/*; do
    name="$(basename "$panel")"
    target="$CONFIG_DIR/panels/$name"
    if [ ! -f "$target" ]; then
      run install -m 755 "$panel" "$target"
      say "painel $name"
    elif [ ! -x "$target" ]; then
      say "painel $name desligado por você — não toquei nele"
    elif same_file "$panel" "$target"; then
      say "painel $name"
    elif is_shipped_version "$target" "config/panels/$name"; then
      run install -m 755 "$panel" "$target"
      say "painel $name atualizado"
    else
      say "painel $name foi editado por você — não toquei nele"
    fi
  done
}

install_config() {
  step 3 "config"
  run mkdir -p "$CONFIG_DIR/panels"
  if [ -f "$CONFIG_DIR/projects.conf" ]; then
    say "projects.conf já existe — não toquei nele"
  else
    say "projetos: adicione com work add <caminho>"
  fi
  install_panels
  if [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/git-review" ]; then
    run rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
    say "configuração antiga do git-review removida"
  fi
  summary "$(short_path "$CONFIG_DIR")"
  finish_step
}

configure_tmux_kitty() {
  step 4 "tmux e kitty"
  write_block "$HOME/.tmux.conf" \
    "$(sed '$d' "$ROOT/config/tmux.conf" | sed '/^# The theme is appended here/d'; cat "$ROOT/themes/$THEME.tmux"; echo '# <<< workdeck <<<')"
  say "tmux.conf — Ctrl+b, mouse e atalhos em Alt"
  summary "Ctrl+b, mouse e atalhos em Alt"
  if install_kitty; then
    apply_kitty
    summary "Ctrl+b, mouse e atalhos em Alt · kitty com tema e fonte"
  else
    summary "Ctrl+b, mouse e atalhos em Alt · sem o kitty"
  fi
  finish_step
}

has_custom_zsh() {
  [ -f "$HOME/.zshrc" ] && without_block "$HOME/.zshrc" \
    | grep -qE 'zsh-autosuggestions|fast-syntax-highlighting|zsh-syntax-highlighting|zinit|oh-my-zsh|starship|powerlevel10k|p10k|spaceship|pure' && return 0
  return 1
}

install_omz_zinit() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone -q --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" >> "$LOG" 2>&1 || return 1
    record omz "$HOME/.oh-my-zsh"
  fi
  if [ ! -f "$ZINIT_DIR/zinit.zsh" ]; then
    mkdir -p "$(dirname "$ZINIT_DIR")"
    git clone -q --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_DIR" >> "$LOG" 2>&1 || return 1
    record zinit "$(dirname "$ZINIT_DIR")"
  fi
  [ -d "$ZSH_PLUGINS" ] && rm -rf "$ZSH_PLUGINS"
  return 0
}

setup_zsh() {
  local choice r zsh_bin
  choice="$(cat "$ZSH_CHOICE" 2>/dev/null || true)"
  printf '%s' "$choice" > "$ZSH_CHOICE.previous" 2>/dev/null || true
  [ "$choice" = no ] && [ "$WANT_ZSH" = 0 ] && return 0
  if [ "$choice" != yes ]; then
    if has_custom_zsh; then
      say "zsh: você já tem plugins (oh-my-zsh, zinit ou outros); não mexi"
      return 0
    fi
    if [ "$WANT_ZSH" = 0 ] && can_ask; then
      stop_spin
      printf '  Quer o zsh do workdeck? Sugestões enquanto digita, cores nos comandos\n'
      printf '  e mais completar com Tab. [S/n] '
      read -r r || r=s
      spin
      case "$r" in ""|s|S|y|Y) ;; *) [ "$DRY" = 1 ] || { mkdir -p "$CONFIG_DIR"; echo no > "$ZSH_CHOICE"; }; return 0 ;; esac
    fi
  fi
  [ "$DRY" = 1 ] && { say "[dry-run] instalaria o zsh do workdeck"; return 0; }
  if ! command -v zsh >/dev/null; then
    if [ "$OS_NAME" != macOS ] && [ "$DEPS" = 1 ] && [ -n "$PKG_MANAGER" ]; then
      stop_spin
      case "$PKG_MANAGER" in
        apt-get) ${SUDO:+"$SUDO"} apt-get install -y zsh ;;
        dnf) ${SUDO:+"$SUDO"} dnf install -y zsh ;;
        pacman) ${SUDO:+"$SUDO"} pacman -S --needed --noconfirm zsh ;;
        zypper) ${SUDO:+"$SUDO"} zypper install -y zsh ;;
        apk) ${SUDO:+"$SUDO"} apk add zsh ;;
      esac >> "$LOG" 2>&1 || true
      spin
    fi
    command -v zsh >/dev/null || { warn "não consegui instalar o zsh; instale pelo gerenciador e rode a instalação de novo com --zsh"; return 0; }
  fi
  zsh_bin="$(command -v zsh)"
  if [ "$(basename "${SHELL:-}")" != zsh ]; then
    stop_spin
    printf '  Usar o zsh como o seu shell padrão? Pede a sua senha. [S/n] '
    read -r r </dev/tty 2>/dev/null || r=n
    spin
    case "${r:-s}" in
      s|S|y|Y)
        stop_spin
        grep -qx "$zsh_bin" /etc/shells 2>/dev/null || echo "$zsh_bin" | ${SUDO:+"$SUDO"} tee -a /etc/shells >/dev/null
        if chsh -s "$zsh_bin" </dev/tty; then SHELL="$zsh_bin"; RESTART_SHELL=1; else warn "não troquei o shell padrão; dá para fazer depois com: chsh -s $zsh_bin"; fi
        spin ;;
    esac
  fi
  if install_omz_zinit; then
    mkdir -p "$CONFIG_DIR"; echo yes > "$ZSH_CHOICE"
    ZSH_SUMMARY="oh-my-zsh (robbyrussell) e zinit"
    [ "$(cat "$ZSH_CHOICE.previous" 2>/dev/null)" = yes ] || RESTART_SHELL=1
  else
    warn "não consegui baixar o oh-my-zsh ou o zinit; rode a instalação de novo com --zsh mais tarde"
  fi
}

configure_shell() {
  local rc=""
  step 5 "shell"
  setup_zsh
  case "$(basename "${SHELL:-/bin/bash}")" in
    zsh)  rc="$HOME/.zshrc" ;;
    bash) if [ "$OS_NAME" = "macOS" ]; then rc="$HOME/.bash_profile"; else rc="$HOME/.bashrc"; fi ;;
  esac
  if [ -n "$rc" ]; then
    write_block "$rc" "$(cat "$ROOT/config/shell-snippet.sh")"
    if [ "$(cat "$ZSH_CHOICE" 2>/dev/null)" = yes ] && [ "$DRY" = 0 ] && command -v zsh >/dev/null; then
      zsh -i -c exit </dev/null >> "$LOG" 2>&1 || true
    fi
    say "$(basename "$rc")"
    summary "$(short_path "$rc")${ZSH_SUMMARY:+ · $ZSH_SUMMARY}"
  else
    warn "shell '$SHELL' não reconhecido — adicione à mão: source $ROOT/config/shell-snippet.sh"
  fi
  finish_step
}

configure_agent() {
  local current_agent="" found=() c a i choice
  step 6 "agente de IA"
  [ -f "$CONFIG_DIR/agent.conf" ] && current_agent="$(. "$CONFIG_DIR/agent.conf"; echo "${AGENT_CMD:-}")"
  if [ -n "$AGENT" ]; then
    run "$ROOT/bin/workdeck-agent" --set "$AGENT" && say "agente: $AGENT"
    summary "$AGENT"
  elif [ -n "$current_agent" ]; then
    say "agente já configurado: $current_agent"
    summary "$current_agent"
  else
    for c in $KNOWN_AGENTS; do
      command -v "$c" >/dev/null && found+=("$c")
    done
    if [ ${#found[@]} -eq 0 ]; then
      say "nenhum agente de IA encontrado no PATH"
      say "o work review usa a IA que estiver aberta na janela"
      summary "nenhum no PATH; o review usa a IA aberta na janela"
    elif [ "$YES" = 1 ] || [ ! -t 0 ]; then
      say "achei no PATH: ${found[*]}"
      say "o work review usa a IA que estiver aberta na janela"
      summary "achei ${found[*]}; o review usa a IA aberta na janela"
    else
      stop_spin
      echo
      echo "  Achei estes agentes de IA no seu PATH:"
      i=1; for a in "${found[@]}"; do echo "    $i) $a"; i=$((i+1)); done
      echo "    0) nenhum por enquanto"
      echo
      printf '  Qual você usa? [0-%s] ' "${#found[@]}"
      read -r choice || choice=0
      if [ "${choice:-0}" -ge 1 ] 2>/dev/null && [ "$choice" -le "${#found[@]}" ]; then
        run "$ROOT/bin/workdeck-agent" --set "${found[$((choice-1))]}" >/dev/null \
          && say "agente: ${found[$((choice-1))]}"
        summary "${found[$((choice-1))]}"
      else
        say "nenhum padrão; o work review usa a IA aberta na janela"
        summary "nenhum padrão; o review usa a IA aberta na janela"
      fi
      echo
    fi
  fi
  finish_step
}

ask_integrations() {
  local available=() f n i choice e
  for f in "$ROOT"/integrations/*.sh; do
    [ "$(basename "$f")" = example.sh ] || available+=("$(basename "$f" .sh)")
  done
  [ ${#available[@]} -gt 0 ] || return 0
  stop_spin
  echo
  echo "  Você usa algum destes com a IA? O workdeck mostra como ligar cada um."
  i=1
  for n in "${available[@]}"; do
    printf '    %s) %-10s %s%s%s\n' "$i" "$n" "$dim" "$(. "$ROOT/integrations/$n.sh"; describe | sed -n 2p)" "$reset"
    i=$((i+1))
  done
  echo
  printf '  Quais? Números separados por espaço, Enter para nenhum: '
  read -r choice || choice=""
  for e in ${choice//,/ }; do
    if [ "$e" -ge 1 ] 2>/dev/null && [ "$e" -le "${#available[@]}" ]; then
      case ",$WITH," in *",${available[$((e-1))]},"*) ;; *) WITH="${WITH:+$WITH,}${available[$((e-1))]}" ;; esac
    fi
  done
  [ "$DRY" = 1 ] || { mkdir -p "$CONFIG_DIR"; echo "${WITH:-none}" > "$INTEGRATIONS_CHOICE"; }
  CHOSEN=1
  spin
}

enable_integration() {
  local name="$1" file_path="$ROOT/integrations/$1.sh"
  if [ ! -f "$file_path" ]; then
    warn "não conheço a integração '$name'"
    return 0
  fi
  (
    . "$file_path"
    title="$(describe | head -1)"
    if is_installed 2>/dev/null; then
      say "$title já está instalada"
      if declare -F usage >/dev/null; then echo; usage | sed 's/^/    /'; fi
      exit 0
    fi
    echo
    describe | sed 's/^/    /'
    echo
    if [ "$YES" = 0 ] && [ "$CHOSEN" = 0 ] && [ -t 0 ]; then
      printf '  Instalar %s? [s/N] ' "$title"
      read -r r || r=n
      case "$r" in s|S|y|Y) ;; *) say "pulada"; exit 0 ;; esac
    fi
    [ "$DRY" = 1 ] && { say "[dry-run] instalaria $title"; exit 0; }
    setup | sed 's/^/    /'
    if declare -F usage >/dev/null; then echo; usage | sed 's/^/    /'; fi
  )
}

configure_integrations() {
  local requested=() name
  step 7 "integrações"
  if [ -z "$WITH" ] && [ ! -f "$INTEGRATIONS_CHOICE" ] && can_ask; then
    ask_integrations
  fi
  if [ -z "$WITH" ]; then
    if [ -f "$INTEGRATIONS_CHOICE" ] && [ "$(cat "$INTEGRATIONS_CHOICE")" != none ]; then
      say "escolhidas antes: $(cat "$INTEGRATIONS_CHOICE"); para ver de novo: rode a instalação de novo com --with <nome>"
      summary "$(cat "$INTEGRATIONS_CHOICE")"
    else
      say "nenhuma; para ligar depois: rode a instalação de novo com --with <nome>"
      summary "nenhuma (--with <nome>)"
    fi
  else
    stop_spin
    summary "$WITH"
    IFS=',' read -r -a requested <<< "$WITH"
    for name in "${requested[@]}"; do enable_integration "$name"; done
  fi
  finish_step
}

finish() {
  local open_hint
  if [ "$RELOAD" = 1 ] && command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
    run tmux source-file "$HOME/.tmux.conf" && say "tmux recarregado"
  fi
  rm -f "$ZSH_CHOICE.previous"
  if [ -n "$UPDATING" ]; then
    if [ "$RESTART_SHELL" = 1 ]; then
      printf '\n  %s●%s Feche e abra o kitty para carregar o zsh e o visual novos.\n' "$yellow" "$reset"
    fi
    exit 0
  fi
  if [ "$FANCY" = 1 ]; then
    printf '\n  %s✓ pronto em %ss%s\n' "$green" "$SECONDS" "$reset"
  else
    echo "Pronto."
  fi
  if in_kitty; then
    open_hint="${bold}feche e abra o kitty${reset}     ${dim}carrega o zsh, o visual e os comandos do workdeck${reset}"
  elif kitty_installed; then
    open_hint="${bold}abra o kitty${reset}              ${dim}com o tema, a fonte e os atalhos cmd do workdeck${reset}"
  else
    open_hint="${bold}feche e abra o terminal${reset}   ${dim}carrega o zsh e os comandos do workdeck${reset}"
  fi
  cat <<EOF

  Agora:
       $open_hint
       work                      ${dim}abre o painel, que mostra como adicionar os projetos${reset}

  Para navegar: Shift+← / Shift+→ troca de janela, Shift+↑ / Shift+↓ troca de
  painel, e Ctrl+b e depois 1…9 vai direto para uma janela. Clicar na barra
  também funciona.
  Ajuda a qualquer hora: Ctrl+b e h dentro do work.
EOF
}

main() {
  parse_options "$@"
  setup_output
  [ "$DRY" = 1 ] || migrate_legacy_config
  choose_theme
  detect_system
  show_header
  install_dependencies
  install_scripts
  install_config
  configure_tmux_kitty
  configure_shell
  configure_agent
  configure_integrations
  finish
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
