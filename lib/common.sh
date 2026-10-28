WORKDECK_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck"
WORKDECK_CODE="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck"
WORKDECK_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/workdeck"
WORKDECK_BIN="$HOME/.local/bin"
KNOWN_AGENTS="claude codex copilot aider gemini opencode cursor-agent crush goose q"

short_path() {
  case "$1" in
    "$HOME"/*) printf '%s/%s\n' '~' "${1#"$HOME"/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

same_file() { [ "$(cksum < "$1")" = "$(cksum < "$2")" ]; }

has_block() { grep -q '^# >>> workdeck >>>$' "$1" 2>/dev/null; }

without_block() { awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$1"; }

migrate_legacy_config() {
  local dir="$WORKDECK_CONFIG" value
  [ -d "$dir" ] || return 0
  if [ -f "$dir/tema" ]; then
    [ -f "$dir/theme" ] || mv "$dir/tema" "$dir/theme"
    rm -f "$dir/tema"
  fi
  if [ -f "$dir/integracoes" ]; then
    if [ ! -f "$dir/integrations" ]; then
      value="$(cat "$dir/integracoes")"
      [ "$value" = nenhuma ] && value=none
      printf '%s\n' "$value" > "$dir/integrations"
    fi
    rm -f "$dir/integracoes"
  fi
  if [ -f "$dir/zsh" ]; then
    case "$(cat "$dir/zsh")" in
      sim) echo yes > "$dir/zsh" ;;
      nao) echo no > "$dir/zsh" ;;
    esac
  fi
  if [ -f "$dir/atualizacao.conf" ]; then
    if [ ! -f "$dir/update.conf" ]; then
      sed 's/^AVISO=/NOTIFY=/' "$dir/atualizacao.conf" > "$dir/update.conf"
    fi
    rm -f "$dir/atualizacao.conf"
  fi
  if [ -f "$dir/.install-manifest" ] && grep -qE '^(bloco|codigo|fonte)\||\|:criado$' "$dir/.install-manifest"; then
    sed -e 's/^bloco|/block|/' -e 's/^codigo|/code|/' -e 's/^fonte|/font|/' -e 's/|:criado$/|:created/' \
      "$dir/.install-manifest" > "$dir/.install-manifest.tmp" \
      && mv "$dir/.install-manifest.tmp" "$dir/.install-manifest"
  fi
  rm -f "$WORKDECK_CACHE/atualizacao" "$WORKDECK_CACHE/pedido-de-review.md"
  return 0
}
