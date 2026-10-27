# workdeck

Um terminal, uma sessão, uma janela por projeto.

O tmux cuida das janelas e divisões, não o terminal. A sessão sobrevive a
fechar o terminal, cair a conexão ou reiniciar a máquina: você volta com
`work` e tudo está onde estava.

Junto vêm um `git review` com diff colorido e um painel onde você põe os
comandos que quiser ver de relance.

**Roda em macOS e Linux.** No Windows, pelo WSL — o tmux não existe no
Windows nativo, e o instalador diz isso em vez de fingir que funciona.

**Não exige um terminal específico.** Os atalhos são `Alt` e quem os
interpreta é o tmux, então valem no Terminal.app, GNOME Terminal, Konsole,
Windows Terminal, kitty, WezTerm, Alacritty ou qualquer outro. Há adaptadores
opcionais em `terminals/` para quem usa Mac e prefere `cmd`.

---

## Instalação

```bash
git clone https://github.com/<voce>/workdeck.git
cd workdeck
./install.sh
```

Depois:

```bash
$EDITOR ~/.config/workdeck/projects.conf   # seus projetos
source ~/.zshrc                            # ou ~/.bashrc
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

## Os projetos

Tudo vem de `~/.config/workdeck/projects.conf`, uma linha por janela:

```
nome|caminho|comando opcional
```

```
api|$HOME/projetos/minha-api
web|$HOME/projetos/meu-front
notas|~/notas
painel|$HOME|work-panel
```

- **nome** vira o nome da janela no tmux, e o argumento de `work <nome>`
- **caminho** é onde a janela abre; aceita `~` e `$HOME`
- **comando** é opcional — se existir, a janela roda isso em vez de um shell

A ordem do arquivo é a ordem das janelas, numeradas a partir de 1. Projeto que
não existe no disco é pulado sem erro, então dá para deixar linhas de coisas
que você ainda não clonou.

**Para adicionar um projeto:** acrescente uma linha, feche a sessão com
`work kill` e abra de novo com `work`. As janelas são criadas na abertura da
sessão; sem fechar, a sessão antiga continua com a lista antiga.

| Comando | O que faz |
|---|---|
| `work` | Abre a sessão, ou volta para ela |
| `work api` | Abre e já vai para a janela `api` |
| `work kill` | Fecha a sessão inteira |

Para usar outro nome de sessão: `export WORKDECK_SESSION=outro`.

---

## Atalhos

Funcionam em qualquer terminal, porque quem os interpreta é o tmux.

| Atalho | Resultado |
|---|---|
| <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | Vai direto para a janela N |
| <kbd>Alt</kbd>+<kbd>setas</kbd> | Pula entre os painéis |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> | Janela anterior / próxima |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>T</kbd> | Nova janela, na pasta atual |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>D</kbd> | Divide lado a lado |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>S</kbd> | Divide em cima/embaixo |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>Z</kbd> | Zoom: o painel ocupa a janela |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>X</kbd> | Fecha o painel |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>R</kbd> | Renomeia a janela |
| <kbd>Alt</kbd>+<kbd>shift</kbd>+<kbd>E</kbd> | Solta a sessão (ela continua viva) |

**Por que as ações usam Shift.** `Alt`+letra minúscula já tem dono: o readline
usa <kbd>Alt</kbd>+<kbd>b</kbd>, <kbd>Alt</kbd>+<kbd>f</kbd> e
<kbd>Alt</kbd>+<kbd>d</kbd> para andar e apagar palavras na linha de comando.
Mapear essas teclas no tmux roubaria funções que você usa o dia todo. Números
e setas são seguros; por isso eles ficaram sem Shift.

**Para mudar um atalho**, edite `config/tmux.conf` e rode `./install.sh`:

```tmux
bind -n M-S-G new-window -c "#{pane_current_path}" lazygit
```

### Atalhos em `cmd`, no macOS

No Mac, `cmd` nunca chega ao tmux: o sistema intercepta antes. Se você quer
`cmd+1` em vez de `Alt+1`, o terminal precisa traduzir. Há adaptadores prontos
em `terminals/` para kitty, WezTerm e Alacritty — veja `terminals/README.md`.
Só o kitty é instalado automaticamente:

```bash
./install.sh --terminal kitty
```

Nada disso é necessário. É conforto.

---

## `git review`

O git expõe qualquer executável `git-algo` do PATH como `git algo`, então o
comando funciona sem alias nenhum.

| Comando | Mostra |
|---|---|
| `git review` | O que ainda não foi commitado, incluindo arquivos novos |
| `git review branch` | O que a branch tem a mais que a `origin/dev` (ou `develop`) |
| `git review qa` | O mesmo, comparando com a `origin/qa` |
| `git review qa src/` | Só os arquivos dentro do caminho |
| `git review --stat` | Só o resumo, sem o código |
| `git review --force` | Roda mesmo com teste ou build pesado em andamento |

Dentro do diff: <kbd>espaço</kbd> pula para o próximo arquivo, <kbd>b</kbd>
volta, setas rolam, <kbd>q</kbd> sai. Acima de 160 colunas ele abre lado a lado
sozinho.

**Duas decisões que valem conhecer.** Ele se recusa a rodar quando detecta
jest, vitest, cypress, tsc, eslint, vite build, storybook ou playwright
disparados por node na linha de comando: é um diff com syntax highlight, e
junto de uma suíte rodando ele trava a máquina. Servidores de linguagem do
editor são filtrados de propósito, senão a trava pegaria sempre. Ele também
barra quando a pressão de memória do macOS está crítica. `--stat` e `--force`
passam por cima das duas.

**Para mudar a branch base**, edite `base_candidates` em `bin/git-review`.

---

## Painéis

O `work-panel` mostra a saída de vários comandos num pane, atualizando
sozinho. Não depende de nada além do que já está instalado.

```bash
work-panel          # atualiza a cada 60s
work-panel 10       # a cada 10s
work-panel --once   # imprime uma vez e sai
painel              # abre numa janela da sessão e vai até ela
```

Dentro dele, <kbd>q</kbd> sai.

Cada painel é um **executável** em `~/.config/workdeck/panels/`. O nome do
arquivo vira o título, e a ordem é alfabética — use um prefixo numérico para
ordenar. Dois vêm prontos:

| Arquivo | Mostra |
|---|---|
| `10-maquina` | Carga e disco livre |
| `20-git` | Em que branch está cada projeto e se há mudança solta |

```
Maquina
  carga 1.40 · disco livre 259Gi

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
./uninstall.sh
```

Remove os blocos e os scripts. Sua config em `~/.config/workdeck/` fica — para
apagar também, `rm -rf ~/.config/workdeck`.

## Customizando

Quase tudo aqui é para ser trocado. O resumo:

| Quero mudar | Onde | Depois |
|---|---|---|
| Os projetos e a ordem das janelas | `~/.config/workdeck/projects.conf` | `work kill` e `work` |
| Um atalho do teclado | `config/tmux.conf` | `./install.sh` |
| Os atalhos `cmd` no Mac | `terminals/kitty.conf` | `./install.sh --terminal kitty` |
| As cores | `themes/<nome>.conf` e `.tmux` | `./install.sh --theme <nome>` |
| O que aparece no painel | `~/.config/workdeck/panels/` | nada, ele relê sozinho |
| A branch base do `git review` | `bin/git-review`, em `base_candidates` | `./install.sh` |
| O nome da sessão | `export WORKDECK_SESSION=outro` | — |
| Algo que não existe aqui | escreva em `bin/` | `./install.sh` |

Qualquer executável que você puser em `bin/` vai para o `PATH` no próximo
`install.sh`. É assim que o `work`, o `git-review` e o `work-panel`
chegam lá — não há nada de especial neles.

Se você for manter sua própria versão, o caminho mais confortável é dar fork,
mexer no que quiser e rodar o `install.sh` do seu fork. O instalador só
gerencia o que está entre os marcadores `# >>> workdeck >>>`, então o resto
dos seus arquivos continua seu.

## Isto é uma config pessoal

O projeto nasceu da config de uma pessoa e é publicado porque pode ser útil a
outras, não como produto mantido. Use, copie, dê fork e mude o que precisar.
Não espere suporte, roadmap ou compatibilidade entre versões.

## Licença

MIT.
