[English](review.md) · **Português**

# Self code review

Um review antes do commit. O `work review` abre um painel separado, embaixo do
chat da sua IA, com um agente que começa do zero: ele lê só a mudança e o código
em volta, e não a conversa que escreveu o código.

```bash
work review            # o que ainda não foi commitado, ou os commits que ainda não subiram
work review branch     # tudo o que a branch mudou em relação à principal
work review staged     # só o que está no stage (git add)
work review --chat     # o review rápido, no chat que você já está usando
```

No kitty, <kbd>⌘</kbd>+<kbd>R</kbd> roda o `work review`, e o menu também tem.

## Por que um painel separado

Um review no mesmo chat divide a conversa e o modelo com quem escreveu o código,
então tende a concordar com as escolhas já feitas e a deixar passar as mesmas
coisas. No painel separado, o revisor começa limpo e, com o `REVIEW_AGENT_CMD`,
pode até ser outro modelo ou outra IA:

```bash
REVIEW_AGENT_CMD="claude --model opus"
```

O custo é um passo: você leva os achados de volta ao chat do agente para
corrigir. Numa mudança pequena, em que a rapidez pesa mais, o
`work review --chat` faz o review no chat que você está usando.

## O painel separado

O `work review` abre o pedido de review do workdeck num painel embaixo do chat
da sua IA (ou do painel em que você está). Rodar de novo manda o pedido para o
mesmo painel.

A resposta é uma lista curta, uma bolinha por achado, no idioma que você
escolheu na instalação:

```
Usei: roteiro padrão

🔴 src/api/pedidos.ts:42 — o token vai inteiro para o log
   → logar só o id do usuário
🟠 src/lista.tsx:18 — uma consulta por item dentro do map
   → buscar todos de uma vez antes do map
🟢 os testes cobrem o caso novo

🔴 corrija os vermelhos antes do commit
```

| | Quer dizer | O que fazer |
|---|---|---|
| 🔴 | Bug: quebra, perde dado, abre falha de segurança ou não faz o que a mudança promete | Corrigir antes do commit |
| 🟠 | Atenção: funciona, mas é arriscado, lento, sem teste ou sobra | Vale corrigir; pode ficar para depois |
| 🟢 | Ok: o que foi conferido e está certo | Nada |

A última linha é o veredito: 🟢 pode commitar, 🟠 pode commitar e deixar os
laranjas para depois, ou 🔴 corrigir os vermelhos antes.

Com o `claude`, cada branch tem uma sessão de review só no painel: o
`work review` retoma a mesma conversa (`claude --resume`) em vez de criar uma
por vez. Com `claude`, `codex` e `gemini`, o pedido entra direto na conversa.
Com outra IA, ele vai para a área de transferência e para
`~/.cache/workdeck/review-request.md`, para colar.

Qual IA o review usa: a do `REVIEW_AGENT_CMD` no `~/.config/workdeck/settings.conf`,
quando definido. Senão, a que estiver aberta na janela e, se não houver nenhuma,
a encontrada na instalação, guardada como `AGENT_CMD`.

## O seu comando de review

Para usar o review de um método como o
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD) ou uma skill sua, defina o
comando numa linha `REVIEW_COMMAND`:

```bash
REVIEW_COMMAND="/bmad-code-review"
```

- em `.workdeck/review.conf` dentro do projeto, só para aquele projeto;
- em `~/.config/workdeck/settings.conf`, para todos.

O comando vira a primeira mensagem do agente no painel separado, no lugar do
pedido do workdeck. Com `--chat`, ele é colado no chat que você está usando. O
arquivo do projeto vale mais, mas só aceita um comando de barra sem argumentos,
como `/bmad-code-review`: um repositório que você clonou não consegue pôr
instruções no seu agente. O seu `settings.conf` aceita qualquer texto, como
`/code-review high`. Os arquivos são lidos, não executados, com as mesmas regras
do `settings.conf`.

## O review no chat

O `work review --chat` manda o review para o agente aberto na janela: o seu
`REVIEW_COMMAND`, ou o `/code-review` no Claude Code (`/code-review main...HEAD`
com `branch`). No Claude Code, ele lê a tela do chat antes:

| O chat do Claude | O que o `work review --chat` faz |
|---|---|
| Parado, com o campo vazio | Manda o comando e o review começa na hora |
| Ainda trabalhando | Não manda nada e pede para rodar de novo quando o Claude terminar |
| Com uma pergunta, como um pedido de permissão | Não manda nada, para nunca responder a pergunta por você |
| Com uma mensagem que você estava digitando | Não manda nada, para nunca enviar a sua mensagem pela metade |

Com outro agente, ele cola o comando sem apertar Enter: confira o chat e aperte
Enter você mesmo. Quando o chat não pode receber o review (sem agente aberto,
`staged` ou com o `REVIEW_AGENT_CMD` definido), ele cai no painel separado.

## Instruções extras

Para acrescentar algo ao pedido de review do workdeck, como a branch base ou a
skill preferida, escreva em:

- `~/.config/workdeck/review.md`, vale para todos os projetos;
- `.workdeck/review.md` dentro do projeto, vale só nele.

O texto vai no fim do pedido e tem prioridade sobre as instruções padrão. Ele
só vale para o painel separado: o `/code-review` segue o `CLAUDE.md` do
projeto, então ponha as regras dele lá.

O review do painel separado vem do passo de revisão do
[ponytail](https://github.com/dietrichgebert/ponytail).
