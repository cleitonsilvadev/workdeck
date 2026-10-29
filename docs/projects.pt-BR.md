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

## Três painéis por projeto

Por padrão, a janela de cada projeto abre com um shell só. Para ela já abrir
dividida entre o agente, o servidor e um shell livre, acrescente ao
`~/.config/workdeck/settings.conf`:

```
PROJECT_LAYOUT="agent-server-shell"
```

```
┌──────────────┬──────────────┐
│              │ 2 servidor   │
│  1 agente    │              │
│              ├──────────────┤
│              │ 3 shell      │
└──────────────┴──────────────┘
```

- **1, o agente:** o comando guardado em `AGENT_CMD` (como `claude`) aparece
  digitado, sem rodar. Aperte Enter nos projetos em que for trabalhar. Sem
  `AGENT_CMD`, o painel abre como um shell comum.
- **2, o servidor:** o comando do `.workdeck/project.conf` do projeto aparece
  digitado, também sem rodar:

  ```
  SERVER_COMMAND="npm run dev"
  ```

  O arquivo segue as mesmas regras do `settings.conf`: uma `CHAVE="valor"` por
  linha, com comentários em linhas próprias. Uma linha em outro formato, como
  uma com comentário depois do valor, é ignorada. Caracteres de controle são
  removidos antes de digitar, então um valor nunca roda sozinho. Sem esse
  arquivo, o painel abre como um shell comum.
- **3, um shell livre** para git, testes e o que mais precisar.

Os comandos são digitados quando o shell mostra o prompt. Nada sobe sozinho,
então abrir muitos projetos não liga vários agentes nem
servidores ao mesmo tempo, e as portas não entram em conflito. A divisão vale
para as janelas abertas depois de ligar: rode `work kill` e `work`, ou
acrescente um projeto com `work add`. Depois, <kbd>Ctrl</kbd>+<kbd>b</kbd>
<kbd>Enter</kbd> acrescenta um quarto painel embaixo do agente, fechando a grade.

## Outra sessão

Para usar outro nome de sessão: `export WORKDECK_SESSION=outro`.
