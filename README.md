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

**Funciona em qualquer terminal**, porque os atalhos são do tmux e não do
terminal. macOS e Linux; no Windows, pelo WSL.

```bash
work                  # abre a sessão, uma janela por projeto
Ctrl+b h              # dentro do work: o menu com tudo (projetos, IA, revisar, dividir)
ai                    # abre a IA ao lado, para te ajudar no projeto; ai help explica
work review           # revisa o que ele escreveu (o mesmo que git review)
work agent claude     # define qual é o seu agente de IA
work painel           # abre o painel de contexto
work doctor           # diz o que funciona no seu ambiente
work help             # menu com as ações, os atalhos e o que falta configurar
```

---

## Instalação

```bash
git clone https://github.com/<voce>/workdeck.git
cd workdeck
./install.sh
```

Depois:

```bash
source ~/.zshrc             # ou ~/.bashrc
work add ~/code/api         # um projeto por vez; Tab completa o caminho
work
```

O instalador detecta o sistema e o gerenciador de pacotes — brew no macOS,
apt, dnf, pacman, zypper ou apk no Linux — e instala o que faltar (`tmux` e
`git-delta`). No Windows nativo ele para e mostra o caminho do WSL.

| Flag | O que faz |
|---|---|
| `--theme <nome>` | Escolhe um tema de `themes/` (padrão: `catppuccin-mocha`) |
| `--terminal kitty` | Instala também os atalhos `cmd` do kitty |
| `--no-deps` | Não instala nada pelo gerenciador de pacotes |
| `--no-reload` | Não recarrega o tmux no fim (útil ao instalar num HOME de teste) |
| `--dry-run` | Mostra o que faria, sem escrever nada |

É idempotente: rodar de novo atualiza em vez de duplicar. Tudo o que ele
escreve nos seus arquivos fica entre marcadores `# >>> workdeck >>>`, e o
`./uninstall.sh` remove exatamente esse trecho.

Se já existir um script seu com o mesmo nome em `~/.local/bin` e com conteúdo
diferente, o instalador guarda uma cópia em `<nome>.antes-do-workdeck` antes
de substituir. O `uninstall.sh` só remove o que não foi alterado desde a
instalação.

### Windows

O tmux não roda no Windows nativo, e é ele que faz o projeto funcionar. O
caminho é o WSL:

```powershell
wsl --install          # PowerShell, como administrador
```

Depois, dentro do WSL, é a instalação normal de Linux. Seu terminal do Windows
continua sendo o terminal — quem gerencia as janelas é o tmux, lá dentro.

---

## O agente de IA

O workdeck não traz nenhum agente. Ele abre o comando que você indicar, num
pane ao lado do seu shell, já na pasta do projeto.

```bash
work agent --list               # procura agentes conhecidos no PATH
work agent claude               # define o seu
work agent                      # mostra o atual
ai                              # abre num pane ao lado
```

<kbd>Ctrl</kbd>+<kbd>b</kbd> e depois <kbd>a</kbd> faz o mesmo sem tirar as
mãos do teclado.

**Sem agente na instalação?** Não precisa instalar de novo. Instale o agente que
quiser pelo método dele, rode `work agent <comando>` e abra com `ai`.
O `work help` mostra se falta esse passo.

O comando pode ter argumentos:

```bash
work agent "aider --no-auto-commits"
```

Na instalação, se você não passar `--agent`, ele procura no seu PATH e pergunta
qual usar. `--yes` pula a pergunta.

O instalador conhece `claude`, `codex`, `copilot`, `aider`, `gemini`,
`opencode`, `cursor-agent`, `crush`, `goose` e `q` — mas isso é só para
oferecer uma lista. Qualquer comando serve.

### Por que um pane, e não uma janela

O agente escreve código que você precisa ver. Com ele ao lado, o `git review`
roda no pane de baixo sem trocar de contexto, e o painel fica a um clique na
barra. É o ponto do projeto.

---

## Integrações

Nada é instalado por padrão. Cada integração é uma peça de terceiros que você
pode querer ou não:

```bash
./install.sh --list-integrations   # ver o que existe
./install.sh --with ai-memory      # ativar (vírgula separa várias)
```

