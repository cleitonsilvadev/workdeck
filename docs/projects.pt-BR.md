[English](projects.md) · **Português**

# Projetos

Cada projeto é uma janela da sessão do tmux. O `work` abre todas de uma vez, e
a sessão sobrevive a fechar o terminal ou cair a conexão: `work` de novo e tudo
está onde estava, agente incluso. Reiniciar a máquina fecha a sessão; o `work`
abre as janelas dos projetos de novo, e o agente você abre outra vez.

## Adicionar

```bash
work add ~/code/api        # Tab completa o caminho
work add                   # sem caminho, usa a pasta atual
```

O nome da janela é o nome da pasta. Com a sessão aberta, a janela aparece na
hora; se a pasta já estiver no work, nada muda. Pelo menu
(<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd>), "Adicionar um projeto…" faz o
mesmo.

## Tirar

Feche a janela do projeto: `exit` no último painel, ou
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd>. Ele sai da lista, e o próximo `work`
não abre mais. Fechar só um dos painéis divididos, ou o agente, não tira nada.
Para voltar, `work add` de novo.

## O `projects.conf`

Os projetos ficam em `~/.config/workdeck/projects.conf`, uma linha por janela:

```
nome|caminho|comando opcional
```

```
painel|$HOME|work-panel
api|$HOME/projetos/minha-api
web|$HOME/projetos/meu-front
notas|~/notas
```

- **nome** vira o nome da janela no tmux.
- **caminho** é onde a janela abre; aceita `~` e `$HOME`.
- **comando** é opcional: se existir, a janela roda isso em vez de um shell.

A ordem do arquivo é a ordem das janelas, numeradas a partir de 1. Projeto que
não existe no disco é pulado sem erro, então dá para deixar linhas de coisas
que ainda não foram clonadas.

Para reordenar, edite o arquivo, feche a sessão com `work kill` e abra de novo
com `work`. As janelas são criadas na abertura da sessão; sem fechar, a sessão
continua com a lista antiga.

## Outra sessão

Para usar outro nome de sessão: `export WORKDECK_SESSION=outro`.
