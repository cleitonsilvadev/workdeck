# workdeck

Um terminal, uma sessão, uma janela por projeto.

O kitty não gerencia abas nem divisões — quem faz isso é o tmux. O kitty só
traduz os atalhos de macOS para o prefixo do tmux. <kbd>cmd</kbd>+<kbd>3</kbd>
não troca de aba do terminal: ele manda `Ctrl+b 3` e o tmux troca de janela.

O ganho é que a sessão sobrevive a fechar o terminal, cair a conexão ou
reiniciar o app. Você volta com `work` e tudo está onde estava.

Junto vêm um `git review` com diff colorido e um painel opcional, onde você
põe os comandos que quiser ver sem sair do terminal.

Feito para macOS e zsh. Nada aqui é amarrado a uma linguagem ou a um serviço:
os projetos, os atalhos, os painéis e as cores são todos seus para trocar.

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
source ~/.zshrc
work
```

O kitty só pega a config nova ao reabrir, ou com <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>f5</kbd>.

Opções do instalador:

| Flag | O que faz |
|---|---|
| `--theme <nome>` | Escolhe um tema de `themes/` (padrão: `catppuccin-mocha`) |
| `--no-brew` | Não instala nada pelo Homebrew |
| `--dry-run` | Mostra o que faria, sem escrever nada |

O instalador é idempotente: rodar de novo atualiza em vez de duplicar. Tudo o
que ele escreve nos seus arquivos fica entre marcadores `# >>> workdeck >>>`,
e o `./uninstall.sh` remove exatamente esse trecho, deixando o resto intacto.

> **Já tem kitty ou tmux configurado?** Rode `./install.sh --dry-run` primeiro.
> O instalador só gerencia o que está entre os marcadores; se você já tem
> cores ou `map` definidos fora deles, os dois blocos vão coexistir e o último
> a ser lido vence. Nesse caso, remova a sua versão antiga antes.

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
painel|$HOME|tclock
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

Todos são <kbd>cmd</kbd>, como em qualquer app de Mac. O kitty manda o
equivalente do tmux.

| Atalho | Resultado |
|---|---|
| <kbd>cmd</kbd>+<kbd>t</kbd> | Nova janela, na pasta atual |
| <kbd>cmd</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | Vai direto para a janela N |
| <kbd>cmd</kbd>+<kbd>[</kbd> / <kbd>]</kbd> | Janela anterior / próxima |
| <kbd>cmd</kbd>+<kbd>d</kbd> | Divide lado a lado |
| <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>d</kbd> | Divide em cima/embaixo |
| <kbd>cmd</kbd>+<kbd>alt</kbd>+<kbd>setas</kbd> | Pula entre os painéis |
| <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>enter</kbd> | Zoom: o painel ocupa a janela |
| <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>w</kbd> | Fecha o painel |
| <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>r</kbd> | Renomeia a janela |
| <kbd>cmd</kbd>+<kbd>shift</kbd>+<kbd>e</kbd> | Solta a sessão (ela continua viva) |
| <kbd>cmd</kbd>+<kbd>b</kbd> | Prefixo cru, para o que não está mapeado |

**Para mudar um atalho**, edite `config/kitty.conf` e rode `./install.sh` de
novo. Cada linha é "manda o prefixo (`\x02`, que é Ctrl+b) e depois a tecla":

```
map cmd+shift+s send_text all \x02s    # cmd+shift+s abre a lista de sessões
```

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

Um painel é qualquer executável que imprima texto. O `tclock` (opcional) os
coloca na tela e os atualiza sozinho; fora dele, cada um funciona na linha de
comando como qualquer comando.

O projeto vem com um só, de propósito — ele serve mais como modelo do que
como funcionalidade:

| Script | Mostra |
|---|---|
| `painel-sistema` | Carga, swap e disco livre |

```bash
$ painel-sistema
carga 2.14 · swap 1.2G · disco livre 86Gi
```

Ele tem seis linhas. Vale abrir `bin/painel-sistema` antes de escrever o seu.

### Fazendo o seu

Qualquer coisa que você queira olhar de relance serve: containers rodando,
build quebrado, fila de deploy, tarefas do dia, o tempo, a cotação do dólar,
quantos commits você fez hoje. Escreva um executável que imprima texto, ponha
em `bin/`, rode `./install.sh` de novo e acrescente ao `config/tclock.toml`:

```toml
[[clock.widgets]]
title = "Containers"
group = "dev"
command = ["docker", "ps", "--format", "{{.Names}}  {{.Status}}"]
refresh_secs = 30
```

Não precisa nem ser um script — `command` aceita qualquer comando com
argumentos, como no exemplo acima.

Widgets com o mesmo `group` aparecem juntos; a tecla <kbd>g</kbd> alterna entre
os grupos. `refresh_secs` diz de quanto em quanto tempo redesenhar, e
`timeout_secs` desiste se o comando travar. Para uma visão maior sob demanda,
`popup_actions` cria uma tecla:

```toml
[[clock.widgets.popup_actions]]
key = "d"
label = "docker com detalhe"
command = ["docker", "ps", "-a"]
```

### Painéis que precisam de credenciais

Se o seu painel fala com uma API — um board, um CI, um serviço interno —, não
coloque token nem URL de organização dentro do script. Leia de um arquivo em
`~/.config/workdeck/`, que fica fora do repositório:

```bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/meu-painel.conf"
[ -f "$CONFIG" ] || { echo "configure primeiro: $CONFIG"; exit 1; }
. "$CONFIG"
```

Assim o painel pode ser versionado e compartilhado, e o que é seu continua
sendo seu. O `.gitignore` já ignora `*.conf` soltos por garantia.

---

## O painel visual (tclock)

**Esta é a única peça que o instalador não resolve.** O `tclock` é um relógio
de terminal com suporte a widgets que rodam comandos. Se você tiver o binário,
ponha em `~/.local/bin/tclock` e rode `./install.sh` de novo — ele cria a
config. Sem ele, todo o resto funciona; você perde só a janela do painel.

Dentro do painel: <kbd>g</kbd> troca de grupo, <kbd>t</kbd> abre a lista com
links, <kbd>Esc</kbd> fecha, <kbd>q</kbd> sai. Para redesenhar sem sair de onde
você está: `tclock run`.

Ele só tem duas alavancas de cor: `color`, um hex único, e `theme`. Não existe
cor por elemento.

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
~/.local/bin/                     work, git-review, painel-*
~/.config/workdeck/               projects.conf e o que seus painéis precisarem
~/.config/kitty/kitty.conf        bloco entre os marcadores
~/.tmux.conf                      bloco entre os marcadores
~/.zshrc                          bloco entre os marcadores
~/.config/git-review/lesskey      navegação dentro do diff
~/.config/tclock/config.toml      se o tclock existir
```

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
| Um atalho do teclado | `config/kitty.conf` | `./install.sh` |
| Um comportamento do tmux | `config/tmux.conf` | `./install.sh` |
| As cores | `themes/<nome>.conf` e `.tmux` | `./install.sh --theme <nome>` |
| O que aparece no painel | `config/tclock.toml` | `tclock run` |
| A branch base do `git review` | `bin/git-review`, em `base_candidates` | `./install.sh` |
| O nome da sessão | `export WORKDECK_SESSION=outro` | — |
| Algo que não existe aqui | escreva em `bin/` | `./install.sh` |

Qualquer executável que você puser em `bin/` vai para o `PATH` no próximo
`install.sh`. É assim que o `work`, o `git-review` e o `painel-sistema`
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