O instalador mostra o que a integração é e de quem é, e só age depois de você
confirmar. Para escrever a sua, veja `integrations/README.md`.

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
| `work review` | O mesmo que `git review` |
| `work painel` | Abre o painel de contexto |

`add`, `help`, `doctor`, `agent`, `review`, `painel`, `escolher` e `kill` são palavras
reservadas: uma janela com um desses nomes não é aberta por `work <nome>`.

Para usar outro nome de sessão: `export WORKDECK_SESSION=outro`.

---

## Atalhos

Funcionam em qualquer terminal, sem configurar nada:

- **<kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd>:** janela anterior / próxima.
- **<kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd>:** painel anterior / próximo.
- **Mouse:** clique no nome da janela na barra de baixo para trocar de janela,
  e num painel para levar o foco até ele. Para mudar o tamanho de um painel,
  arraste a borda dele.
- **<kbd>Ctrl</kbd>+<kbd>b</kbd>, solte, e depois a tecla:**

| Ação | <kbd>Ctrl</kbd>+<kbd>b</kbd> e depois | Atalho direto, opcional |
|---|---|---|
| Vai para a janela N | <kbd>1</kbd>…<kbd>9</kbd> | <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> |
| Pula entre os painéis | <kbd>setas</kbd> | <kbd>Alt</kbd>+<kbd>setas</kbd> |
| Janela anterior / próxima | <kbd>p</kbd> / <kbd>n</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Nova janela, na pasta atual | <kbd>c</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>T</kbd> |
| Divide a tela, no sentido que sobra mais espaço | <kbd>Enter</kbd> | |
| Divide lado a lado | <kbd>v</kbd> ou <kbd>\|</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>D</kbd> |
| Divide em cima/embaixo | <kbd>-</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>S</kbd> |
| Iguala o tamanho dos painéis | <kbd>=</kbd> | |
| Zoom: o painel ocupa a janela | <kbd>z</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>Z</kbd> |
| Fecha o painel | <kbd>x</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>X</kbd> |
| Renomeia a janela | <kbd>,</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>R</kbd> |
| Abre o agente de IA ao lado | <kbd>a</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>A</kbd> |
| **Abre o menu: ir para um projeto, adicionar, IA, revisar, dividir, zoom, fechar** | <kbd>h</kbd> | |
| Solta a sessão (ela continua viva) | <kbd>d</kbd> | <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>E</kbd> |

