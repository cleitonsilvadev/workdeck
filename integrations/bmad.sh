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
O BMAD pode ficar dentro de cada projeto ou numa pasta só, fora deles.
A instalação precisa do Node.js.

  Dentro do projeto
    1. Vá para a pasta do projeto (Shift+→ no work).
    2. Rode: npx bmad-method install
    3. Escolha os módulos e a sua IA quando ele perguntar.
    Ele cria a pasta do BMAD no projeto e os comandos dentro do seu agente.

  Fora do projeto (um repositório do time, uma pasta sua)
    Instale ou clone o BMAD uma vez, na pasta onde ele vai ficar, e aponte
    para ela a partir de cada projeto. Todos os projetos usam a mesma cópia,
    e o repositório do projeto não carrega o BMAD.
FIM
}

usar() {
  cat <<'FIM'
Nos dois casos, a IA só usa o que as instruções dela apontam. Deixe o
CLAUDE.md (ou o AGENTS.md) do projeto dizendo:

  - onde fica o BMAD, com o caminho completo se ele estiver fora do projeto;
  - onde ficam os PRDs, as stories e os padrões do time;
  - qual agente usar para revisar o código (o work review procura por ele).

O que vale para todos os projetos vai no ~/.claude/CLAUDE.md; o que é de um
projeto só fica no CLAUDE.md dele. Instruções curtas e com caminhos certos
funcionam melhor que um texto longo.
FIM
}
