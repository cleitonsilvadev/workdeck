# >>> workdeck >>>
# Serve para bash e zsh.
export PATH="$HOME/.local/bin:$PATH"

# ai → abre o agente de IA num pane ao lado, na pasta em que você está.
# Configure qual com: workdeck-agent --set <comando>
ai() { workdeck-agent "$@"; }

# painel → abre (ou redesenha) o painel numa janela da sessão e vai até ela.
painel() {
  local sessao="${WORKDECK_SESSION:-work}"
  if ! tmux has-session -t "$sessao" 2>/dev/null; then
    echo "sessão $sessao não está aberta; rode: work"
    return 1
  fi
  if tmux list-windows -t "$sessao" -F '#W' | grep -qx painel; then
    tmux respawn-pane -k -t "$sessao:painel" -c "$HOME" work-panel
  else
    tmux new-window -d -t "$sessao:" -n painel -c "$HOME" work-panel
  fi
  if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$sessao" \; select-window -t "$sessao:painel"
  else
    tmux select-window -t "$sessao:painel" && tmux attach -t "$sessao"
  fi
}
# <<< workdeck <<<
