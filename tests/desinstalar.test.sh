teste_desinstalar_tudo() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  bash "$CODIGO/uninstall.sh" --all >/dev/null || falhar "a desinstalação saiu com erro"
  afirmar "o work saiu" test ! -e "$HOME/.local/bin/work"
  afirmar "o código saiu" test ! -e "$CODIGO"
  afirmar "a config saiu" test ! -e "$CONFIG"
  afirmar "o tmux.conf criado pela instalação saiu" test ! -e "$HOME/.tmux.conf"
}

teste_restore_devolve_o_original() {
  printf 'set -g history-limit 5000\n' > "$HOME/.tmux.conf"
  antes="$(cksum < "$HOME/.tmux.conf")"
  instalar >/dev/null || falhar "a instalação saiu com erro"
  bash "$CODIGO/uninstall.sh" --restore >/dev/null || falhar "a desinstalação saiu com erro"
  afirmar_igual "$(cksum < "$HOME/.tmux.conf")" "$antes" "tmux.conf depois do --restore"
}

teste_desinstalar_tira_so_o_bloco() {
  printf 'set -g history-limit 5000\n' > "$HOME/.tmux.conf"
  instalar >/dev/null || falhar "a instalação saiu com erro"
  bash "$CODIGO/uninstall.sh" >/dev/null || falhar "a desinstalação saiu com erro"
  afirmar_igual "$(contar_blocos "$HOME/.tmux.conf")" 0 "blocos no tmux.conf"
  afirmar "a linha do usuário continua" grep -qx 'set -g history-limit 5000' "$HOME/.tmux.conf"
  afirmar "a config continua" test -d "$CONFIG"
}
