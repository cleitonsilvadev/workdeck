# Mudanças

O `work update` mostra o trecho da versão nova antes de perguntar se quer
atualizar. Cada versão é uma tag `vX.Y.Z`.

## v1.1.2

- Correção: no Claude Code, o `work review` colava o `/code-review` mas não apertava Enter. A leitura da tela não reconhecia o campo de mensagem do Claude, que usa um espaço especial depois do `❯` e mostra uma sugestão apagada quando está vazio. Agora o review começa sozinho, como prometido na v1.1.1.

## v1.1.1

- No Claude Code, o `work review` começa o review sozinho, sem você apertar Enter no chat. Ele só manda quando o Claude terminou: se ainda estiver trabalhando, com uma pergunta aberta ou com uma mensagem sua pela metade, não manda nada e diz o que falta.
- Correção: sem nada por commitar, o `work review` dizia que não havia o que revisar mesmo com commits que ainda não subiram. Agora, com o Claude aberto, ele manda o `/code-review`, que revisa esses commits.

## v1.1.0

- O `work review` usa o review do seu próprio agente. No Claude Code, ele cola o `/code-review` no chat que você está usando; você confere e aperta Enter, e os achados chegam ali, com o agente pronto para corrigir.
- Para usar outro review, como o do BMAD ou uma skill sua, ponha `REVIEW_COMMAND="/o-comando"` em `.workdeck/review.conf` no projeto (só um comando de barra, sem argumentos) ou no `settings.conf`, para todos. `work review --pane` abre o painel separado de antes, que continua valendo com `staged` e com agentes sem review próprio.
- As suas escolhas ficam num arquivo só, `~/.config/workdeck/settings.conf`, uma `CHAVE="valor"` por linha: terminal, tema, visual, agente, integrações, zsh e o aviso de versão nova. O `work update` junta os arquivos antigos nele sem perder nenhuma escolha. Pode editar à mão; a instalação só reescreve uma chave quando você pede com uma flag, como `--theme`.
- Novo `ACTIVE_PANE="line"` no `settings.conf`: um traço fino na cor de destaque do tema sobre o painel ativo, para saber onde está o foco com dois painéis lado a lado. Vem desligado; `Ctrl+b r` aplica, sem reiniciar a sessão.
- Correção: a checagem diária de versão nova voltou a funcionar. Desde a reorganização do código ela não rodava, e o `work` e o painel não avisavam de versões novas.

## v1.0.1

- O `work update` não trava mais quando uma versão é republicada com o mesmo nome: a busca de versões passa a aceitar a tag nova no lugar da antiga.
- `Option+Delete` volta a apagar a palavra inteira dentro do Claude Code e de outros agentes no tmux. No kitty, `Shift+Enter` pula a linha no agente em vez de enviar a mensagem, e só dentro do tmux.
- **`Alt+←` e `Alt+→` não trocam mais de painel**, para continuarem andando por palavras no shell e nos agentes. `Alt+↑` e `Alt+↓` seguem trocando de painel, e `Ctrl+b` com as setas troca em qualquer direção.
- Ao atualizar, a sessão aberta já passa a usar os atalhos novos depois de recarregar a configuração (`Ctrl+b r`); não precisa do `work kill`. No kitty, recarregue a configuração com `Ctrl+Cmd+,` ou abra o kitty de novo, senão o `Shift+Enter` não muda.

## v1.0.0

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
