# workdeck

Um workflow de terminal para trabalhar com agentes de IA.

Uma sessão do tmux, uma janela por projeto, o agente num pane ao lado, e o que
você precisa olhar enquanto ele trabalha: o diff do que ele escreveu, o estado
dos seus repositórios, o que mais você quiser.

A sessão sobrevive a fechar o terminal, cair a conexão ou reiniciar a máquina.
Você volta com `work` e tudo está onde estava, agente incluso.

**Funciona com qualquer agente de CLI** — Claude Code, Codex, Copilot CLI,
Aider, Gemini, o que você usar. O projeto não embute nenhum: ele abre o
comando que você escolher.

**Feito para o [kitty](https://sw.kovidgoyal.net/kitty/)**, no macOS e no Linux.
A instalação já baixa o kitty e deixa ele com o tema, a fonte e os atalhos `cmd`.
Os atalhos são do tmux, então o `work` também abre em outro terminal: só o
visual muda.

```bash
work                  # abre a sessão, uma janela por projeto
work add ~/projeto    # acrescenta um projeto; Tab completa o caminho
work review           # a IA faz um self code review da mudança, num painel embaixo
work update           # atualiza o workdeck
```

Dentro do work, <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>h</kbd> abre o menu com
tudo, e `work help` lista os outros comandos.

---

## Instalação

Numa linha, sem clonar nada:

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/instalar.sh | bash
```

Ele baixa a versão publicada mais nova para `~/.local/share/workdeck` e roda o
instalador de lá. As opções passam adiante, como em
`curl -fsSL … | bash -s -- --theme nord`. Para ler o script antes de rodar:

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/instalar.sh -o instalar.sh
less instalar.sh && bash instalar.sh
```

Depois, abra o kitty (ou feche e abra, se a instalação rodou nele), para ele
carregar o zsh, o visual e os comandos do workdeck, e rode:

```bash
work
```

O `work` abre o painel, e o painel mostra como adicionar os seus projetos.

O instalador detecta o sistema e o gerenciador de pacotes — brew no macOS,
apt, dnf, pacman, zypper ou apk no Linux — e instala o que faltar (`tmux` e
`git-delta`). O kitty vem do instalador oficial dele, sem sudo: em
`~/Applications` no Mac e em `~/.local/kitty.app` no Linux. Detalhes em
`terminals/README.md`.

| Flag | O que faz |
|---|---|
| `--theme <nome>` | Escolhe um tema de `themes/` (padrão: `catppuccin-mocha`) |
| `--with <nome>` | Liga integrações sem perguntar: `bmad`, `spec-kit`, `ai-memory` |
| `--zsh` | Instala o oh-my-zsh e o zinit sem perguntar (veja abaixo) |
| `--no-deps` | Não instala nada pelo gerenciador de pacotes |
| `--no-reload` | Não recarrega o tmux no fim (útil ao instalar num HOME de teste) |
| `--dry-run` | Mostra o que faria, sem escrever nada |

É idempotente: rodar de novo atualiza em vez de duplicar. Tudo o que ele
escreve nos seus arquivos fica entre marcadores `# >>> workdeck >>>`, e o
`work uninstall` remove exatamente esse trecho.

Se já existir um script seu com o mesmo nome em `~/.local/bin`, o instalador não
o substitui e avisa. O `work uninstall` só remove o que não foi alterado desde a
instalação. Para rodar a instalação de novo com outras opções, use
`work install`, por exemplo `work install --theme nord`.

---

### O zsh do workdeck

A instalação já deixa o zsh pronto, com "sim" como resposta padrão: o
[oh-my-zsh](https://ohmyz.sh) com o tema robbyrussell
(`➜  projeto git:(main) ✗`), e o [zinit](https://github.com/zdharma-continuum/zinit) com três plugins:
sugestões enquanto digita (zsh-autosuggestions), cores nos comandos
(fast-syntax-highlighting) e mais coisa para completar com Tab
(zsh-completions). Tudo é carregado pelo bloco do workdeck no `.zshrc`; o resto
do seu arquivo fica como está.

- Se você já tem oh-my-zsh, zinit, Starship ou Powerlevel10k, ele não pergunta e
  não mexe.
- No Linux sem zsh, ele instala o zsh e pergunta antes de trocar o seu shell
  padrão (pede a senha).
- Prefere outro tema do oh-my-zsh? Ponha `export WORKDECK_ZSH_THEME=agnoster`
  (ou qualquer outro) no `~/.zshrc`, antes do bloco do workdeck.
- Não quer? Responda "n" na instalação. Para tirar depois, `work uninstall`.
- Quem já tinha o workdeck recebe a pergunta no próximo `work update`.

## O agente de IA

O workdeck não traz nem abre nenhum agente: você abre o seu como sempre, no
painel que quiser (`claude`, `codex`…). O `work agent` só diz qual IA o
`work review` usa.

```bash
work agent --list               # procura agentes conhecidos no PATH
work agent claude               # define o seu
work agent                      # mostra o atual
```

O comando pode ter argumentos:

```bash
work agent "aider --no-auto-commits"
```

Na instalação, se você não passar `--agent`, ele procura no seu PATH e pergunta
qual usar. `--yes` pula a pergunta. O instalador conhece `claude`, `codex`,
`copilot`, `aider`, `gemini`, `opencode`, `cursor-agent`, `crush`, `goose` e
`q`, mas isso é só para oferecer uma lista. Qualquer comando serve.

---

## Integrações

Nada é instalado por padrão. Cada integração é uma peça de terceiros que você
pode querer ou não: o framework que guia a IA (BMAD, Spec Kit) e a memória entre
sessões (ai-memory).

Na primeira instalação, o instalador lista as integrações e pergunta quais você
usa; para cada uma escolhida, mostra de quem é e como ligar. Ele guarda a
resposta e não pergunta de novo. Para ver ou ligar depois:

```bash
work install --list-integrations   # ver o que existe
work install --with bmad           # ativar (vírgula separa várias)
``` Para escrever a sua, veja `integrations/README.md`.

O workdeck é um workflow, não um gerenciador de pacotes. Estas integrações
estão aqui porque aparecem muito em trabalho com agentes — não porque o
projeto as mantém ou as auditou.

---

## Diagnóstico

```bash
workdeck-doctor
```

Diz o que funciona no seu ambiente e o que não vai funcionar: se o tmux e o
delta estão instalados, qual terminal você está usando, se ele suporta cores
de 24 bits, se os atalhos em `cmd` são possíveis aí, se há um agente
configurado e se o `~/.local/bin` está no PATH. Com `--quiet`, só os
problemas.

Rode isso antes de abrir uma issue dizendo que algo não funciona.

---

## Os projetos

Adicione um projeto por vez, passando o caminho:

```bash
work add ~/code/api              # Tab completa o caminho
work add                         # sem caminho, usa a pasta atual
```

O nome da janela é o nome da pasta. Se a sessão já estiver aberta, a janela
aparece na hora; se a pasta já estiver no work, nada muda.

Para tirar um projeto, feche a janela dele: `exit` no último painel, ou
<kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>x</kbd>. Ele sai do `projects.conf`, e o
próximo `work` não abre mais. Para voltar, `work add` de novo. Fechar só um dos
painéis divididos, ou o agente, não tira nada.

Para escolher vários de uma vez, `work escolher` procura os repositórios git da
sua pasta pessoal (até 4 níveis, sem `Library`, `node_modules` nem pastas
ocultas) e mostra uma lista, dos mais usados para os menos. A busca pode
demorar numa pasta pessoal grande, ou quando o macOS pede permissão para
pastas como Documentos:

```
  Escolha os projetos do seu work
  ↑↓ move · espaço marca · a marca todos · enter confirma · q sai

  [x] api                  ~/code/api                                 hoje
  [x] web                  ~/code/web                                 ontem
  [ ] blog                 ~/projetos/blog                            há 2 meses
```

Os cinco mais usados já vêm marcados; na maioria das vezes basta um
<kbd>enter</kbd>. A escolha fica salva, e os próximos `work` abrem direto. Rodar
`work escolher` de novo mostra a lista com os atuais marcados.

A escolha vira `~/.config/workdeck/projects.conf`, uma linha por janela, que
também dá para editar à mão:

```
nome|caminho|comando opcional
```

```
painel|$HOME|work-panel
api|$HOME/projetos/minha-api
web|$HOME/projetos/meu-front
notas|~/notas
```

- **nome** vira o nome da janela no tmux, e o argumento de `work <nome>`
- **caminho** é onde a janela abre; aceita `~` e `$HOME`
- **comando** é opcional — se existir, a janela roda isso em vez de um shell

A ordem do arquivo é a ordem das janelas, numeradas a partir de 1. Projeto que
não existe no disco é pulado sem erro, então dá para deixar linhas de coisas
que você ainda não clonou.

**Para adicionar um projeto:** `work add <caminho>`. Para tirar ou
reordenar, `work escolher` ou edite o arquivo, e depois feche a sessão com
`work kill` e abra de novo com `work`. As janelas são criadas na abertura da
sessão; sem fechar, a sessão antiga continua com a lista antiga.

| Comando | O que faz |
|---|---|
| `work` | Abre a sessão, ou volta para ela |
| `work api` | Abre e já vai para a janela `api` |
| `work add <caminho>` | Acrescenta o projeto como janela; sem caminho, usa a pasta atual |
| `work escolher` | Escolhe de novo os projetos |
| `work kill` | Fecha a sessão inteira |
| `work help` | Abre o menu com as ações; `--texto` mostra comandos, atalhos e o que falta configurar |
| `work doctor` | Diz o que funciona no seu ambiente |
| `work agent <cmd>` | Define o agente de IA; sem nada, mostra o atual |
| `work review [staged\|branch]` | A IA faz um self code review da mudança antes do commit |
| `work painel` | Abre o painel de contexto |

`add`, `help`, `doctor`, `agent`, `review`, `painel`, `escolher`, `update`, `versao`, `install`, `uninstall` e `kill` são palavras
reservadas: uma janela com um desses nomes não é aberta por `work <nome>`.

Para usar outro nome de sessão: `export WORKDECK_SESSION=outro`.

---

## Atalhos

O dia a dia, sem configurar nada:

| Para | Teclas |
|---|---|
| **Abrir o menu com tudo** (projetos, revisar, dividir…) | <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>h</kbd> |
| Ir para o projeto anterior / próximo | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Ir direto para a janela N | <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>1</kbd>…<kbd>9</kbd> |
| Dividir a tela (ao lado ou embaixo, onde couber) | <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>Enter</kbd> |
| Escolher o sentido: ao lado / embaixo | <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>v</kbd> / <kbd>-</kbd> |
| Trocar de painel dentro da janela | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Zoom no painel, e de novo para voltar | <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>z</kbd> |
| Fechar o painel | <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>x</kbd> |
| Pedir à IA um self code review antes do commit | `work review` |

<kbd>Ctrl</kbd>+<kbd>b</kbd> quer dizer: aperte <kbd>Ctrl</kbd>+<kbd>b</kbd>,
solte, e depois a tecla. O mouse também funciona: clique na janela na barra de
baixo, ou num painel, e arraste a borda para mudar o tamanho.

Só as teclas do workdeck funcionam depois do <kbd>Ctrl</kbd>+<kbd>b</kbd>; uma
fora da lista mostra "tecla sem uso no workdeck — Ctrl+b h abre o menu". A lista
completa está em `work help`, ou <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>?</kbd>.

<details>
<summary>Atalhos de uma tecla com Alt, e como mudar os atalhos</summary>

Há atalhos diretos com Alt, que economizam uma tecla: <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd>
vai para a janela, <kbd>Alt</kbd>+setas troca de painel e
<kbd>Alt</kbd>+<kbd>shift</kbd>+letra faz as ações (<kbd>D</kbd> divide ao lado,
<kbd>S</kbd> embaixo, <kbd>Z</kbd> zoom, <kbd>X</kbd> fecha, <kbd>A</kbd> abre a
IA). No kitty do workdeck funcionam de cara, inclusive no Mac, onde a Option
já age como Alt.

As ações usam Shift porque `Alt`+letra minúscula é do readline (andar e apagar
palavras na linha de comando).

**Para acrescentar ou trocar um atalho**, ponha o `bind` no seu `~/.tmux.conf`,
depois do bloco do workdeck: o que estiver antes é desligado junto com os do
tmux, e o bloco é reescrito a cada atualização.

```tmux
bind -n M-S-G new-window -c "#{pane_current_path}" lazygit
```

</details>

### O kitty

O workdeck foi feito para o kitty, e a instalação deixa ele pronto: tema, fonte
JetBrains Mono, a Option do Mac como Alt e, no Mac, atalhos em `cmd`
(`cmd+1…9` vai para a janela, `cmd+d` divide ao lado, `cmd+h` abre o menu). A
lista completa está em `terminals/README.md`.

Em outro terminal o `work` abre do mesmo jeito, porque os atalhos são do tmux:
`Ctrl+b`, `Shift`+setas e o mouse funcionam em qualquer um. Ele só avisa, uma vez
por dia, que o visual e os atalhos `cmd` são do kitty. Por SSH ele não avisa.

```bash
work kitty                 # diz se você está no kitty
work kitty --nao-avisar    # desliga o aviso; --avisar liga de novo
```

---

## `work review`

Um self code review antes do commit: a sua IA lê a mudança e o código em volta e
revisa como a pessoa sênior que vai ser chamada se aquilo quebrar.

```bash
work review            # o que ainda não foi commitado
work review staged     # só o que está no stage (git add)
work review branch     # tudo o que a branch mudou em relação à principal
```

O review abre num painel embaixo do chat da sua IA (ou do painel em que você
está), separado da conversa que escreveu o código. Rodar de novo manda o pedido
para o mesmo painel. Com o `claude`, cada branch tem uma sessão de review só: o
`work review` retoma a mesma conversa (`claude --resume`), em vez de criar uma
por vez, e o `/resume` não enche de "self code review". Na conversa retomada, a
IA diz o que da revisão anterior foi corrigido e o que continua.

A IA procura bugs, falhas de segurança e segredos, código arriscado sem teste,
trechos lentos, o que dá para cortar e arquivos fora do escopo. Cada achado vem
com a gravidade (corrigir antes do commit, vale corrigir, opcional), o que o
código faz, o que dá errado, como corrigir e o que acontece se você não
corrigir; no fim, um veredito. Ela não altera nada: só revisa.

**O seu fluxo de review.** O pedido manda a IA usar o agente de review e os PRDs
ou stories que as instruções dela apontam (`CLAUDE.md`, `AGENTS.md`, skills),
como um `bmad-code-review` ou uma skill sua de review de PR, e dizer na
primeira linha qual usou. Se o seu framework fica fora do projeto, num
repositório do time, por exemplo, diga onde nas instruções da IA: assim ele
vale também quando você pede uma revisão direto, sem o workdeck.

Para acrescentar algo a todo review, como a branch base ou a skill preferida:

```bash
work review --editar            # vale para todos os projetos
work review --editar projeto    # só para este, em .workdeck/review.md
```

Com `claude`, `codex` e `gemini`, o pedido já entra na conversa. Com outra IA, ele
vai para a área de transferência e para `~/.cache/workdeck/pedido-de-review.md`,
para você colar. A ideia vem do passo de revisão do
[ponytail](https://github.com/dietrichgebert/ponytail).

## `git review`

Só o diff, sem IA, para quem quer olhar a mudança por conta própria.

O git expõe qualquer executável `git-algo` do PATH como `git algo`, então o
comando funciona sem alias nenhum.

`git review` mostra o que ainda não foi commitado, incluindo arquivos novos.

Dentro do diff: <kbd>espaço</kbd> pula para o próximo arquivo, <kbd>b</kbd>
volta, setas rolam, <kbd>q</kbd> sai. Acima de 160 colunas ele abre lado a lado
sozinho.

### Configurando

Para mudar o layout ou o tema:

```bash
cp config/git-review.example.conf ~/.config/workdeck/git-review.conf
```

| Variável | Padrão |
|---|---|
| `SIDE_BY_SIDE_MIN_COLS` | `160` |
| `DELTA_SYNTAX_THEME` | vazio (o delta decide, e respeita `BAT_THEME`) |

---

## Painéis

O painel é a janela 1 da sessão: a visão geral do seu work em cima, e um
terminal de 8 linhas embaixo para digitar. Sem nenhum projeto, o `work` abre só com ele,
mostrando o que falta fazer, e o `work add` digitado ali já cria a janela.

Por baixo, o `work-panel` mostra a saída de vários comandos, atualizando
sozinho. Não depende de nada além do que já está instalado.

```bash
work painel         # abre ou redesenha a janela do painel e vai até ela
work-panel          # atualiza a cada 60s
work-panel 10       # a cada 10s
work-panel --once   # imprime uma vez e sai
```

Dentro dele, <kbd>q</kbd> sai.

Cada painel é um **executável** em `~/.config/workdeck/panels/`. O nome do
arquivo vira o título, e a ordem é alfabética — use um prefixo numérico para
ordenar; os que começam com `00-` aparecem sem título. Dois vêm prontos:

| Arquivo | Mostra |
|---|---|
| `00-workdeck` | O logo, quantos projetos e qual agente, e o que falta configurar |
| `20-projetos` | Cada projeto, a branch e se há mudança solta (`●`) ou está limpo (`✓`) |

```
Projetos
  api            main                 ✓ limpo
  web            feature/login        ● 6 alterado(s)
```

### Fazendo o seu

Qualquer coisa que imprima texto serve: containers rodando, build quebrado,
fila de deploy, tarefas do dia, a cotação do dólar, quantos commits você fez
hoje.

```bash
cat > ~/.config/workdeck/panels/30-docker <<'EOF'
#!/usr/bin/env bash
docker ps --format '{{.Names}}  {{.Status}}'
EOF
chmod +x ~/.config/workdeck/panels/30-docker
```

É só isso. Não precisa reinstalar nem reiniciar: o `work-panel` lê o diretório
a cada ciclo. Esqueceu o `chmod +x`? Ele avisa.

Os painéis que vêm com o workdeck são atualizados pelo `work update`; um painel
que você editou ou criou nunca é sobrescrito.

### Painéis que precisam de credenciais

Se o seu painel fala com uma API — um board, um CI, um serviço interno —, não
coloque token nem URL dentro do script. Leia de um arquivo em
`~/.config/workdeck/`, que fica fora do repositório:

```bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/meu-painel.conf"
[ -f "$CONFIG" ] || { echo "configure primeiro: $CONFIG"; exit 1; }
. "$CONFIG"
```

Assim o painel pode ser compartilhado e o que é seu continua sendo seu.

---

## Temas

| Tema | Fundo | Jeito |
|---|---|---|
| `catppuccin-mocha` | `#1e1e2e` | Pastel por construção. O padrão. |
| `nord` | `#2e3440` | Frio e dessaturado. Verde e vermelho ficam próximos em luminosidade, o que pesa ao ler diff. |
| `min-dark` | `#1f1f1f` | Neutro, derivado do tema Min Dark do VS Code, com o contraste do texto baixado para ~9,6:1. |

```bash
work install --theme nord
```

**Para criar um tema**, copie dois arquivos em `themes/`: `<nome>.conf` com as
cores do kitty (`background`, `foreground`, `color0`–`color15`) e `<nome>.tmux`
com as do tmux (barra, janela ativa, bordas de painel). O instalador cola cada
um no lugar certo.

Vale olhar o contraste antes de fechar um tema. Em fundo escuro, texto acima de
11:1 cansa em sessão longa, e nada abaixo de 4,5:1 deve carregar informação.
Vermelho e verde precisam se separar também em luminosidade, não só em matiz,
senão o diff fica difícil em tela não-retina.

---

## O que vai para onde

```
~/.local/bin/                     work, work-panel, git-review
~/.config/workdeck/projects.conf  seus projetos
~/.config/workdeck/panels/        seus painéis
~/.tmux.conf                      bloco entre os marcadores
~/.zshrc ou ~/.bashrc             bloco entre os marcadores
~/.config/git-review/lesskey      navegação dentro do diff
~/.config/kitty/kitty.conf        bloco entre os marcadores
```

---

## Atualizar

O instalador guarda uma cópia do workdeck em `~/.local/share/workdeck`. Depois
disso, a pasta que você clonou pode ir embora: atualizar não depende dela.

```bash
work update              # procura a versão nova, mostra o que mudou e pergunta
work versao              # a versão instalada
work update --desligar   # para de avisar; work update continua funcionando
work update --ligar      # volta a avisar
work uninstall --all     # desinstala, sem precisar da pasta clonada
```

O `work` e o painel também conferem sozinhos, no máximo uma vez por dia e em
segundo plano: nunca ficam esperando a internet, e sem rede não acontece nada.
Para atualizar na hora, `work update`. Quando há versão
nova, ele mostra o que mudou e pergunta antes de abrir a sessão; se você disser
não, ele não pergunta de novo sobre essa versão. O painel mostra
`● v1.0.0 → v1.1.0: work update` enquanto houver uma versão para instalar.

Só contam versões publicadas como tag (`v1.2.0`), não cada commit. O que muda em
cada uma está no `CHANGELOG.md`. A atualização troca o código e reaplica a
instalação; seus projetos, painéis e a escolha do agente ficam como estão.

## Desinstalar

```bash
work uninstall            # tira os blocos e os scripts; sua config fica
work uninstall --restore  # devolve os arquivos ao estado de antes da instalação
work uninstall --all      # remove tudo, inclusive ~/.config/workdeck e a cópia do código
work uninstall --dry-run  # mostra o que faria
```

O instalador guarda uma cópia de cada arquivo antes de tocar nele pela primeira
vez, em `~/.config/workdeck/.backups/`, e anota tudo o que fez num manifesto.
O `--restore` usa essas cópias: seu `.tmux.conf` e seu `.zshrc` voltam byte a
byte ao que eram.

Fora isso, ele nunca remove o que não é dele. Script que você alterou depois
da instalação fica, com aviso. Se já existia um script seu com o mesmo nome, o
instalador não o substituiu, e o desinstalador também não mexe nele.

---

## Customizando

Quase tudo aqui é para ser trocado. O resumo:

| Quero mudar | Onde | Depois |
|---|---|---|
| Os projetos e a ordem das janelas | `~/.config/workdeck/projects.conf` | `work kill` e `work` |
| Um atalho do teclado | o seu `~/.tmux.conf`, depois do bloco do workdeck | `Ctrl+b r` |
| Os atalhos `cmd` e o visual do kitty | o seu `kitty.conf`, fora do bloco do workdeck | reabra o kitty |
| As cores | `work install --theme <nome>` | — |
| O que aparece no painel | `~/.config/workdeck/panels/` | nada, ele relê sozinho |
| O nome da sessão | `export WORKDECK_SESSION=outro` | — |
| Algo que não existe aqui | um fork do repositório, com o seu script em `bin/` | `./install.sh` no fork |

Qualquer executável em `bin/` vai para o `PATH` na instalação. É assim que o
`work`, o `git-review` e o `work-panel` chegam lá — não há nada de especial
neles.

Se você for manter sua própria versão, o caminho mais confortável é dar fork,
mexer no que quiser e rodar o `install.sh` do seu fork. O instalador só
gerencia o que está entre os marcadores `# >>> workdeck >>>`, então o resto
dos seus arquivos continua seu.

## O que esperar

O workdeck é um ponto de partida, não um produto. Ele não traz os seus
projetos, os seus painéis nem o seu tema: traz a estrutura para você montar os
seus, e três temas para começar.

Isso é intencional. O que torna um setup de terminal bom é ele ser o seu, e
qualquer coisa que viesse pronta aqui seria a opinião de outra pessoa sobre
como você deve trabalhar.

Então: use, copie, dê fork, mude o que precisar. Não há roadmap, não há
garantia de compatibilidade entre versões, e issues podem demorar.

---

## Licença

MIT.
