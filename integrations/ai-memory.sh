#!/usr/bin/env bash
# ai-memory — memória de longo prazo para agentes de IA, via MCP.

descrever() {
  echo "ai-memory"
  echo "Memória entre sessões para o seu agente: decisões, convenções e contexto."
  echo "Projeto de terceiros, instalado pelo gerenciador do seu agente."
}

verificar() {
  command -v ai-memory >/dev/null
}

instalar() {
  cat <<'FIM'
O ai-memory não é distribuído pelo workdeck, e a instalação depende de qual
agente você usa — cada um registra servidores MCP de um jeito.

  1. Instale o servidor seguindo a documentação do projeto.
  2. Registre-o no seu agente como servidor MCP.

No Claude Code, por exemplo:
  claude mcp add ai-memory -- <comando do servidor>

Em outros agentes, procure por "MCP" na documentação.

O workdeck não precisa dele para nada: é só uma peça que costuma aparecer em
fluxo de trabalho com agentes, e deixamos o atalho aqui.
FIM
}
