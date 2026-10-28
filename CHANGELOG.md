# Mudanças

O `work update` mostra o trecho da versão nova antes de perguntar se quer
atualizar. Cada versão é uma tag `vX.Y.Z`.

## v1.0.9

- Volta o `work kill`, que fecha a sessão inteira.

## v1.0.8

- O kitty é pré-requisito oficial: a instalação sempre instala o kitty, sem perguntar. Em outro terminal o `work` abre, mas o visual e os atalhos `cmd` ficam fora do suporte.

## v1.0.7

- O menu (Ctrl+b h) lista os seus projetos, cada um com o número da janela como tecla, e ganha "Atualizar o workdeck". Sai o "Ir para um projeto".
- Sai o Ctrl+b ? e a lista de atalhos: o menu é a única ajuda.

## v1.0.6

- O painel mostra só o workdeck e os projetos; os comandos e os atalhos ficam no Ctrl+b ?, e uma linha lembra onde estão.

## v1.0.5

- A instalação pergunta antes de instalar o kitty (sim é o padrão) e guarda a resposta. Quem já tem o kitty não vê a pergunta.
- O README deixa claro que o workdeck funciona em qualquer terminal e que o kitty é o que deixa ele completo.

## v1.0.4

- Só o `work` fica no PATH. O painel, a lista de atalhos e o pedido de review passam a ser peças internas, chamadas por ele; a atualização tira `work-panel`, `workdeck-agent` e `workdeck-help` de `~/.local/bin`.

## v1.0.3

- Sai o `git review`, e com ele o `git-delta` da lista de dependências; a atualização apaga o script e a configuração dele. O `git-delta` que já estiver instalado fica.

## v1.0.2

- Só quatro comandos: `work`, `work add`, `work review` e `work update`. Saem `escolher`, `painel`, `kill`, `doctor`, `help`, `versao`, `install`, `uninstall`, `agent` e `kitty`, e a atualização apaga o `workdeck-doctor` antigo.
- O `work review` usa a IA que está aberta na janela; o `agent.conf` só vale quando não há nenhuma.
- Sai o aviso diário fora do kitty; fica só a linha no painel. Para desinstalar: `bash ~/.local/share/workdeck/uninstall.sh`.

## v1.0.1

- `work review` abre num painel embaixo do chat e reaproveita: o mesmo painel enquanto ele estiver aberto, e uma sessão do claude por branch, em vez de um chat novo a cada review.
- O pedido de review manda a IA usar o agente de review e os PRDs que as instruções dela apontam (CLAUDE.md, AGENTS.md, skills); `work review --editar` acrescenta o que você quiser.
- Sai o `ai`: abra a sua IA como sempre. Os comandos principais ficam `work`, `work add`, `work review` e `work update`.

## v1.0.0

- `work` abre uma sessão do tmux com uma janela por projeto e o painel com o que fazer no dia; a sessão sobrevive a fechar o terminal.
- `work add <pasta>` acrescenta um projeto; fechar a janela tira ele do work.
- `ai` abre a sua IA ao lado, na pasta do projeto; funciona com claude, codex, gemini, aider e outros.
- `work review` pede à IA um self code review antes do commit, na conversa que já está aberta; se o projeto tem um agente de review do BMAD ou de outro framework, usa ele.
- Instalação numa linha, com o kitty (tema, fonte JetBrains Mono e atalhos `cmd` no Mac), o zsh com oh-my-zsh e zinit, a escolha do agente e as integrações (BMAD, Spec Kit, ai-memory).
- `work update` avisa quando há versão nova e reaplica a instalação; `work doctor` diz o que funciona no seu ambiente.
