# Mudanças

O `work update` mostra o trecho da versão nova antes de perguntar se quer
atualizar. Cada versão é uma tag `vX.Y.Z`.

## v1.0.4

- README novo, mais curto e direto: o que é, instalação, primeiros passos e recursos. Os detalhes foram para guias em `docs/` (instalação, projetos, atalhos, review, painéis, temas, integrações e customização).

## v1.0.3

- A instalação não conta mais o kitty que está na pasta de outro usuário do Mac, como o de uma conta apagada, e instala o kitty na sua.

## v1.0.2

- Volta o `work uninstall`, que desinstala tudo o que o workdeck instalou: mostra o que vai sair, pergunta antes e aceita `--dry-run`. O kitty e a fonte que a instalação trouxe saem junto.
- Sem o manifesto da instalação, desinstalar tudo também apaga o código em `~/.local/share/workdeck`.

## v1.0.1

- O zsh do workdeck vem com "sim" como resposta padrão: Enter instala o oh-my-zsh e o zinit com os plugins.
- README revisado: flags que faltavam, atalhos com Alt, o que vai para onde e como apontar o CLAUDE.md para o BMAD, os PRDs e o ai-memory.

## v1.0.0

- `work` abre uma sessão do tmux com uma janela por projeto e o painel do workdeck; a sessão sobrevive a fechar o terminal.
- Cinco comandos: `work`, `work add`, `work review`, `work update` e `work kill`. O menu (Ctrl+b h) lista os projetos e as ações, e mostra os atalhos do dia a dia.
- `work review` pede à IA aberta na janela um self code review antes do commit, usando o agente de review e os PRDs que o CLAUDE.md ou o AGENTS.md apontam.
- Instalação numa linha, com o kitty (tema, fonte JetBrains Mono e atalhos `cmd` no Mac) e o zsh do workdeck: oh-my-zsh com robbyrussell e zinit com três plugins.
- Integrações opcionais (BMAD, Spec Kit, ai-memory), com como instalar e como deixar a IA usando cada uma.
- `work update` avisa quando há versão nova e reaplica a instalação, sem perder o tema e as escolhas feitas.
