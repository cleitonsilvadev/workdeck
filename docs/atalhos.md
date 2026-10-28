# Atalhos

## O dia a dia

| Para | Teclas |
|---|---|
| **Abrir o menu** (projetos, review, dividir…) | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Projeto anterior / próximo | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Ir direto para a janela N | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>1</kbd>…<kbd>9</kbd> |
| Dividir a tela (ao lado ou embaixo, onde couber) | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> |
| Escolher o sentido: ao lado / embaixo | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>v</kbd> / <kbd>-</kbd> |
| Painel anterior / próximo | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Zoom no painel, e de novo para voltar | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>z</kbd> |
| Fechar o painel | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd> |
| Sair e deixar a sessão rodando | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd> |

<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> quer dizer: aperte
<kbd>Ctrl</kbd>+<kbd>b</kbd>, solte, e depois a tecla. O mouse também funciona:
clique na janela na barra de baixo, ou num painel, e arraste a borda para mudar
o tamanho.

No menu, cada projeto tem o número da janela como tecla (apertar <kbd>2</kbd>
vai direto para o segundo). <kbd>q</kbd> ou <kbd>Esc</kbd> fecha o menu.

Só as teclas do workdeck funcionam depois do <kbd>Ctrl</kbd>+<kbd>b</kbd>; uma
fora da lista mostra "tecla sem uso no workdeck — Ctrl+b h abre o menu".

## Atalhos de uma tecla, com Alt

- <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> vai para a janela.
- <kbd>Alt</kbd>+setas troca de painel.
- <kbd>Alt</kbd>+<kbd>Shift</kbd>+letra faz as ações: <kbd>D</kbd> divide ao
  lado, <kbd>S</kbd> embaixo, <kbd>Z</kbd> zoom, <kbd>X</kbd> fecha,
  <kbd>T</kbd> abre uma janela, <kbd>R</kbd> renomeia a janela, <kbd>E</kbd> sai
  da sessão sem fechar.

No kitty do workdeck eles funcionam de cara, inclusive no Mac, onde a Option já
age como Alt. As ações usam Shift porque `Alt`+letra minúscula é do readline
(andar e apagar palavras na linha de comando).

## O kitty

O kitty é o terminal do workdeck, e a instalação deixa ele pronto: tema, fonte
JetBrains Mono, a Option do Mac como Alt e, no Mac, atalhos em `cmd`
(`cmd+1…9` vai para a janela, `cmd+d` divide ao lado, `cmd+h` abre o menu). A
lista completa está em [terminals/README.md](../terminals/README.md).

Em outro terminal, ou por SSH, o `work` abre do mesmo
jeito, porque os atalhos são do tmux, e o painel avisa que você está fora do
kitty. O visual e os atalhos `cmd`, porém, só são garantidos no kitty.

## Criar ou trocar um atalho

Ponha o `bind` no seu `~/.tmux.conf`, **depois** do bloco do workdeck: o que
estiver antes é desligado junto com os atalhos padrão do tmux, e o bloco é
reescrito a cada atualização.

```tmux
bind -n M-S-G new-window -c "#{pane_current_path}" lazygit
```

Depois, <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> recarrega a configuração.
