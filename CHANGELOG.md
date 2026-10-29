# Mudanças · Changes

O `work update` mostra o trecho da versão nova no seu idioma antes de perguntar
se quer atualizar. Cada versão é uma tag `vX.Y.Z`.

`work update` shows the section of the new version in your language before
asking whether to update. Each version is a `vX.Y.Z` tag.

## v1.6.0

### Português

- O workdeck fala inglês ou português. Na primeira instalação, a primeira pergunta é o idioma, com o do sistema como padrão; `--lang en` ou `--lang pt-BR` responde sem perguntar, e a escolha fica como `LANGUAGE` no `settings.conf`. Quem já usa o workdeck responde uma vez, no próximo `work update`, com o português como padrão: Enter deixa tudo como estava.
- Seguem o idioma: o instalador, o comando `work`, o menu, o painel, a janela do painel (`painel` ou `panel`), os avisos da barra, o pedido de review que vai para o agente e este registro de mudanças, que agora traz cada versão nos dois idiomas. As integrações, o desinstalador e o `get.sh` ficam para a próxima versão.
- `work update --off` e `work update --on` ligam e desligam o aviso de versão nova; `--desligar` e `--ligar` continuam funcionando. `work --help` lista os comandos.
- A janela de cada projeto abre com o agente e um shell lado a lado, em todos os projetos, sempre que o `work` abre a sessão. Antes, ela abria com um painel só, ou com três no `PROJECT_LAYOUT="agent-server-shell"`, que agora também abre dois. Para voltar a um painel só, use `PROJECT_LAYOUT="none"` no `settings.conf`. O `Ctrl+b Enter` continua igual.
- Novo `REVIEW_AGENT_CMD` no `settings.conf`: escolhe o agente ou o modelo que faz o `work review`, como `claude --model opus`. O review roda no painel separado, embaixo do chat, e um modelo diferente do que escreveu o código não repete os mesmos pontos cegos.
- Rode `Ctrl+b r` e depois `work kill` e `work`, para a barra usar as frases novas e as janelas abrirem com os dois painéis.

### English

- workdeck speaks English or Portuguese. On the first install, the first question is the language, with the system language as the default; `--lang en` or `--lang pt-BR` answers without asking, and the choice is saved as `LANGUAGE` in `settings.conf`. If you already use workdeck, the next `work update` asks once, with Portuguese as the default: Enter keeps everything as it was.
- These follow the language: the installer, the `work` command, the menu, the panel, the panel window (`panel` or `painel`), the status bar messages, the review request sent to the agent and this changelog, which now has each version in both languages. The integrations, the uninstaller and `get.sh` come in the next version.
- `work update --off` and `work update --on` turn the new version notice off and on; `--desligar` and `--ligar` keep working. `work --help` lists the commands.
- Each project window opens with the agent and a shell side by side, in every project, whenever `work` opens the session. Before, it opened with a single pane, or with three under `PROJECT_LAYOUT="agent-server-shell"`, which now opens two as well. To go back to a single pane, use `PROJECT_LAYOUT="none"` in `settings.conf`. `Ctrl+b Enter` stays the same.
- New `REVIEW_AGENT_CMD` in `settings.conf`: picks the agent or model that runs `work review`, such as `claude --model opus`. The review runs in the separate pane below the chat, and a model other than the one that wrote the code does not repeat the same blind spots.
- Run `Ctrl+b r`, then `work kill` and `work`, so the status bar uses the new messages and the windows open with the two panes.

## v1.5.0

### Português

- O menu (`Ctrl+b h`) ganhou o item "Ligar o aviso quando um agente termina", que liga a notificação do sistema sem editar o `settings.conf`. Com o aviso ligado, o mesmo item aparece como "Desligar o aviso quando um agente termina".
- Correção: quando a conversa mencionava "esc to interrupt", o `work review` dizia que o Claude ainda estava trabalhando, e a ✦ não aparecia quando o Claude ou o Codex terminava. Agora só conta a linha de status do agente, perto do campo de mensagem.

### English

- The menu (`Ctrl+b h`) has a new item, "Turn on the alert when an agent finishes", which turns on the system notification without editing `settings.conf`. With the alert on, the same item reads "Turn off the alert when an agent finishes".
- Fix: when the conversation mentioned "esc to interrupt", `work review` said Claude was still working, and the ✦ did not show up when Claude or Codex finished. Now only the agent status line, near the message field, counts.

## v1.4.0

### Português

