[English](panels.md) · **Português**

# Painéis

O painel é a janela 1 da sessão: a visão geral do seu work em cima e um
terminal de 8 linhas embaixo para digitar. Sem nenhum projeto, o `work` abre só
com ele, mostrando o que falta fazer, e um `work add` digitado ali já cria a
janela.

O que aparece em cima é montado a partir de uma pasta:

```
~/.config/workdeck/panels/
├── 00-workdeck     o logo, a versão e o que falta configurar
├── 20-projetos     a branch e as mudanças de cada projeto
└── 30-docker       ← o seu
```

Cada arquivo é um programa. O painel roda todos, em ordem alfabética, e mostra
o que cada um imprime, um embaixo do outro. A cada 60 segundos, roda tudo de
novo. Personalizar o painel é criar, editar ou desligar arquivos nessa pasta.

## Criar o seu, passo a passo

Um painel com os commits que você fez hoje em cada projeto:

**1. Crie o arquivo.** O nome vira o título e define a posição: `30-` fica
depois dos dois que vêm prontos.

```bash
cat > ~/.config/workdeck/panels/30-commits-de-hoje <<'PANEL'
#!/usr/bin/env bash
while IFS='|' read -r name path _; do
  path="${path/#\~/$HOME}"; path="${path/#\$HOME/$HOME}"
  [ -d "$path/.git" ] || continue
  n=$(git -C "$path" log --oneline --since=midnight --author="$(git config user.email)" | wc -l | tr -d ' ')
  [ "$n" -gt 0 ] && echo "$name  $n commit(s)"
done < ~/.config/workdeck/projects.conf
PANEL
```

**2. Torne executável.** Sem isso, ele não aparece: um arquivo sem permissão
de execução é um painel desligado.

```bash
chmod +x ~/.config/workdeck/panels/30-commits-de-hoje
```

**3. Teste fora do painel.** Rode o arquivo direto, no terminal, e veja se a
saída é a que você quer:

```bash
~/.config/workdeck/panels/30-commits-de-hoje
```

**4. Pronto.** Não precisa reinstalar nem reiniciar: no próximo ciclo ele
aparece no painel, com o título "Commits de hoje".

## As regras

- **Qualquer linguagem.** Bash, Python, Node, um binário: basta ser executável
  e imprimir texto. Com Python, comece o arquivo com `#!/usr/bin/env python3`.
- **O nome é o título.** O prefixo numérico some e os hífens viram espaços:
  `30-commits-de-hoje` aparece como "Commits de hoje". Os que começam com `00-`
  aparecem sem título.
- **A ordem é alfabética.** Use o prefixo para ordenar: `10-`, `20-`, `30-`.
- **Cores funcionam.** Códigos ANSI passam direto, como em
  `printf '\033[32m✓\033[0m tudo certo\n'`.
- **Seja rápido.** Os painéis rodam um depois do outro, e o painel só se
  redesenha quando todos terminam. Um comando que demora 10 segundos atrasa
  tudo. Para algo lento, como uma API, guarde o resultado num arquivo e
  atualize só de vez em quando.
- **Erros aparecem.** O que o programa escreve no stderr também vai para o
  painel, o que ajuda a descobrir por que ele quebrou.

## Ideias

| Painel | Comando principal |
|---|---|
| Containers rodando | `docker ps --format '{{.Names}}  {{.Status}}'` |
| Pull requests abertos | `gh pr list --author @me` |
| Último build do CI | `gh run list --limit 3` |
| Portas em uso | `lsof -iTCP -sTCP:LISTEN -P \| awk 'NR>1 {print $1, $9}'` |
| Espaço em disco | `df -h / \| tail -1` |
| Tarefas do dia | `cat ~/notas/hoje.md` |

## Mudar os que vêm prontos

**Desligar.** Tire a permissão de execução. O painel deixa de mostrar, e o
`work update` respeita: não liga de novo.

```bash
chmod -x ~/.config/workdeck/panels/20-projetos
```

Para religar, `chmod +x`. Apagar o arquivo não adianta: a próxima atualização
cria de novo.

**Editar.** Pode mexer à vontade. Um painel padrão que você editou nunca é
sobrescrito pelo `work update`; os que você não mexeu recebem as melhorias das
versões novas.

## Mudar o intervalo

O padrão é 60 segundos. Para outro valor, ponha os segundos no fim da linha do
painel no `~/.config/workdeck/projects.conf`:

```
painel|~|work-panel 30
```

Depois, `work kill` e `work` para aplicar. Dentro do painel, <kbd>q</kbd> sai.

## O painel com relógio: tclock

O [tclock](https://github.com/akitaonrails/clock-tui), o fork do clock-tui
mantido pelo Fabio Akita, pode ser o painel: um relógio grande no alto e cada
bloco do painel embaixo como widget, com as cores, atualizado no mesmo
intervalo. O bloco do workdeck, com o logo e a versão, vem primeiro.

A instalação pergunta se você quer (`--clock` responde sim, `--no-clock` não) e
guarda `PANEL_CLOCK` no `settings.conf`. No Linux, ela baixa o binário do
release e confere o sha256; no Mac, compila com o `cargo`, então precisa do Rust
(`brew install rust`). Sem o tclock, o painel continua no modo de texto.

O workdeck guarda a configuração dele do tclock em `~/.config/workdeck/tclock/`,
então uma configuração sua do tclock não é tocada. Dentro do relógio,
<kbd>z</kbd> esconde os blocos e <kbd>q</kbd> sai. O `work uninstall` remove o
tclock só se foi o workdeck que instalou.

## Painéis que precisam de credenciais

Se o painel fala com uma API — um board, um CI, um serviço interno —, não
coloque token nem URL no script. Leia de um arquivo em `~/.config/workdeck/`:

```bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/meu-painel.conf"
[ -f "$CONFIG" ] || { echo "configure primeiro: $CONFIG"; exit 1; }
. "$CONFIG"
```

Assim o painel pode ser compartilhado e as credenciais continuam só suas.
