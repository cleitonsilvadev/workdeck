# kitty

O workdeck requer o [kitty](https://sw.kovidgoyal.net/kitty/), que roda no macOS e
no Linux. A instalação baixa o kitty pelo instalador oficial, sem sudo, e
acrescenta o bloco de `kitty.conf` ao seu `~/.config/kitty/kitty.conf`:

- **Tema** do workdeck (`--theme`), o mesmo da barra do tmux.
- **Fonte** JetBrains Mono, com espaçamento de linha um pouco maior.
- **Option como Alt** no Mac, para os atalhos diretos com Alt.
- **cmd** no Mac: `cmd+h` abre o menu, `cmd+enter` divide a tela, `cmd+1…9`
  vai para a janela, `cmd+d` / `cmd+shift+d` divide ao lado / embaixo,
  `cmd+shift+enter` dá zoom, `cmd+shift+w` fecha o painel.

| Sistema | Onde o kitty fica |
|---|---|
| macOS | `~/Applications/kitty.app` |
| Linux | `~/.local/kitty.app`, com `kitty` em `~/.local/bin` e o atalho no menu de aplicativos |

Se você já tem o kitty, a instalação usa o seu e só acrescenta o bloco. O que
você escreveu fora dos marcadores `# >>> workdeck >>>` não muda, e o
desinstalador tira só o bloco. O kitty continua instalado.

**Outro terminal** (por SSH, no terminal do editor) também abre o `work`, porque
os atalhos são do tmux, e o painel avisa que você está fora do kitty. O visual e
os atalhos `cmd` só são garantidos no kitty.
