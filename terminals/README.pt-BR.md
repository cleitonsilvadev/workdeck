[English](README.md) · **Português**

# Terminais

A única dependência é o tmux, então o `work`, o painel e os atalhos funcionam
igual em qualquer terminal. O que muda de um terminal para outro são os extras:
as cores, a fonte e os atalhos próprios dele.

A instalação pergunta quais terminais você usa (kitty, iTerm2 no Mac, Warp ou o
terminal padrão, que cobre o do sistema e qualquer outro; dá para escolher mais
de um) e configura os extras que cada um aceita.
**Ela não instala terminal:** se o escolhido faltar, grava a configuração mesmo
assim e diz onde baixar, para o terminal já abrir pronto quando você instalar.
Para responder sem a pergunta, use `--terminal kitty`, `--terminal kitty,iterm`,
`--terminal warp` ou `--terminal other`; a escolha fica salva em
`~/.config/workdeck/settings.conf` (`TERMINAL`).

No kitty e no Warp, uma segunda pergunta oferece o **visual** do workdeck: o
tema e a fonte JetBrains Mono, baixada das releases oficiais, sem sudo. A
resposta padrão é não (Enter recusa). `--visual` aceita sem perguntar e
`--no-visual` recusa; a resposta fica em `~/.config/workdeck/settings.conf` (`VISUAL`).

## kitty

Com o kitty escolhido, a instalação acrescenta um bloco ao seu
`~/.config/kitty/kitty.conf`, mesmo antes de o kitty estar instalado, com:

- **Os atalhos do workdeck**, <kbd>⌘</kbd> no Mac e
  <kbd>Ctrl</kbd>+<kbd>Shift</kbd> no Linux: H menu, P adicionar projeto, 1…9
  ir para o projeto, A agente, T terminal, Z zoom,
  W fechar, R review. A tabela completa está em
  [docs/shortcuts.pt-BR.md](../docs/shortcuts.pt-BR.md).
- **Option como Alt** no Mac, para os atalhos diretos com Alt.
- **Shift+Enter** é enviado no formato estendido, para que agentes como o
  Claude Code pulem a linha em vez de enviar a mensagem. Só vale enquanto o
  tmux roda na janela, então um shell comum não é afetado.

Se você aceitar o visual, o mesmo bloco ganha também:

- **Tema** do workdeck (`--theme`), o mesmo da barra do tmux.
- **Fonte** JetBrains Mono, com espaçamento de linha um pouco maior.
- **Margem** de 8 pontos entre o texto e a borda da janela. Com o tema, o fundo
  do kitty tem a cor do fundo do tmux, e a margem se mistura a ele.

Sem o visual, o kitty fica com o tema e a fonte dele. Se uma versão antiga do
workdeck já tinha posto o tema e a fonte no seu `kitty.conf`, a atualização
mantém os dois e salva isso como a sua escolha.

A instalação encontra o kitty em `/Applications` ou `~/Applications` (Mac), em
`~/.local/kitty.app` (Linux) ou no `PATH`. O que você escreveu fora dos
marcadores `# >>> workdeck >>>` não muda, e o desinstalador tira só o bloco. O
kitty continua instalado.

## iTerm2

No Mac, com o iTerm2 escolhido, a instalação grava um profile **workdeck** em
`~/Library/Application Support/iTerm2/DynamicProfiles/workdeck.json`, mesmo
antes de o iTerm2 estar instalado. Ele tem os mesmos atalhos do workdeck do
kitty, com <kbd>⌘</kbd>, e a Option esquerda como Meta para os atalhos Alt.

O iTerm2 não troca de profile sozinho. Escolha uma vez em Settings › Profiles ›
workdeck › Other Actions › Set as Default; a instalação lembra disso no fim. O
`work uninstall` remove o profile, a não ser que você o tenha editado.

## Warp

Com o [Warp](https://www.warp.dev/) escolhido, a instalação confere se ele está
instalado. O `work` abre e o tmux faz o resto: os atalhos `Alt` e a barra valem
normalmente. O painel reconhece o Warp pela variável `WARP_CLIENT_VERSION`.

Se você aceitar o visual, a instalação copia o tema para a pasta de temas do
Warp e baixa a fonte JetBrains Mono:

| Sistema | Onde o tema fica |
|---|---|
| macOS | `~/.warp/themes/workdeck-<tema>.yaml` |
| Linux | `~/.local/share/warp-terminal/themes/workdeck-<tema>.yaml` |

O Warp não troca de tema nem de fonte por arquivo, então o último passo é seu:

- **Tema.** Em **Settings › Appearance › Themes**, escolha `workdeck <tema>`.
  Também dá para buscar "Open theme picker" na Command Palette. O Warp pode levar
  alguns minutos para notar a pasta nova; reabrir o app resolve.
- **Fonte.** Em **Settings › Appearance › Text › Font type**, escolha JetBrains
  Mono.
- **Option como Alt (só no Mac).** Os atalhos `Alt` do tmux (`Alt+1…9`,
  `Alt+↑/↓`) só funcionam se a Option for tratada como Alt. Em
  **Settings › Features**, ligue **Left Option key is Meta**. A instalação não liga
  isso por você, porque o Warp guarda essa opção no `settings.toml` dele e o
  reescreve.

O que **não** vem para o Warp: os atalhos do workdeck. O `keybindings.yaml` do Warp só
liga teclas a ações do próprio Warp e não tem uma ação de enviar texto, que é o
que traduz os atalhos do workdeck para teclas do tmux. No Warp, use
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> para o menu.

O `work uninstall` remove o tema copiado, a não ser que você o tenha editado.

Se você abrir de outro terminal uma sessão do tmux iniciada no Warp, a variável
`WARP_CLIENT_VERSION` continua no ambiente do tmux e o painel mostra o aviso do
Warp.

## Terminal padrão

Ghostty, WezTerm, o terminal que vem no sistema ou uma conexão por SSH: o `work`
abre do mesmo jeito, com os atalhos do tmux (<kbd>Ctrl</kbd>+<kbd>b</kbd>
<kbd>h</kbd> para o menu, <kbd>Shift</kbd>+setas para navegar). No Mac, ligue a
Option como Meta nas configurações do terminal para usar os atalhos Alt. O tema
e a fonte, se você quiser, são configurados no próprio terminal.
