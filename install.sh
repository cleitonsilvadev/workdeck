#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/common.sh"

CONFIG_DIR="$WORKDECK_CONFIG"
BIN_DIR="$WORKDECK_BIN"
CODE="$WORKDECK_CODE"
BACKUPS="$CONFIG_DIR/.backups"
MANIFEST="$CONFIG_DIR/.install-manifest"
ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck-zsh"
ZINIT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
KITTY_DOWNLOAD="https://sw.kovidgoyal.net/kitty/binary/"
WARP_DOWNLOAD="https://www.warp.dev/download"

THEME=""
LANGUAGE=""
LANGUAGE_REQUESTED=""
LINUX_LEGACY=0
WANT_ZSH=0
TERMINAL=""
TERMINAL_REQUESTED=""
VISUAL=""
VISUAL_REQUESTED=""
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
      --theme) THEME="$(option_value "$@")"; shift 2 ;;
      --agent) AGENT="$(option_value "$@")"; shift 2 ;;
      --with) WITH="$(option_value "$@")"; shift 2 ;;
      --lang)
        LANGUAGE_REQUESTED="$(option_value "$@")"
        valid_language "$LANGUAGE_REQUESTED" || { msgln install_bad_lang "$LANGUAGE_REQUESTED"; exit 1; }
        load_messages "$LANGUAGE_REQUESTED"
        shift 2 ;;
      --yes|-y) YES=1; shift ;;
      --list-integrations) list_integrations; exit 0 ;;
      --terminal)
        TERMINAL_REQUESTED="$(option_value "$@")"
        valid_terminal "$TERMINAL_REQUESTED" || { msgln install_bad_terminal "$TERMINAL_REQUESTED"; exit 1; }
        shift 2 ;;
      --visual) VISUAL_REQUESTED=yes; shift ;;
      --no-visual) VISUAL_REQUESTED=no; shift ;;
      --no-deps) DEPS=0; shift ;;
      --zsh) WANT_ZSH=1; shift ;;
      --no-reload) RELOAD=0; shift ;;
      --dry-run) DRY=1; shift ;;
      -h|--help) msgln install_help; exit 0 ;;
      *) msgln install_unknown_option "$1"; exit 1 ;;
    esac
  done
}

option_value() {
  if [ $# -lt 2 ] || [ -z "$2" ]; then msg install_needs_value "$1" >&2; echo >&2; exit 1; fi
  printf '%s' "$2"
}

valid_language() {
  case "$1" in
    en|pt-BR) return 0 ;;
    *) return 1 ;;
  esac
}

language_name() {
  case "$1" in
    pt-BR) echo Português ;;
    *) echo English ;;
  esac
}

ask_language() {
  local answer
  echo
  echo "  $(msg install_ask_language)"
  echo "    1) English"
  echo "    2) Português"
  echo
  printf '  %s' "$(msg install_ask_number "$(language_name "$LANGUAGE")")"
  read -r answer || answer=""
  case "$answer" in
    1) LANGUAGE=en ;;
    2) LANGUAGE=pt-BR ;;
  esac
}

