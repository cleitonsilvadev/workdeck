[English](customizing.md) · **Português**

# Customizando

Quase tudo no workdeck é para ser trocado.

| Para mudar | Onde | Depois |
|---|---|---|
| Os projetos e a ordem das janelas | `~/.config/workdeck/projects.conf` | `work kill` e `work` |
| Um atalho do teclado | o seu `~/.tmux.conf`, depois do bloco do workdeck | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> |
| Os atalhos `cmd` e o visual do kitty | o seu `kitty.conf`, fora do bloco do workdeck | reabra o kitty |
| As cores | a instalação com `--theme <nome>` | — |
| O que aparece no painel | `~/.config/workdeck/panels/` | nada, ele relê sozinho |
| O que todo review pede | `~/.config/workdeck/review.pt-BR.md` ou `.workdeck/review.pt-BR.md` | — |
| O tema do oh-my-zsh | `export WORKDECK_ZSH_THEME=<tema>` no `.zshrc` | reabra o terminal |
| O nome da sessão | `export WORKDECK_SESSION=outro` | — |
| Algo que não existe aqui | um fork, com o seu comando no `bin/work` | `./install.sh` no fork |

O instalador só gerencia o que está entre os marcadores `# >>> workdeck >>>`;
o resto dos seus arquivos continua seu. O que você puser fora desses blocos
sobrevive a atualizações.

## Mantendo a sua versão

Só o `work` vai para o `PATH`. Os outros scripts de `bin/` são peças internas,
chamadas de dentro da instalação em `~/.local/share/workdeck`.

Para ir além da configuração, faça um fork, mude o que quiser e rode o
`./install.sh` de dentro dele. O instalador copia o seu fork para
`~/.local/share/workdeck` e o `work update` passa a seguir as versões dele.