- A barra do tmux marca com uma ✦ roxa a janela em que um agente terminou ou parou para perguntar algo, enquanto você está em outra. Com vários agentes na mesma janela, a estrela continua uma só. Ela some quando você abre a janela ou quando os agentes voltam a trabalhar. No Claude Code e no Codex, o fim é detectado pelo "esc to interrupt" da tela deles; nos outros agentes, por 10 segundos sem mudança na tela. Antes, a ✦ só marcava a janela com o review aberto num painel.
- Novo `NOTIFY_AGENTS="yes"` no `settings.conf`: uma notificação do sistema avisa quando um agente termina numa janela que você não está olhando ("o claude terminou em api"). Vem desligado.
- A aba do painel aparece na cor de destaque do tema, para diferenciar das janelas de projeto (vale a partir do próximo `work` depois de um `work kill`).
- Rode `Ctrl+b r` depois de atualizar, para a barra usar a estrela nova, e `work` uma vez para o acompanhamento começar.

### English

- The tmux status bar marks with a purple ✦ the window where an agent finished or stopped to ask something, while you are in another one. With several agents in the same window, there is still a single star. It goes away when you open the window or when the agents start working again. For Claude Code and Codex, the end is detected through the "esc to interrupt" on their screen; for other agents, after 10 seconds without screen changes. Before, the ✦ only marked the window with the review open in a pane.
- New `NOTIFY_AGENTS="yes"` in `settings.conf`: a system notification tells you when an agent finishes in a window you are not looking at ("claude finished in api"). Off by default.
- The panel tab shows in the theme accent color, to set it apart from the project windows (applies from the next `work` after a `work kill`).
- Run `Ctrl+b r` after updating, so the status bar uses the new star, and `work` once to start tracking the agents.

## v1.3.1

### Português

- Correção: no macOS, se o `settings.conf` tivesse um comentário salvo com acentos em Latin-1 (por um editor antigo, por exemplo), nenhuma escolha era lida e o workdeck voltava aos padrões. Agora o arquivo é lido normalmente.

### English

- Fix: on macOS, if `settings.conf` had a comment saved with Latin-1 accents (by an old editor, for example), no choice was read and workdeck fell back to the defaults. The file is now read normally.

## v1.3.0

### Português

- Novo `PROJECT_LAYOUT="agent-server-shell"` no `settings.conf`: a janela de cada projeto já abre em três painéis, com o agente à esquerda, o servidor em cima à direita e um shell livre embaixo. O comando do agente (`AGENT_CMD`) e o do servidor (`SERVER_COMMAND` no `.workdeck/project.conf` do projeto) aparecem digitados, sem rodar: você aperta Enter onde for trabalhar. Vem desligado e vale para as janelas abertas depois de ligar.
- No Windows, a instalação para logo no começo, antes de gravar qualquer coisa, e explica como instalar pelo WSL.
- Correção: com o `ACTIVE_PANE="line"`, o `Ctrl+b Enter` não fechava a grade 2×2; agora o quarto painel vai para baixo do da esquerda também com o traço ligado.

### English

