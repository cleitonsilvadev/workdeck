WORKDECK_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck"
WORKDECK_CODIGO="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck"
WORKDECK_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/workdeck"
WORKDECK_BIN="$HOME/.local/bin"
AGENTES_CONHECIDOS="claude codex copilot aider gemini opencode cursor-agent crush goose q"

curto() {
  case "$1" in
    "$HOME"/*) printf '%s/%s\n' '~' "${1#"$HOME"/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

iguais() { [ "$(cksum < "$1")" = "$(cksum < "$2")" ]; }

tem_bloco() { grep -q '^# >>> workdeck >>>$' "$1" 2>/dev/null; }

sem_bloco() { awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$1"; }
