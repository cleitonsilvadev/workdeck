# >>> workdeck >>>
export PATH="$HOME/.local/bin:$PATH"

# tclock run → (re)abre o painel na janela "painel" da sessão e vai até ela.
# Qualquer outro uso chama o tclock normal; para fechar, q dentro dele.
# Só faz sentido se você tiver o tclock instalado (veja o README).
tclock() {
  local sessao="${WORKDECK_SESSION:-work}"
  if [ "$1" != "run" ]; then
    command tclock "$@"
    return
  fi
  if ! tmux has-session -t "$sessao" 2>/dev/null; then
    echo "sessão $sessao não está aberta; rode: work"
    return 1
  fi
  if tmux list-windows -t "$sessao" -F '#W' | grep -qx painel; then
    tmux respawn-pane -k -t "$sessao:painel" -c "$HOME" tclock
  else
    tmux new-window -d -t "$sessao" -n painel -c "$HOME" tclock
  fi
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$sessao" \; select-window -t "$sessao:painel"
  else
    tmux select-window -t "$sessao:painel" && tmux attach -t "$sessao"
  fi
}
# <<< workdeck <<<
