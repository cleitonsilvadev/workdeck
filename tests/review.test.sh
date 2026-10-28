projeto_com_mudanca() {
  mkdir -p "$HOME/api"
  git -C "$HOME/api" init -q
  echo 'export const a = 1' > "$HOME/api/index.ts"
  git -C "$HOME/api" add -A
  git -C "$HOME/api" -c user.name=t -c user.email=t@t commit -qm inicio
  echo 'export const a = 2' > "$HOME/api/index.ts"
}

teste_review_pede_saida_com_bolinhas() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  projeto_com_mudanca
  (cd "$HOME/api" && work review >/dev/null 2>&1)
  pedido="$HOME/.cache/workdeck/pedido-de-review.md"
  afirmar "o pedido foi gravado" test -s "$pedido"
  texto="$(cat "$pedido")"
  afirmar_contem "$texto" "🔴 arquivo:linha"
  afirmar_contem "$texto" "🟠 arquivo:linha"
  afirmar_contem "$texto" "🟢 pode commitar"
  afirmar_contem "$texto" "🔴 corrija os vermelhos antes do commit"
  afirmar_contem "$texto" "sem explicação longa"
}

teste_review_inclui_instrucoes_do_projeto() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  projeto_com_mudanca
  mkdir -p "$HOME/api/.workdeck"
  echo 'Use a branch develop como base.' > "$HOME/api/.workdeck/review.md"
  (cd "$HOME/api" && work review >/dev/null 2>&1)
  afirmar_contem "$(cat "$HOME/.cache/workdeck/pedido-de-review.md")" "Use a branch develop como base."
}

teste_review_sem_mudanca_avisa() {
  instalar >/dev/null || falhar "a instalação saiu com erro"
  projeto_com_mudanca
  git -C "$HOME/api" checkout -q -- index.ts
  afirmar_contem "$(cd "$HOME/api" && work review 2>&1)" "nada mudou desde o último commit"
}