Os atalhos diretos economizam uma tecla. No Linux funcionam de cara; no Mac, a
tecla Option precisa funcionar como Alt, um ajuste feito uma vez: veja
[A tecla Option, no macOS](#a-tecla-option-no-macos).

**Por que as ações usam Shift.** `Alt`+letra minúscula já tem dono: o readline
usa <kbd>Alt</kbd>+<kbd>b</kbd>, <kbd>Alt</kbd>+<kbd>f</kbd> e
<kbd>Alt</kbd>+<kbd>d</kbd> para andar e apagar palavras na linha de comando.
Mapear essas teclas no tmux roubaria funções que você usa o dia todo. Números
e setas são seguros; por isso eles ficaram sem Shift.

**Para mudar um atalho**, edite `config/tmux.conf` e rode `./install.sh`:

```tmux
bind -n M-S-G new-window -c "#{pane_current_path}" lazygit
```

### Terminais

Qualquer terminal serve, porque os atalhos são do tmux. Se você ainda não tem
um preferido, estes são os mais usados em cada sistema:

| Sistema | Terminal | |
|---|---|---|
| macOS | Terminal.app | já vem instalado |
| | [iTerm2](https://iterm2.com) | o mais popular do Mac |
| | [kitty](https://sw.kovidgoyal.net/kitty/) | rápido, configurado por arquivo de texto |
| | [WezTerm](https://wezterm.org) | multiplataforma, configurado em Lua |
| | [Ghostty](https://ghostty.org) | recente, nativo |
| Linux | GNOME Terminal | padrão no GNOME |
| | Konsole | padrão no KDE |
| | [Alacritty](https://alacritty.org) | mínimo, acelerado por GPU |
| | [kitty](https://sw.kovidgoyal.net/kitty/) · [WezTerm](https://wezterm.org) · [Ghostty](https://ghostty.org) | os mesmos do Mac |
| Windows | [Windows Terminal](https://learn.microsoft.com/windows/terminal/) | o padrão atual, com suporte a WSL |
| | [WezTerm](https://wezterm.org) | se você quer a mesma config nos três sistemas |

No Linux e no Windows, `Alt` chega ao tmux e os atalhos funcionam sem
configurar nada. No Mac, veja a seção abaixo.

### A tecla Option, no macOS

Opcional: só para os atalhos diretos. No Mac, a tecla Option (⌥) escreve
caracteres especiais por padrão: <kbd>Option</kbd>+<kbd>2</kbd> vira `™` em vez
de trocar de janela. Para ela agir como Alt, é um ajuste feito uma vez, e o
instalador e o `workdeck-doctor` dizem onde fica:

| Terminal | Onde ligar |
|---|---|
| Terminal.app | Ajustes → Perfis → Teclado → marque "Usar Option como tecla Meta" |
| iTerm2 | Settings → Profiles → Keys → General → "Left Option key": Esc+ |
| kitty | no `kitty.conf`: `macos_option_as_alt left` |
| Ghostty | na config: `macos-option-as-alt = left` |
| Alacritty | no `alacritty.toml`, em `[window]`: `option_as_alt = "OnlyLeft"` |
| WezTerm | nada, já vem assim |

### Atalhos em `cmd`, no macOS

No Mac, `cmd` nunca chega ao tmux: o sistema intercepta antes. Se você quer
`cmd+1` em vez de `Alt+1`, o terminal precisa traduzir. Há adaptadores prontos
em `terminals/` para kitty, WezTerm e Alacritty — veja `terminals/README.md`.
Só o kitty é instalado automaticamente:

```bash
./install.sh --terminal kitty
```

Nada disso é necessário. É conforto, e só no Mac.

---

## `git review`

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
| `20-git` | Em que branch está cada projeto e se há mudança solta |

```
Git
  api            main
  web            feature/login  (6 alterado(s))
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

Para versionar os seus junto do projeto, ponha em `config/panels/` e rode
`./install.sh` — ele copia o que ainda não existe e nunca sobrescreve um
painel seu.

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
./install.sh --theme nord
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
~/.config/kitty/kitty.conf        só com --terminal kitty
```

---

## Desinstalar

```bash
./uninstall.sh            # tira os blocos e os scripts; sua config fica
./uninstall.sh --restore  # devolve os arquivos ao estado de antes da instalação
./uninstall.sh --all      # remove tudo, inclusive ~/.config/workdeck
./uninstall.sh --dry-run  # mostra o que faria
```

O instalador guarda uma cópia de cada arquivo antes de tocar nele pela primeira
vez, em `~/.config/workdeck/.backups/`, e anota tudo o que fez num manifesto.
O `--restore` usa essas cópias: seu `.tmux.conf` e seu `.zshrc` voltam byte a
byte ao que eram.

Fora isso, ele nunca remove o que não é dele. Script que você alterou depois
da instalação fica, com aviso. Se existia um script seu com o mesmo nome, o
instalador guardou em `<nome>.antes-do-workdeck` e o desinstalador devolve.

---

## Customizando

Quase tudo aqui é para ser trocado. O resumo:

| Quero mudar | Onde | Depois |
|---|---|---|
| Os projetos e a ordem das janelas | `~/.config/workdeck/projects.conf` | `work kill` e `work` |
| Um atalho do teclado | `config/tmux.conf` | `./install.sh` |
| Os atalhos `cmd` no Mac | `terminals/kitty.conf` | `./install.sh --terminal kitty` |
| As cores | `themes/<nome>.conf` e `.tmux` | `./install.sh --theme <nome>` |
| O que aparece no painel | `~/.config/workdeck/panels/` | nada, ele relê sozinho |
| O nome da sessão | `export WORKDECK_SESSION=outro` | — |
| Algo que não existe aqui | escreva em `bin/` | `./install.sh` |

Qualquer executável que você puser em `bin/` vai para o `PATH` no próximo
`install.sh`. É assim que o `work`, o `git-review` e o `work-panel`
chegam lá — não há nada de especial neles.

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
