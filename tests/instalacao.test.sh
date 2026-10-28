teste_instala_do_zero() {
  instalar || falhar "a instalação saiu com erro"
  afirmar "o work está no PATH" test -x "$HOME/.local/bin/work"
  afirmar "a cópia do código existe" test -f "$CODIGO/lib/comum.sh"
  afirmar "o painel 00-workdeck foi instalado" test -x "$CONFIG/panels/00-workdeck"
  afirmar "o painel 20-projetos foi instalado" test -x "$CONFIG/panels/20-projetos"
  afirmar "o manifesto foi gravado" test -f "$CONFIG/.install-manifest"
  afirmar_igual "$(contar_blocos "$HOME/.tmux.conf")" 1 "blocos no tmux.conf"
  afirmar_igual "$(contar_blocos "$(arquivo_do_shell)")" 1 "blocos no arquivo do shell"
}

teste_reinstalar_nao_duplica() {
  instalar >/dev/null || falhar "primeira instalação"
  instalar >/dev/null || falhar "segunda instalação"
  afirmar_igual "$(contar_blocos "$HOME/.tmux.conf")" 1 "blocos no tmux.conf"
  afirmar_igual "$(contar_blocos "$(arquivo_do_shell)")" 1 "blocos no arquivo do shell"
  afirmar_igual "$(grep -c '^bloco|' "$CONFIG/.install-manifest")" 2 "blocos no manifesto"
}

teste_preserva_o_que_ja_existia() {
  printf 'set -g history-limit 5000\n' > "$HOME/.tmux.conf"
  instalar >/dev/null || falhar "a instalação saiu com erro"
  afirmar "a linha do usuário continua" grep -qx 'set -g history-limit 5000' "$HOME/.tmux.conf"
  afirmar "a cópia do original foi guardada" sh -c "ls '$CONFIG/.backups/' | grep -q tmux.conf"
}

teste_nao_substitui_work_de_outro() {
  mkdir -p "$HOME/.local/bin"
  printf '#!/bin/sh\necho meu\n' > "$HOME/.local/bin/work"
  saida="$(instalar 2>&1)" || falhar "a instalação saiu com erro"
  afirmar_igual "$(cat "$HOME/.local/bin/work")" "$(printf '#!/bin/sh\necho meu')" "o work do usuário"
  afirmar_contem "$saida" "já existe um work que não é do workdeck"
}

teste_dry_run_nao_escreve() {
  instalar --dry-run >/dev/null || falhar "o dry-run saiu com erro"
  afirmar "não criou o tmux.conf" test ! -e "$HOME/.tmux.conf"
  afirmar "não gravou o tema" test ! -e "$CONFIG/tema"
  afirmar "não instalou o work" test ! -e "$HOME/.local/bin/work"
}
