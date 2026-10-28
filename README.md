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

**Funciona em qualquer terminal**, no macOS e no Linux, porque os atalhos são do
tmux. No [kitty](https://sw.kovidgoyal.net/kitty/) fica completo: tema, fonte e
atalhos `cmd` no Mac. A instalação pergunta se você quer o kitty e já deixa ele
pronto.

```bash
work                  # abre a sessão, uma janela por projeto
work add ~/projeto    # acrescenta um projeto; Tab completa o caminho
work review           # a IA faz um self code review da mudança, num painel embaixo
work update           # atualiza o workdeck
```

Dentro do work, <kbd>Ctrl</kbd>+<kbd>b</kbd> e <kbd>h</kbd> abre o menu: os seus
projetos, cada um com o número da janela (apertar <kbd>2</kbd> vai direto para o
segundo), e as ações (adicionar projeto, review, atualizar, dividir a tela).

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

Depois, feche e abra o terminal (ou abra o kitty, se instalou), para ele carregar
o zsh, o visual e os comandos do workdeck, e rode:

```bash
work
```

O `work` abre o painel, e o painel mostra como adicionar os seus projetos.

O instalador detecta o sistema e o gerenciador de pacotes — brew no macOS,
apt, dnf, pacman, zypper ou apk no Linux — e instala o tmux, se faltar. Se você aceitar o kitty, ele vem do instalador
oficial, sem sudo: em `~/Applications` no Mac e em `~/.local/kitty.app` no Linux.
Quem já tem o kitty não vê a pergunta e só recebe o bloco de configuração. Detalhes em
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
desinstalador remove exatamente esse trecho.

Se já existir um script seu com o mesmo nome em `~/.local/bin`, o instalador não
o substitui e avisa. O desinstalador só remove o que não foi alterado desde a
instalação. Para instalar de novo com outras opções, rode o mesmo comando com
elas no fim: `curl -fsSL … | bash -s -- --theme nord`.

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
- Não quer? Responda "n" na instalação.
- Quem já tinha o workdeck recebe a pergunta no próximo `work update`.

## O agente de IA

O workdeck não traz nem abre nenhum agente: você abre o seu como sempre, num
painel da janela do projeto (`claude`, `codex`…). O `work review` usa a IA que
estiver aberta ali. Se não houver nenhuma, usa a que você escolheu na
instalação, guardada em `~/.config/workdeck/agent.conf`.

---

## Integrações

Nada é instalado por padrão. Cada integração é uma peça de terceiros que você
pode querer ou não: o framework que guia a IA (BMAD, Spec Kit) e a memória entre
sessões (ai-memory).

Na primeira instalação, o instalador lista as integrações e pergunta quais você
usa; para cada uma escolhida, mostra de quem é e como ligar. Ele guarda a
resposta e não pergunta de novo. Para ligar depois, rode a instalação com
`--with bmad` (vírgula separa várias). Para escrever a sua, veja
`integrations/README.md`.

O workdeck é um workflow, não um gerenciador de pacotes. Estas integrações
estão aqui porque aparecem muito em trabalho com agentes — não porque o
projeto as mantém ou as auditou.

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

Os projetos ficam em `~/.config/workdeck/projects.conf`, uma linha por janela,
que também dá para editar à mão:

```
nome|caminho|comando opcional
```

```
painel|$HOME|work-panel
api|$HOME/projetos/minha-api
web|$HOME/projetos/meu-front
notas|~/notas
```

- **nome** vira o nome da janela no tmux
- **caminho** é onde a janela abre; aceita `~` e `$HOME`
- **comando** é opcional — se existir, a janela roda isso em vez de um shell

A ordem do arquivo é a ordem das janelas, numeradas a partir de 1. Projeto que
não existe no disco é pulado sem erro, então dá para deixar linhas de coisas
que você ainda não clonou.

**Para adicionar um projeto:** `work add <caminho>`. Para reordenar, edite o
arquivo, feche a sessão (`tmux kill-session -t work`) e abra de novo com `work`. As janelas são criadas na abertura da
sessão; sem fechar, a sessão antiga continua com a lista antiga.

| Comando | O que faz |
|---|---|
| `work` | Abre a sessão, ou volta para ela |
| `work add <caminho>` | Acrescenta o projeto como janela; sem caminho, usa a pasta atual |
| `work review [staged\|branch]` | A IA faz um self code review da mudança antes do commit |
| `work update` | Atualiza o workdeck |

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
fora da lista mostra "tecla sem uso no workdeck — Ctrl+b h abre o menu".

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

O workdeck funciona em qualquer terminal, mas no kitty fica completo, e a
instalação deixa ele pronto se você aceitar: tema, fonte
JetBrains Mono, a Option do Mac como Alt e, no Mac, atalhos em `cmd`
(`cmd+1…9` vai para a janela, `cmd+d` divide ao lado, `cmd+h` abre o menu). A
lista completa está em `terminals/README.md`.

Em outro terminal o `work` abre do mesmo jeito, porque os atalhos são do tmux:
`Ctrl+b`, `Shift`+setas e o mouse funcionam em qualquer um. O que muda é o
visual e os atalhos `cmd`, e o painel lembra disso quando você está fora do kitty.

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

Para acrescentar algo a todo review, como a branch base ou a skill preferida,
escreva em `~/.config/workdeck/review.md` (todos os projetos) ou em
`.workdeck/review.md` dentro do projeto (só nele). O texto vai no fim do pedido.

Com `claude`, `codex` e `gemini`, o pedido já entra na conversa. Com outra IA, ele
vai para a área de transferência e para `~/.cache/workdeck/pedido-de-review.md`,
para você colar. A ideia vem do passo de revisão do
[ponytail](https://github.com/dietrichgebert/ponytail).

## Painéis

O painel é a janela 1 da sessão: a visão geral do seu work em cima, e um
terminal de 8 linhas embaixo para digitar. Sem nenhum projeto, o `work` abre só com ele,
mostrando o que falta fazer, e o `work add` digitado ali já cria a janela.

Por baixo, o painel mostra a saída de vários comandos e atualiza sozinho a cada
60 segundos. Para outro intervalo, ponha os segundos no fim da linha dele em
`projects.conf`, como em `painel|~|work-panel 30`.

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

É só isso. Não precisa reinstalar nem reiniciar: o painel lê o diretório
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
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/instalar.sh | bash -s -- --theme nord
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
~/.local/bin/                     work, o único comando no PATH
~/.config/workdeck/projects.conf  seus projetos
~/.config/workdeck/panels/        seus painéis
~/.tmux.conf                      bloco entre os marcadores
~/.zshrc ou ~/.bashrc             bloco entre os marcadores
~/.config/kitty/kitty.conf        bloco entre os marcadores
```

---

## Atualizar

O instalador guarda uma cópia do workdeck em `~/.local/share/workdeck`. Depois
disso, a pasta que você clonou pode ir embora: atualizar não depende dela.

```bash
work update              # procura a versão nova, mostra o que mudou e pergunta
work update --desligar   # para de avisar; work update continua funcionando
work update --ligar      # volta a avisar
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
bash ~/.local/share/workdeck/uninstall.sh             # tira os blocos e os scripts; sua config fica
bash ~/.local/share/workdeck/uninstall.sh --restore   # devolve os arquivos ao estado de antes
bash ~/.local/share/workdeck/uninstall.sh --all       # remove tudo, inclusive ~/.config/workdeck e o código
bash ~/.local/share/workdeck/uninstall.sh --dry-run   # mostra o que faria
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
| Os projetos e a ordem das janelas | `~/.config/workdeck/projects.conf` | feche a sessão e rode `work` |
| Um atalho do teclado | o seu `~/.tmux.conf`, depois do bloco do workdeck | `Ctrl+b r` |
| Os atalhos `cmd` e o visual do kitty | o seu `kitty.conf`, fora do bloco do workdeck | reabra o kitty |
| As cores | a instalação com `--theme <nome>` | — |
| O que aparece no painel | `~/.config/workdeck/panels/` | nada, ele relê sozinho |
| O nome da sessão | `export WORKDECK_SESSION=outro` | — |
| Algo que não existe aqui | um fork do repositório, com o seu comando no `bin/work` | `./install.sh` no fork |

Só o `work` vai para o `PATH`. Os outros scripts de `bin/` são peças internas: o
`work` os chama de dentro da instalação, em `~/.local/share/workdeck`.

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
