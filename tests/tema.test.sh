tema_aplicado() {
  local linha
  while IFS= read -r linha; do
    [ -z "$linha" ] && continue
    grep -qxF -- "$linha" "$HOME/.tmux.conf" || return 1
  done < "$REPO/themes/$1.tmux"
}

teste_tema_padrao() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  afirmar_igual "$(cat "$CONFIG/tema")" catppuccin-mocha "tema salvo"
  afirmar "as cores do catppuccin estão no tmux.conf" tema_aplicado catppuccin-mocha
}

teste_tema_escolhido_fica_salvo() {
  instalar --theme nord >/dev/null || falhar "instalação com --theme nord"
  instalar >/dev/null || falhar "reinstalação sem --theme"
  afirmar_igual "$(cat "$CONFIG/tema")" nord "tema depois de reinstalar"
  afirmar "as cores do nord continuam no tmux.conf" tema_aplicado nord
}

teste_tema_salvo_invalido_volta_ao_padrao() {
  echo nao-existe > "$CONFIG/tema"
  instalar >/dev/null || falhar "a instalação saiu com erro"
  afirmar_igual "$(cat "$CONFIG/tema")" catppuccin-mocha "tema salvo"
}

teste_tema_inexistente_falha() {
  if saida="$(instalar --theme foo 2>&1)"; then falhar "a instalação deveria falhar"; fi
  afirmar_contem "$saida" "tema 'foo' não existe"
  afirmar_contem "$saida" "nord"
}
