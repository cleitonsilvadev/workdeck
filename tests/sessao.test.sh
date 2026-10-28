sessao_tmux() { tmux "$@"; }

teste_primeiro_work_abre_o_painel_com_terminal() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  abrir_work_num_terminal work
  esperar sessao_tmux has-session -t work || falhar "a sessão work não abriu"
  esperar sh -c "tmux list-panes -t work:painel -F '#{@papel}' | grep -qx TERMINAL" || falhar "o terminal embaixo do painel não apareceu"
  sleep 1
  papeis="$(tmux list-panes -t work:painel -F '#{@papel}:#{pane_dead}' | tr '\n' ' ')"
  afirmar_igual "$papeis" "PAINEL:0 TERMINAL:0 " "painéis da janela do painel"
}

teste_work_add_cria_a_janela_do_projeto() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null || falhar "o work add saiu com erro"
  afirmar "o projeto entrou no projects.conf" grep -q "^api|" "$CONFIG/projects.conf"
  abrir_work_num_terminal work
  esperar sh -c "tmux list-windows -t work -F '#W' | grep -qx api" || falhar "a janela do projeto não abriu"
  afirmar_igual "$(tmux list-windows -t work -F '#W' | tr '\n' ' ')" "painel api " "janelas"
}

teste_menu_diz_como_fechar() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  abrir_work_num_terminal work
  esperar sh -c "tmux list-clients -t work | grep -q ." || falhar "nenhum terminal ligado à sessão"
  cliente="$(tmux list-clients -t work -F '#{client_name}' | head -1)"
  WD_MENU_LOG="$BASE/menu" work _menu "$cliente" "$(tmux display -p -t work:painel '#{pane_id}')"
  afirmar_contem "$(cat "$BASE/menu")" "-q ou Esc fecha o menu"
  afirmar_contem "$(cat "$BASE/menu")" "painel"
}

teste_work_sem_o_codigo_explica_o_que_fazer() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  rm -rf "$CODIGO"
  if saida="$(work 2>&1)"; then falhar "o work deveria falhar sem o código"; fi
  afirmar_contem "$saida" "o código do workdeck não está em"
  afirmar_contem "$saida" "instalar.sh"
}
