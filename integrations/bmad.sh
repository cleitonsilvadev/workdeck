#!/usr/bin/env bash

descrever() {
  echo "BMAD Method"
  echo "Framework de agentes (PM, arquiteto, dev, QA) que guia a IA do PRD ao código."
  echo "Projeto de terceiros: https://github.com/bmad-code-org/BMAD-METHOD"
}

verificar() {
  return 1
}

instalar() {
  cat <<'FIM'
O BMAD é instalado por projeto, não na máquina. Precisa do Node.js.

  1. Vá para a pasta do projeto (Shift+→ no work).
  2. Rode: npx bmad-method install
  3. Escolha os módulos e a sua IA quando ele perguntar.

Ele cria a pasta do BMAD no projeto e os comandos dentro do seu agente. O
workdeck não depende dele: o ai e o work review funcionam com ou sem.
FIM
}
