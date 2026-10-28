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
Precisa do Node.js 20.12+ e do Python 3.10+.

  1. Vá para a pasta do projeto (Shift+→ no work).
  2. Rode: npx bmad-method install
  3. Escolha os módulos e a sua IA quando ele perguntar.

O instalador do BMAD deixa os comandos dele prontos dentro da sua IA.
FIM
}

usar() {
  cat <<'FIM'
Abra a sua IA na pasta do projeto e:

  - bmad-help   diz o que fazer a seguir, a qualquer momento;
  - bmad-build  começa uma mudança, a partir do que você descrever.

Para o work review usar o review do BMAD, diga isso no CLAUDE.md (ou no
AGENTS.md) do projeto. Documentação: https://github.com/bmad-code-org/BMAD-METHOD
FIM
}