- New `PROJECT_LAYOUT="agent-server-shell"` in `settings.conf`: each project window opens in three panes, with the agent on the left, the server at the top right and a free shell below it. The agent command (`AGENT_CMD`) and the server command (`SERVER_COMMAND` in the project's `.workdeck/project.conf`) are typed but not run: you press Enter where you want to work. Off by default, and applies to windows opened after you turn it on.
- On Windows, the installer stops right at the start, before writing anything, and explains how to install through WSL.
- Fix: with `ACTIVE_PANE="line"`, `Ctrl+b Enter` did not close the 2×2 grid; the fourth pane now goes below the left one with the line on as well.

## v1.2.0

### Português

- `Ctrl+b Enter` e o "Dividir a tela" do menu montam uma grade sempre igual: o segundo painel abre ao lado, o terceiro embaixo do da direita e o quarto embaixo do da esquerda, fechando quatro painéis do mesmo tamanho. A partir do quinto, a janela vira uma grade igual. Os painéis que já existem não mudam de lugar. `Ctrl+b v` e `Ctrl+b -` continuam dividindo ao lado e embaixo, como antes. Rode `Ctrl+b r` depois de atualizar para a tecla nova valer na sessão aberta.

### English

- `Ctrl+b Enter` and "Split the screen" in the menu build the same grid every time: the second pane opens to the side, the third below the right one and the fourth below the left one, making four panes of the same size. From the fifth on, the window becomes an even grid. Existing panes do not move. `Ctrl+b v` and `Ctrl+b -` still split to the side and below, as before. Run `Ctrl+b r` after updating so the new key works in the open session.

## v1.1.2

### Português

- Correção: no Claude Code, o `work review` colava o `/code-review` mas não apertava Enter. A leitura da tela não reconhecia o campo de mensagem do Claude, que usa um espaço especial depois do `❯` e mostra uma sugestão apagada quando está vazio. Agora o review começa sozinho, como prometido na v1.1.1.

### English

- Fix: in Claude Code, `work review` pasted `/code-review` but did not press Enter. The screen reading did not recognize the Claude message field, which uses a special space after `❯` and shows a dimmed suggestion when empty. The review now starts on its own, as promised in v1.1.1.

## v1.1.1

### Português

- No Claude Code, o `work review` começa o review sozinho, sem você apertar Enter no chat. Ele só manda quando o Claude terminou: se ainda estiver trabalhando, com uma pergunta aberta ou com uma mensagem sua pela metade, não manda nada e diz o que falta.
- Correção: sem nada por commitar, o `work review` dizia que não havia o que revisar mesmo com commits que ainda não subiram. Agora, com o Claude aberto, ele manda o `/code-review`, que revisa esses commits.

### English

- In Claude Code, `work review` starts the review on its own, without you pressing Enter in the chat. It only sends it when Claude is done: if it is still working, has an open question or a half-written message of yours, it sends nothing and says what is missing.
- Fix: with nothing to commit, `work review` said there was nothing to review even with commits that were not pushed yet. Now, with Claude open, it sends `/code-review`, which reviews those commits.

## v1.1.0

### Português

- O `work review` usa o review do seu próprio agente. No Claude Code, ele cola o `/code-review` no chat que você está usando; você confere e aperta Enter, e os achados chegam ali, com o agente pronto para corrigir.
- Para usar outro review, como o do BMAD ou uma skill sua, ponha `REVIEW_COMMAND="/o-comando"` em `.workdeck/review.conf` no projeto (só um comando de barra, sem argumentos) ou no `settings.conf`, para todos. `work review --pane` abre o painel separado de antes, que continua valendo com `staged` e com agentes sem review próprio.
- As suas escolhas ficam num arquivo só, `~/.config/workdeck/settings.conf`, uma `CHAVE="valor"` por linha: terminal, tema, visual, agente, integrações, zsh e o aviso de versão nova. O `work update` junta os arquivos antigos nele sem perder nenhuma escolha. Pode editar à mão; a instalação só reescreve uma chave quando você pede com uma flag, como `--theme`.
- Novo `ACTIVE_PANE="line"` no `settings.conf`: um traço fino na cor de destaque do tema sobre o painel ativo, para saber onde está o foco com dois painéis lado a lado. Vem desligado; `Ctrl+b r` aplica, sem reiniciar a sessão.
- Correção: a checagem diária de versão nova voltou a funcionar. Desde a reorganização do código ela não rodava, e o `work` e o painel não avisavam de versões novas.

### English

- `work review` uses your own agent's review. In Claude Code, it pastes `/code-review` into the chat you are using; you check it and press Enter, and the findings arrive there, with the agent ready to fix them.
- To use another review, such as the BMAD one or a skill of yours, put `REVIEW_COMMAND="/the-command"` in `.workdeck/review.conf` in the project (only a slash command, without arguments) or in `settings.conf`, for every project. `work review --pane` opens the separate pane from before, which still applies with `staged` and with agents without their own review.
- Your choices live in a single file, `~/.config/workdeck/settings.conf`, one `KEY="value"` per line: terminal, theme, look, agent, integrations, zsh and the new version notice. `work update` folds the old files into it without losing any choice. You can edit it by hand; the installer only rewrites a key when you ask with a flag, such as `--theme`.
- New `ACTIVE_PANE="line"` in `settings.conf`: a thin line in the theme accent color over the active pane, to see where the focus is with two panes side by side. Off by default; `Ctrl+b r` applies it without restarting the session.
- Fix: the daily check for a new version works again. Since the code reorganization it did not run, and `work` and the panel did not tell you about new versions.

## v1.0.1

### Português

- O `work update` não trava mais quando uma versão é republicada com o mesmo nome: a busca de versões passa a aceitar a tag nova no lugar da antiga.
- `Option+Delete` volta a apagar a palavra inteira dentro do Claude Code e de outros agentes no tmux. No kitty, `Shift+Enter` pula a linha no agente em vez de enviar a mensagem, e só dentro do tmux.
- **`Alt+←` e `Alt+→` não trocam mais de painel**, para continuarem andando por palavras no shell e nos agentes. `Alt+↑` e `Alt+↓` seguem trocando de painel, e `Ctrl+b` com as setas troca em qualquer direção.
- Ao atualizar, a sessão aberta já passa a usar os atalhos novos depois de recarregar a configuração (`Ctrl+b r`); não precisa do `work kill`. No kitty, recarregue a configuração com `Ctrl+Cmd+,` ou abra o kitty de novo, senão o `Shift+Enter` não muda.

### English

- `work update` no longer gets stuck when a version is republished under the same name: the version lookup now accepts the new tag in place of the old one.
- `Option+Delete` deletes the whole word again inside Claude Code and other agents in tmux. In kitty, `Shift+Enter` adds a line in the agent instead of sending the message, and only inside tmux.
- **`Alt+←` and `Alt+→` no longer switch panes**, so they keep moving by words in the shell and in the agents. `Alt+↑` and `Alt+↓` still switch panes, and `Ctrl+b` with the arrows switches in any direction.
- When you update, the open session uses the new shortcuts after reloading the configuration (`Ctrl+b r`); no `work kill` needed. In kitty, reload the configuration with `Ctrl+Cmd+,` or reopen kitty, otherwise `Shift+Enter` does not change.

## v1.0.0

### Português

O workdeck é um framework para trabalhar com agentes de IA no terminal,
construído sobre o tmux. Esta é a primeira versão numerada do zero; quem já
usava o workdeck recebe esta atualização normalmente e não perde nenhuma
escolha.

- `work` abre uma sessão do tmux com uma janela por projeto e o painel do workdeck. A sessão sobrevive a fechar o terminal, e depois de reiniciar a máquina o `work` abre os projetos de novo.
- Os comandos do dia a dia: `work`, `work add`, `work review`, `work update`, `work kill` e `work uninstall`. O menu (Ctrl+b h) lista os projetos, as ações e os atalhos.
- `work review` pede ao seu agente de IA uma revisão da mudança antes do commit, num painel separado da conversa que escreveu o código, com uma bolinha por achado: vermelha para bug a corrigir antes do commit, laranja para atenção que pode ficar para depois e verde para o que está certo, e no fim um veredito.
- O painel mostra a branch e as mudanças de cada projeto. Qualquer executável em `~/.config/workdeck/panels/` vira um bloco do painel, e `chmod -x` desliga um bloco, inclusive os que vêm prontos.
- Funciona em qualquer terminal: a única dependência é o tmux. A instalação pergunta qual terminal você usa e oferece os extras dele: no kitty, os atalhos `cmd` e, se você quiser, o tema e a fonte JetBrains Mono; no Warp, o tema copiado para a pasta dele e onde escolher tema, fonte e a Option como Meta. O workdeck não instala terminal.
- Três temas (`catppuccin-mocha`, `nord` e `min-dark`) e o zsh do workdeck opcional, com oh-my-zsh e zinit.
- Integrações opcionais com `--with`: BMAD, Spec Kit e ai-memory.
- Instalação numa linha com `get.sh` e reversível: o que ela escreve nos seus arquivos fica entre marcadores, e o `work uninstall` desfaz tudo.
- README e guias em inglês e em português. O que aparece no terminal é em português.

### English

workdeck is a framework for working with AI agents in the terminal, built on
tmux. This is the first version numbered from scratch; existing users get this
update normally and lose no choice.

- `work` opens a tmux session with one window per project and the workdeck panel. The session survives closing the terminal, and after a restart `work` opens the projects again.
- The everyday commands: `work`, `work add`, `work review`, `work update`, `work kill` and `work uninstall`. The menu (Ctrl+b h) lists the projects, the actions and the shortcuts.
- `work review` asks your AI agent to review the change before the commit, in a pane separate from the conversation that wrote the code, with a dot per finding: red for a bug to fix before the commit, orange for a concern that can wait and green for what is right, and a verdict at the end.
- The panel shows the branch and the changes of each project. Any executable in `~/.config/workdeck/panels/` becomes a block of the panel, and `chmod -x` turns a block off, including the shipped ones.
- Works in any terminal: tmux is the only dependency. The installer asks which terminal you use and offers its extras: in kitty, the `cmd` shortcuts and, if you want, the theme and the JetBrains Mono font; in Warp, the theme copied to its folder and where to pick the theme, the font and Option as Meta. workdeck does not install a terminal.
- Three themes (`catppuccin-mocha`, `nord` and `min-dark`) and the optional workdeck zsh, with oh-my-zsh and zinit.
- Optional integrations with `--with`: BMAD, Spec Kit and ai-memory.
- One-line install with `get.sh`, fully reversible: what it writes to your files sits between markers, and `work uninstall` undoes everything.
- README and guides in English and Portuguese. What shows up in the terminal is in Portuguese.
