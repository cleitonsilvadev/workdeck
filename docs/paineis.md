# Painéis

O painel é a janela 1 da sessão: a visão geral do seu work em cima e um
terminal de 8 linhas embaixo para digitar. Sem nenhum projeto, o `work` abre só
com ele, mostrando o que falta fazer, e um `work add` digitado ali já cria a
janela.

Ele mostra a saída de vários comandos e se atualiza sozinho a cada 60 segundos.
Para outro intervalo, ponha os segundos no fim da linha dele no
`projects.conf`, como em `painel|~|work-panel 30`. Dentro dele, <kbd>q</kbd>
sai.

## Os que vêm prontos

| Arquivo | Mostra |
|---|---|
| `00-workdeck` | O logo, a versão, quantos projetos e qual agente, e o que falta configurar |
| `20-projetos` | Cada projeto, a branch e se há mudança (`●`) ou está limpo (`✓`) |

```
Projetos
  api            main                 ✓ limpo
  web            feature/login        ● 6 alterado(s)
```

## Fazendo o seu

Cada bloco é um **executável** em `~/.config/workdeck/panels/`. Qualquer coisa
que imprima texto serve: containers rodando, build quebrado, fila de deploy,
tarefas do dia, quantos commits você fez hoje.

```bash
cat > ~/.config/workdeck/panels/30-docker <<'PAINEL'
#!/usr/bin/env bash
docker ps --format '{{.Names}}  {{.Status}}'
PAINEL
chmod +x ~/.config/workdeck/panels/30-docker
```

- O nome do arquivo vira o título; `30-docker` aparece como "Docker".
- A ordem é alfabética: use um prefixo numérico para ordenar.
- Os que começam com `00-` aparecem sem título.
- Não precisa reinstalar nem reiniciar: o painel relê a pasta a cada ciclo.
- Esqueceu o `chmod +x`? Ele avisa.

Os painéis que vêm com o workdeck são atualizados pelo `work update`; um painel
que você editou ou criou nunca é sobrescrito.

## Painéis que precisam de credenciais

Se o painel fala com uma API — um board, um CI, um serviço interno —, não
coloque token nem URL no script. Leia de um arquivo em `~/.config/workdeck/`:

```bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/meu-painel.conf"
[ -f "$CONFIG" ] || { echo "configure primeiro: $CONFIG"; exit 1; }
. "$CONFIG"
```

Assim o painel pode ser compartilhado e as credenciais continuam só suas.
