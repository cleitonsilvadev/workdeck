# >>> workdeck >>>
# Serve para bash e zsh.
export PATH="$HOME/.local/bin:$PATH"

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
if [ -n "${ZSH_VERSION:-}" ] && grep -qx sim "${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/zsh" 2>/dev/null; then
  if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME="${WORKDECK_ZSH_THEME:-robbyrussell}"
    plugins=(git)
    . "$ZSH/oh-my-zsh.sh"
  fi
  if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh" ]; then
    . "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh"
    zinit light zdharma-continuum/fast-syntax-highlighting
    zinit light zsh-users/zsh-autosuggestions
    zinit light zsh-users/zsh-completions
  fi
fi

_work_janelas() {
  local f="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/projects.conf"
  [ -f "$f" ] && grep -v '^[[:space:]]*#' "$f" | cut -d'|' -f1
}
if [ -n "${ZSH_VERSION:-}" ]; then
  _work() {
    if (( CURRENT == 2 )); then
      compadd add review update escolher kill help doctor agent painel kitty $(_work_janelas)
    elif [[ ${words[2]} == add ]]; then
      _directories
    fi
  }
  (( $+functions[compdef] )) && compdef _work work
elif [ -n "${BASH_VERSION:-}" ]; then
  _work() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" = 1 ]; then
      COMPREPLY=($(compgen -W "add review update escolher kill help doctor agent painel kitty $(_work_janelas)" -- "$cur"))
    elif [ "${COMP_WORDS[1]}" = add ]; then
      COMPREPLY=($(compgen -d -- "$cur"))
    fi
  }
  complete -o filenames -F _work work
fi
# <<< workdeck <<<
