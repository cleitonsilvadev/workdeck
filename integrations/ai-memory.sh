#!/usr/bin/env bash
# ai-memory: long-term memory for AI agents, via MCP.

describe() {
  echo "ai-memory"
  echo "Memória entre sessões para o seu agente: decisões, convenções e contexto."
  echo "Projeto de terceiros, instalado pelo gerenciador do seu agente."
}

is_installed() {
  command -v ai-memory >/dev/null
}

setup() {
  cat <<'EOF'
O ai-memory não é distribuído pelo workdeck, e a instalação depende de qual
agente você usa — cada um registra servidores MCP de um jeito.

  1. Instale o servidor seguindo a documentação do projeto.
  2. Registre-o no seu agente como servidor MCP.

No Claude Code, por exemplo:
  claude mcp add ai-memory -- <comando do servidor>

Em outros agentes, procure por "MCP" na documentação.
EOF
}

usage() {
  cat <<'EOF'
O ai-memory guarda o que acontece nas sessões (decisões, convenções, armadilhas)
e devolve esse contexto quando você abre a IA de novo no mesmo projeto.

  1. Confira se ele aparece no seu agente. No Claude Code: claude mcp list
  2. Abra a IA num projeto e pergunte o que ela lembra dele.

Memória não substitui o CLAUDE.md. As regras que a IA deve sempre seguir e os
caminhos do projeto (BMAD, PRDs, padrões) ficam no CLAUDE.md ou no AGENTS.md;
a memória completa com o histórico. Se a IA lembrar de algo que virou regra,
peça para ela passar para o CLAUDE.md.

O workdeck não precisa dele para nada: é só uma peça que costuma aparecer em
fluxo de trabalho com agentes, e deixamos o atalho aqui.
EOF
}
