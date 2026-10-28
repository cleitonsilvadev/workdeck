painel() {
  "$CODIGO/bin/work-panel" --once | sed 's/\x1b\[[0-9;]*m//g'
}

teste_painel_mostra_blocos_com_titulo() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  printf '#!/usr/bin/env bash\necho tudo certo\n' > "$CONFIG/panels/30-commits-de-hoje"
  chmod +x "$CONFIG/panels/30-commits-de-hoje"
  saida="$(painel)"
  afirmar_contem "$saida" "Commits de hoje"
  afirmar_contem "$saida" "  tudo certo"
  afirmar_contem "$saida" "Projetos"
}

teste_painel_desligado_some_e_o_update_respeita() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  chmod -x "$CONFIG/panels/20-projetos"
  afirmar_nao_contem "$(painel)" "Projetos" "o painel desligado"
  saida="$(instalar 2>&1)" || falhar "a reinstalação saiu com erro"
  afirmar_contem "$saida" "painel 20-projetos desligado por você"
  afirmar "o painel continua desligado" test ! -x "$CONFIG/panels/20-projetos"
}

teste_painel_editado_nao_e_sobrescrito() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  echo 'echo minha versão' >> "$CONFIG/panels/20-projetos"
  saida="$(instalar 2>&1)" || falhar "a reinstalação saiu com erro"
  afirmar_contem "$saida" "painel 20-projetos foi editado por você"
  afirmar "a edição continua" grep -q 'minha versão' "$CONFIG/panels/20-projetos"
}

teste_dica_de_painel_proprio() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  afirmar_contem "$(painel)" "Para pôr o seu no painel"
  printf '#!/usr/bin/env bash\necho oi\n' > "$CONFIG/panels/30-meu"
  chmod +x "$CONFIG/panels/30-meu"
  afirmar_nao_contem "$(painel)" "Para pôr o seu no painel"
}
