falhar() {
  echo "FALHOU: $*"
  exit 1
}

afirmar() {
  local descricao="$1"; shift
  "$@" || falhar "$descricao"
}

afirmar_igual() {
  [ "$1" = "$2" ] || falhar "${3:-valores diferentes}: esperado [$2], veio [$1]"
}

afirmar_contem() {
  case "$1" in *"$2"*) ;; *) falhar "${3:-texto não encontrado}: [$2] não está em [$1]" ;; esac
}

afirmar_nao_contem() {
  case "$1" in *"$2"*) falhar "${3:-texto inesperado}: [$2] está em [$1]" ;; esac
}

esperar() {
  local n=0
  while [ "$n" -lt 50 ]; do
    "$@" >/dev/null 2>&1 && return 0
    sleep 0.2
    n=$((n + 1))
  done
  return 1
}

contar_blocos() {
  grep -c '^# >>> workdeck >>>$' "$1" 2>/dev/null || true
}

preparar_repo() {
  TESTE_TMP="$(mktemp -d "${TMPDIR:-/tmp}/workdeck-testes.XXXXXX")"
  REPO="$TESTE_TMP/repo"
  mkdir -p "$REPO"
  if git -C "$RAIZ" rev-parse >/dev/null 2>&1; then
    git -C "$RAIZ" ls-files -co --exclude-standard | while IFS= read -r f; do
      [ -f "$RAIZ/$f" ] || continue
      mkdir -p "$REPO/$(dirname "$f")"
      cp -p "$RAIZ/$f" "$REPO/$f"
    done
  else
    (cd "$RAIZ" && tar cf - --exclude .git .) | (cd "$REPO" && tar xf -)
  fi
  git -C "$REPO" init -q
  git -C "$REPO" add -A
  git -C "$REPO" -c user.name=teste -c user.email=teste@exemplo.com commit -qm teste
  REAL_TMUX="$(command -v tmux)"
  export TESTE_TMP REPO REAL_TMUX
}

preparar_home() {
  local nome="$1" base="$TESTE_TMP/$1" pasta_git
  mkdir -p "$base/home/.config/workdeck" "$base/bin"
  SOCKET="wdt-$nome-$$"
  SOCKET_HOST="wdh-$nome-$$"
  cat > "$base/bin/tmux" <<FAKE
#!/bin/sh
if [ "\$1" = display-menu ] && [ -n "\${WD_MENU_LOG:-}" ]; then printf '%s\n' "\$@" > "\$WD_MENU_LOG"; exit 0; fi
exec "$REAL_TMUX" -L "$SOCKET" "\$@"
FAKE
  chmod +x "$base/bin/tmux"
  echo nao > "$base/home/.config/workdeck/zsh"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME TMUX KITTY_WINDOW_ID WORKDECK_SESSION
  export HOME="$base/home"
  pasta_git="$(dirname "$(command -v git)")"
  export PATH="$base/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$pasta_git"
  export SHELL=/bin/bash TERM=xterm-256color NO_COLOR=1
  export SOCKET SOCKET_HOST
  export CONFIG="$HOME/.config/workdeck"
  export CODIGO="$HOME/.local/share/workdeck"
  export BASE="$base"
}

limpar_tmux() {
  "$REAL_TMUX" -L "$SOCKET" kill-server >/dev/null 2>&1 || true
  "$REAL_TMUX" -L "$SOCKET_HOST" kill-server >/dev/null 2>&1 || true
}

instalar() {
  bash "$REPO/install.sh" --yes --no-deps --no-reload "$@" </dev/null
}

arquivo_do_shell() {
  if [ "$(uname -s)" = Darwin ]; then echo "$HOME/.bash_profile"; else echo "$HOME/.bashrc"; fi
}

abrir_work_num_terminal() {
  "$REAL_TMUX" -L "$SOCKET_HOST" -f /dev/null new-session -d -s host -x 120 -y 40 \
    "env -i HOME='$HOME' PATH='$PATH' SHELL=/bin/bash TERM=xterm-256color bash --norc --noprofile"
  esperar "$REAL_TMUX" -L "$SOCKET_HOST" has-session -t host || falhar "o terminal de teste não abriu"
  "$REAL_TMUX" -L "$SOCKET_HOST" send-keys -t host "$*" Enter
}
