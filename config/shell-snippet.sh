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
_wd_zsh="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck-zsh"
if [ -n "${ZSH_VERSION:-}" ] && [ -d "$_wd_zsh" ] && grep -qx sim "${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/zsh" 2>/dev/null; then
  fpath=("$_wd_zsh/zsh-completions/src" $fpath)
  autoload -Uz compinit && compinit -i
  [ -f "$_wd_zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && . "$_wd_zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "$_wd_zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] && . "$_wd_zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi
unset _wd_zsh

_work_janelas() {
  local f="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/projects.conf"
  [ -f "$f" ] && grep -v '^[[:space:]]*#' "$f" | cut -d'|' -f1
}
if [ -n "${ZSH_VERSION:-}" ]; then
  _work() {
    if (( CURRENT == 2 )); then
      compadd add escolher kill help doctor agent review painel $(_work_janelas)
    elif [[ ${words[2]} == add ]]; then
      _directories
    fi
  }
  (( $+functions[compdef] )) && compdef _work work
elif [ -n "${BASH_VERSION:-}" ]; then
  _work() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" = 1 ]; then
      COMPREPLY=($(compgen -W "add escolher kill help doctor agent review painel $(_work_janelas)" -- "$cur"))
    elif [ "${COMP_WORDS[1]}" = add ]; then
      COMPREPLY=($(compgen -d -- "$cur"))
    fi
  }
  complete -o filenames -F _work work
fi
# <<< workdeck <<<