choose_language() {
  LANGUAGE="${LANGUAGE_REQUESTED:-$(setting_get LANGUAGE)}"
  if ! valid_language "$LANGUAGE"; then
    if [ -f "$MANIFEST" ]; then LANGUAGE=pt-BR; else LANGUAGE="$(workdeck_language)"; fi
    load_messages "$LANGUAGE"
    can_ask && ask_language
  fi
  load_messages "$LANGUAGE"
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
    warn "$(msg install_not_regular "$(short_path "$file")")"
    return 0
  fi
  backup="$(backup_file "$file")"
  [ -n "$backup" ] && say "$(msg install_backup "${backup#"$HOME"/}")"
  [ -e "$file" ] || backup=":created"
  grep -qF "block|$file|" "$MANIFEST" 2>/dev/null || record block "$file" "$backup"
  [ "$DRY" = 1 ] && { say "$(msg install_dry_block "$file")"; return 0; }
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
  local saved
  saved="$(setting_get THEME)"
  if [ -z "$THEME" ]; then
    THEME="$saved"
    [ -f "$ROOT/themes/${THEME:-_}.conf" ] || THEME="catppuccin-mocha"
  fi
  if [ ! -f "$ROOT/themes/$THEME.conf" ]; then
    local t
    msgln install_bad_theme "$THEME"
    for t in "$ROOT"/themes/*.conf; do t="$(basename "$t")"; echo "  ${t%.conf}"; done
    exit 1
  fi
  save_choice THEME "$THEME"
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
    msgln install_header_plain "$OS_NAME" "$THEME"
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

apply_kitty() {
  local block
  block="$(sed '$d' "$ROOT/terminals/kitty.conf" | sed '/^# The theme is appended here/d')"
  [ "$OS_NAME" = macOS ] || block="$(printf '%s\n' "$block" | grep -v '^map cmd\|^macos_')"
  if [ "$VISUAL" = yes ]; then
    block="$(printf '%s\n\n%s\n%s\n' "$block" "$(cat "$ROOT/terminals/kitty-visual.conf")" "$(cat "$ROOT/themes/$THEME.conf")")"
  fi
  write_block "$HOME/.config/kitty/kitty.conf" "$(printf '%s\n' "$block"; echo '# <<< workdeck <<<')"
  if [ "$VISUAL" = yes ]; then say "$(msg install_kitty_full)"; else say "$(msg install_kitty_keys)"; fi
}

kitty_block_has_visual() {
  sed -n '/^# >>> workdeck >>>$/,/^# <<< workdeck <<<$/p' "$HOME/.config/kitty/kitty.conf" 2>/dev/null \
    | grep -q '^font_family'
}

in_warp() { [ -n "${WARP_CLIENT_VERSION:-}" ]; }

current_terminal_name() {
  if in_kitty; then echo kitty
  elif in_warp; then echo Warp
  else echo terminal
  fi
}

warp_installed() {
  in_warp && return 0
  [ -d /Applications/Warp.app ] || [ -d "$HOME/Applications/Warp.app" ] && return 0
  command -v warp-terminal >/dev/null
}

valid_terminal() {
  case "$1" in
    kitty|warp|other) return 0 ;;
    *) return 1 ;;
  esac
}

detected_terminal() {
  in_kitty && { echo kitty; return 0; }
  in_warp && { echo warp; return 0; }
  kitty_installed && { echo kitty; return 0; }
  warp_installed && { echo warp; return 0; }
  echo other
}

chosen_terminal_name() {
  case "$TERMINAL" in
    warp) echo Warp ;;
    other) msgln install_other_terminal ;;
    *) echo "$TERMINAL" ;;
  esac
}

ask_terminal() {
  local answer
  stop_spin
  echo
  echo "  $(msg install_ask_terminal)"
  printf '    1) %-7s %s%s%s\n' kitty "$dim" "$(msg install_terminal_kitty)" "$reset"
  printf '    2) %-7s %s%s%s\n' Warp "$dim" "$(msg install_terminal_warp)" "$reset"
  printf '    3) %-7s %s%s%s\n' "$(msg install_other_terminal)" "$dim" "$(msg install_terminal_other)" "$reset"
  echo
  printf '  %s' "$(msg install_ask_number "$(chosen_terminal_name)")"
  read -r answer || answer=""
  spin
  case "$answer" in
    1) TERMINAL=kitty ;;
    2) TERMINAL=warp ;;
    3) TERMINAL=other ;;
  esac
}

# A key that already holds this value is left alone, so a reinstall does not
# rewrite the user's file.
save_choice() {
  [ "$DRY" = 1 ] && return 0
  setting_has "$1" && [ "$(setting_get "$1")" = "$2" ] && return 0
  setting_set "$1" "$2"
}

choose_terminal() {
  TERMINAL="${TERMINAL_REQUESTED:-$(setting_get TERMINAL)}"
  if valid_terminal "$TERMINAL"; then
    save_choice TERMINAL "$TERMINAL"
    return 0
  fi
  TERMINAL="$(detected_terminal)"
  can_ask || return 0
  ask_terminal
  save_choice TERMINAL "$TERMINAL"
}

terminal_has_visual() { [ "$TERMINAL" = kitty ] || [ "$TERMINAL" = warp ]; }

ask_visual() {
  local answer
  stop_spin
  echo
  printf '  %s' "$(msg install_ask_visual "$(chosen_terminal_name)")"
  read -r answer || answer=n
  spin
  case "${answer:-n}" in
    s|S|y|Y) VISUAL=yes ;;
    *) VISUAL=no ;;
  esac
}

choose_visual() {
  VISUAL=""
  terminal_has_visual || return 0
  VISUAL="${VISUAL_REQUESTED:-$(setting_get VISUAL)}"
  if [ "$VISUAL" = yes ] || [ "$VISUAL" = no ]; then
    save_choice VISUAL "$VISUAL"
    return 0
  fi
  if [ "$TERMINAL" = kitty ] && kitty_block_has_visual; then
    VISUAL=yes
    save_choice VISUAL "$VISUAL"
    return 0
  fi
  VISUAL=no
  can_ask || return 0
  ask_visual
  save_choice VISUAL "$VISUAL"
}

warp_themes_dir() {
  if [ "$OS_NAME" = macOS ]; then echo "$HOME/.warp/themes"
  else echo "${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal/themes"
  fi
}

apply_warp_theme() {
  local dest
  dest="$(warp_themes_dir)/workdeck-$THEME.yaml"
  record warp-theme "$dest"
  [ "$DRY" = 1 ] && { say "$(msg install_dry_warp_theme "$dest")"; return 0; }
  mkdir -p "$(dirname "$dest")"
  cp "$ROOT/themes/$THEME.warp.yaml" "$dest"
  say "$(msg install_warp_theme "$(short_path "$dest")")"
}

configure_kitty() {
  if ! kitty_installed; then
    warn "$(msg install_kitty_missing "$KITTY_DOWNLOAD")"
    summary "$SUMMARY · $(msg install_kitty_missing_short)"
    return 0
  fi
  apply_kitty
  if [ "$VISUAL" = yes ]; then
    install_font
    summary "$SUMMARY · $(msg install_kitty_summary_full)"
    return 0
  fi
  summary "$SUMMARY · $(msg install_kitty_summary_keys)"
}

configure_warp() {
  if ! warp_installed; then
    warn "$(msg install_warp_missing "$WARP_DOWNLOAD")"
    summary "$SUMMARY · $(msg install_warp_missing_short)"
    return 0
  fi
  say "$(msg install_warp_found)"
  if [ "$VISUAL" = yes ]; then
    apply_warp_theme
    install_font
    summary "$SUMMARY · $(msg install_warp_summary_full)"
    return 0
  fi
  summary "$SUMMARY · Warp"
}

configure_terminal() {
  rm -f "$CONFIG_DIR/kitty"
  case "$TERMINAL" in
    kitty) configure_kitty ;;
    warp) configure_warp ;;
    *) say "$(msg install_no_terminal_changes)" ;;
  esac
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
    say "$(msg install_font_present)"
  elif [ "$DEPS" = 0 ]; then
    say "$(msg install_font_no_deps)"
  elif [ "$DRY" = 1 ]; then
    say "$(msg install_dry_font "$FONTS_DIR")"
  elif ! command -v curl >/dev/null || ! command -v unzip >/dev/null; then
    warn "$(msg install_font_no_tools)"
  else
    zip="$(mktemp)"
    if curl -fsSL -o "$zip" https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip >> "$LOG" 2>&1 \
       && mkdir -p "$FONTS_DIR" && unzip -qo -j "$zip" 'fonts/ttf/*.ttf' -d "$FONTS_DIR" >> "$LOG" 2>&1; then
      if command -v fc-cache >/dev/null; then fc-cache -f "$FONTS_DIR" >> "$LOG" 2>&1; fi
      record font "$FONTS_DIR"
      say "$(msg install_font_done "$(short_path "$FONTS_DIR")")"
    else
      warn "$(msg install_font_failed)"
    fi
    rm -f "$zip"
  fi
}

install_dependencies() {
  local missing=() package setup versions=""
  step 1 "$(msg install_step_deps)"
  command -v tmux >/dev/null || missing+=(tmux)
  if [ ${#missing[@]} -eq 0 ]; then
    say "$(msg install_tmux_present)"
  elif [ "$DEPS" = 0 ]; then
    warn "$(msg install_missing_no_deps "${missing[*]}")"
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
        *)       warn "$(msg install_unknown_pkg "${missing[*]}")"; break ;;
      esac
      run "${setup[@]}" || warn "$(msg install_pkg_failed "$package" "$PKG_MANAGER")"
    done
  fi
  if command -v tmux >/dev/null; then versions="tmux $(tmux -V | awk '{print $2}')"; fi
  summary "$versions"
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
    say "$(msg install_code_copy "$(short_path "$CODE")")"
  else
    warn "$(msg install_not_clone "$ROOT")"
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
    say "$(msg install_script_moved "$(basename "$target")" "$(short_path "$BIN_DIR")")"
  done < <(grep '^script|' "$MANIFEST" || true)
}

install_scripts() {
  local target="$BIN_DIR/work"
  step 2 "$(msg install_step_scripts)"
  run mkdir -p "$BIN_DIR"
  if [ -f "$target" ] && ! same_file "$ROOT/bin/work" "$target" && ! grep -qxF "script|$target|" "$MANIFEST" 2>/dev/null; then
    warn "$(msg install_work_exists)"
  else
    say "work"
    run install -m 755 "$ROOT/bin/work" "$target"
    record script "$target"
  fi
  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) say "$(msg install_not_in_path "$BIN_DIR")" ;;
  esac
  install_code
  remove_old_scripts
  summary "$(msg install_scripts_summary "$(short_path "$BIN_DIR")")"
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
      say "$(msg install_old_panel "$old")"
    fi
  done
  for panel in "$ROOT"/config/panels/*; do
    name="$(basename "$panel")"
    target="$CONFIG_DIR/panels/$name"
    if [ ! -f "$target" ]; then
      run install -m 755 "$panel" "$target"
      say "$(msg install_panel "$name")"
    elif [ ! -x "$target" ]; then
      say "$(msg install_panel_off "$name")"
    elif same_file "$panel" "$target"; then
      say "$(msg install_panel "$name")"
    elif is_shipped_version "$target" "config/panels/$name"; then
      run install -m 755 "$panel" "$target"
      say "$(msg install_panel_updated "$name")"
    else
      say "$(msg install_panel_edited "$name")"
    fi
  done
}

localize_panel_window() {
  local file="$1" name
  name="$(msg window_panel)"
  grep -qE "^(painel|panel)\|[^|]*\|work-panel" "$file" || return 0
  grep -qE "^$name\|[^|]*\|work-panel" "$file" && return 0
  [ "$DRY" = 1 ] && return 0
  awk -v name="$name" -F'|' 'BEGIN { OFS = "|" } ($1 == "painel" || $1 == "panel") && $3 ~ /^work-panel/ { $1 = name } { print }' "$file" > "$file.tmp" \
    && cat "$file.tmp" > "$file" && rm -f "$file.tmp"
}

install_config() {
  step 3 "$(msg install_step_config)"
  run mkdir -p "$CONFIG_DIR/panels"
  if [ -f "$CONFIG_DIR/projects.conf" ]; then
    localize_panel_window "$CONFIG_DIR/projects.conf"
    say "$(msg install_projects_exists)"
  else
    say "$(msg install_projects_hint)"
  fi
  install_panels
  if [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/git-review" ]; then
    run rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
    say "$(msg install_git_review_removed)"
  fi
  summary "$(short_path "$CONFIG_DIR")"
  finish_step
}

fill_messages() {
  local text marker key
  text="$(cat)"
  for marker in $(printf '%s\n' "$text" | grep -o '{{msg:[a-z0-9_]*}}' | sort -u); do
    key="${marker#??msg:}"
    key="${key%??}"
    text="$(printf '%s\n' "$text" | WD_MARKER="$marker" WD_VALUE="$(msg "$key")" awk '
      BEGIN {
        marker = ENVIRON["WD_MARKER"]; value = ENVIRON["WD_VALUE"]
        gsub(/#/, "##", value); gsub(/"/, "\\\"", value)
      }
      {
        line = $0; out = ""
        while ((i = index(line, marker)) > 0) { out = out substr(line, 1, i - 1) value; line = substr(line, i + length(marker)) }
        print out line
      }')"
  done
  printf '%s\n' "$text"
}

configure_tmux_and_terminal() {
  step 4 "$(msg install_step_tmux)"
  write_block "$HOME/.tmux.conf" \
    "$(sed '$d' "$ROOT/config/tmux.conf" | sed '/^# The theme is appended here/d' | fill_messages; cat "$ROOT/themes/$THEME.tmux"; echo "run-shell -b \"$BIN_DIR/work _settings\""; echo '# <<< workdeck <<<')"
  say "$(msg install_tmux_done)"
  summary "$(msg install_tmux_summary)"
  choose_terminal
  choose_visual
  configure_terminal
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
  local choice previous r zsh_bin
  choice="$(setting_get ZSH)"
  previous="$choice"
  [ "$choice" = no ] && [ "$WANT_ZSH" = 0 ] && return 0
  if [ "$choice" != yes ]; then
    if has_custom_zsh; then
      say "$(msg install_zsh_custom)"
      return 0
    fi
    if [ "$WANT_ZSH" = 0 ] && can_ask; then
      stop_spin
      printf '  %s' "$(msg install_ask_zsh)"
      read -r r || r=s
      spin
      case "$r" in ""|s|S|y|Y) ;; *) save_choice ZSH no; return 0 ;; esac
    fi
  fi
  [ "$DRY" = 1 ] && { say "$(msg install_dry_zsh)"; return 0; }
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
    command -v zsh >/dev/null || { warn "$(msg install_zsh_failed)"; return 0; }
  fi
  zsh_bin="$(command -v zsh)"
  if [ "$(basename "${SHELL:-}")" != zsh ]; then
    stop_spin
    printf '  %s' "$(msg install_ask_chsh)"
    read -r r </dev/tty 2>/dev/null || r=n
    spin
    case "${r:-s}" in
      s|S|y|Y)
        stop_spin
        grep -qx "$zsh_bin" /etc/shells 2>/dev/null || echo "$zsh_bin" | ${SUDO:+"$SUDO"} tee -a /etc/shells >/dev/null
        if chsh -s "$zsh_bin" </dev/tty; then SHELL="$zsh_bin"; RESTART_SHELL=1; else warn "$(msg install_chsh_failed "$zsh_bin")"; fi
        spin ;;
    esac
  fi
  if install_omz_zinit; then
    save_choice ZSH yes
    ZSH_SUMMARY="$(msg install_zsh_summary)"
    [ "$previous" = yes ] || RESTART_SHELL=1
  else
    warn "$(msg install_omz_failed)"
  fi
}

configure_shell() {
  local rc=""
  step 5 "$(msg install_step_shell)"
  setup_zsh
  case "$(basename "${SHELL:-/bin/bash}")" in
    zsh)  rc="$HOME/.zshrc" ;;
    bash) if [ "$OS_NAME" = "macOS" ]; then rc="$HOME/.bash_profile"; else rc="$HOME/.bashrc"; fi ;;
  esac
  if [ -n "$rc" ]; then
    write_block "$rc" "$(cat "$ROOT/config/shell-snippet.sh")"
    if [ "$(setting_get ZSH)" = yes ] && [ "$DRY" = 0 ] && command -v zsh >/dev/null; then
      zsh -i -c exit </dev/null >> "$LOG" 2>&1 || true
    fi
    say "$(basename "$rc")"
    summary "$(short_path "$rc")${ZSH_SUMMARY:+ · $ZSH_SUMMARY}"
  else
    warn "$(msg install_unknown_shell "$SHELL" "$ROOT/config/shell-snippet.sh")"
  fi
  finish_step
}

configure_agent() {
  local current_agent="" found=() c a i choice
  step 6 "$(msg install_step_agent)"
  current_agent="$(setting_get AGENT_CMD)"
  if [ -n "$AGENT" ]; then
    run "$ROOT/bin/workdeck-agent" --set "$AGENT" && say "$(msg install_agent "$AGENT")"
    summary "$AGENT"
  elif [ -n "$current_agent" ]; then
    say "$(msg install_agent_set "$current_agent")"
    summary "$current_agent"
  else
    for c in $KNOWN_AGENTS; do
      command -v "$c" >/dev/null && found+=("$c")
    done
    if [ ${#found[@]} -eq 0 ]; then
      say "$(msg install_no_agent)"
      say "$(msg install_review_uses_open)"
      summary "$(msg install_no_agent_summary)"
    elif [ "$YES" = 1 ] || [ ! -t 0 ]; then
      say "$(msg install_found_agents "${found[*]}")"
      say "$(msg install_review_uses_open)"
      summary "$(msg install_found_agents_summary "${found[*]}")"
    else
      stop_spin
      echo
      echo "  $(msg install_ask_agent)"
      i=1; for a in "${found[@]}"; do echo "    $i) $a"; i=$((i+1)); done
      echo "    0) $(msg install_agent_none_option)"
      echo
      printf '  %s' "$(msg install_ask_agent_number "${#found[@]}")"
      read -r choice || choice=0
      if [ "${choice:-0}" -ge 1 ] 2>/dev/null && [ "$choice" -le "${#found[@]}" ]; then
        run "$ROOT/bin/workdeck-agent" --set "${found[$((choice-1))]}" >/dev/null \
          && say "$(msg install_agent "${found[$((choice-1))]}")"
        summary "${found[$((choice-1))]}"
      else
        say "$(msg install_no_default_agent)"
        summary "$(msg install_no_default_agent_summary)"
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
  echo "  $(msg install_ask_integrations)"
  i=1
  for n in "${available[@]}"; do
    printf '    %s) %-10s %s%s%s\n' "$i" "$n" "$dim" "$(. "$ROOT/integrations/$n.sh"; describe | sed -n 2p)" "$reset"
    i=$((i+1))
  done
  echo
  printf '  %s' "$(msg install_ask_integration_numbers)"
  read -r choice || choice=""
  for e in ${choice//,/ }; do
    if [ "$e" -ge 1 ] 2>/dev/null && [ "$e" -le "${#available[@]}" ]; then
      case ",$WITH," in *",${available[$((e-1))]},"*) ;; *) WITH="${WITH:+$WITH,}${available[$((e-1))]}" ;; esac
    fi
  done
  save_choice INTEGRATIONS "${WITH:-none}"
  CHOSEN=1
  spin
}

enable_integration() {
  local name="$1" file_path="$ROOT/integrations/$1.sh"
  if [ ! -f "$file_path" ]; then
    warn "$(msg install_unknown_integration "$name")"
    return 0
  fi
  (
    . "$file_path"
    title="$(describe | head -1)"
    if is_installed 2>/dev/null; then
      say "$(msg install_integration_present "$title")"
      if declare -F usage >/dev/null; then echo; usage | sed 's/^/    /'; fi
      exit 0
    fi
    echo
    describe | sed 's/^/    /'
    echo
    if [ "$YES" = 0 ] && [ "$CHOSEN" = 0 ] && [ -t 0 ]; then
      printf '  %s' "$(msg install_ask_integration "$title")"
      read -r r || r=n
      case "$r" in s|S|y|Y) ;; *) say "$(msg install_skipped)"; exit 0 ;; esac
    fi
    [ "$DRY" = 1 ] && { say "$(msg install_dry_integration "$title")"; exit 0; }
    setup | sed 's/^/    /'
    if declare -F usage >/dev/null; then echo; usage | sed 's/^/    /'; fi
  )
}

configure_integrations() {
  local requested=() name
  step 7 "$(msg install_step_integrations)"
  if [ -z "$WITH" ] && ! setting_has INTEGRATIONS && can_ask; then
    ask_integrations
  fi
  if [ -z "$WITH" ]; then
    if setting_has INTEGRATIONS && [ "$(setting_get INTEGRATIONS)" != none ]; then
      say "$(msg install_integrations_before "$(setting_get INTEGRATIONS)")"
      summary "$(setting_get INTEGRATIONS)"
    else
      say "$(msg install_integrations_none)"
      summary "$(msg install_integrations_none_summary)"
    fi
  else
    stop_spin
    summary "$WITH"
    IFS=',' read -r -a requested <<< "$WITH"
    for name in "${requested[@]}"; do enable_integration "$name"; done
  fi
  finish_step
}

choice_status() {
  setting_has "$1" && return 0
  msg install_not_saved
}

show_choices() {
  local visual
  visual="$(msg install_no)"
  printf '\n  %s\n' "$(msg install_choices)"
  printf '       %-9s %s%s\n' "$(msg install_choice_language)" "$(language_name "$LANGUAGE")" "$(choice_status LANGUAGE)"
  printf '                 %s\n' "$(msg install_choice_language_hint)"
  printf '       terminal  %s%s\n' "$(chosen_terminal_name)" "$(choice_status TERMINAL)"
  printf '                 %s\n' "$(msg install_choice_terminal_hint)"
  terminal_has_visual || return 0
  [ "$VISUAL" = yes ] && visual="$(msg install_yes)"
  printf '       visual    %s%s\n' "$visual" "$(choice_status VISUAL)"
  printf '                 %s\n' "$(msg install_choice_visual_hint)"
}

teach_warp() {
  [ "$TERMINAL" = warp ] || return 0
  warp_installed || return 0
  [ "$VISUAL" = yes ] || [ "$OS_NAME" = macOS ] || return 0
  printf '\n  %s\n' "$(msg install_warp_todo)"
  if [ "$VISUAL" = yes ]; then
    printf '%s\n' "$(msg install_warp_theme_steps "$THEME")"
  fi
  [ "$OS_NAME" = macOS ] || return 0
  printf '%s\n' "$(msg install_warp_option_steps)"
}

finish() {
  local open_hint
  if [ "$RELOAD" = 1 ] && command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
    run tmux source-file "$HOME/.tmux.conf" && say "$(msg install_tmux_reloaded)"
  fi
  if [ -n "$UPDATING" ]; then
    if [ "$RESTART_SHELL" = 1 ]; then
      printf '\n  %s●%s %s\n' "$yellow" "$reset" "$(msg install_restart_terminal "$(current_terminal_name)")"
    fi
    exit 0
  fi
  if [ "$FANCY" = 1 ]; then
    printf '\n  %s%s%s\n' "$green" "$(msg install_done_fancy "$SECONDS")" "$reset"
  else
    msgln install_done
  fi
  if in_kitty; then
    open_hint="$(next_step "$(msg install_open_kitty_restart)" "$(msg install_open_kitty_restart_hint)")"
  elif in_warp; then
    open_hint="$(next_step "$(msg install_open_warp_restart)" "$(msg install_open_terminal_restart_hint)")"
  elif [ "$TERMINAL" = kitty ] && kitty_installed && [ "$VISUAL" = yes ]; then
    open_hint="$(next_step "$(msg install_open_kitty)" "$(msg install_open_kitty_visual_hint)")"
  elif [ "$TERMINAL" = kitty ] && kitty_installed; then
    open_hint="$(next_step "$(msg install_open_kitty)" "$(msg install_open_kitty_hint)")"
  else
    open_hint="$(next_step "$(msg install_open_terminal_restart)" "$(msg install_open_terminal_restart_hint)")"
  fi
  printf '\n  %s\n' "$(msg install_now)"
  printf '       %s\n' "$open_hint"
  printf '       %s\n\n' "$(next_step work "$(msg install_work_hint)" plain)"
  printf '%s\n' "$(msg install_navigation)"
  teach_warp
  show_choices
}

next_step() {
  local label="$1" width
  width=$(printf '%s' "$label" | LC_ALL=C tr -d '\200-\277' | wc -c)
  if [ "${3:-}" = plain ]; then
    printf '%s%*s %s%s%s' "$label" $((30 - width)) "" "$dim" "$2" "$reset"
  else
    printf '%s%s%s%*s %s%s%s' "$bold" "$label" "$reset" $((30 - width)) "" "$dim" "$2" "$reset"
  fi
}

refuse_unsupported_system() {
  case "$(uname -s)" in
    Darwin) ;;
    Linux)
      if [ -f "$MANIFEST" ]; then
        LINUX_LEGACY=1
      else
        msgln install_macos_only
        exit 1
      fi ;;
    *)
      msgln install_macos_only
      exit 1 ;;
  esac
}

main() {
  refuse_unsupported_system
  parse_options "$@"
  setup_output
  choose_language
  [ "$DRY" = 1 ] || { settings_ensure_header; migrate_legacy_config; }
  save_choice LANGUAGE "$LANGUAGE"
  choose_theme
  detect_system
  show_header
  [ "$LINUX_LEGACY" = 0 ] || warn "$(msg install_linux_unsupported)"
  install_dependencies
  install_scripts
  install_config
  configure_tmux_and_terminal
  configure_shell
  configure_agent
  configure_integrations
  [ "$DRY" = 1 ] || settings_ensure_template
  finish
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
