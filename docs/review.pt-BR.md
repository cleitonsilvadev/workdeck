[English](review.md) · **Português**

# Self code review

Um review antes do commit. O `work review` pede ao agente que você já tem aberto
uma revisão da mudança, usando o melhor review que ele tiver.

```bash
work review            # o que ainda não foi commitado (no Claude Code, também os commits da branch que ainda não subiram)
work review branch     # tudo o que a branch mudou em relação à principal
work review staged     # só o que está no stage (git add), no painel separado
work review --pane     # força o painel separado, descrito abaixo
```

## Qual review roda

O `work review` procura o agente aberto num painel da janela atual e usa a
primeira opção que se aplica:

| | Quando | O que acontece |
|---|---|---|
| 1 | O projeto ou a sua config define um comando de review | Esse comando é colado no chat do agente |
| 2 | O agente é o Claude Code | O `/code-review` é colado no chat; o `work review branch` cola `/code-review main...HEAD` |
| 3 | Qualquer outro caso | O pedido de review do workdeck abre numa janela própria |

Nos casos 1 e 2, o review roda no chat que você já está usando, e o agente que
escreveu o código está ali para corrigir o que aparecer. O Claude Code roda o
`/code-review` como um subagente em segundo plano, com contexto próprio, então
o review não herda a conversa que escreveu o código. Os achados chegam no chat
quando ele termina.

O review é para quando o agente terminou. No Claude Code, o `work review` lê a
tela do chat antes:

| O chat do Claude | O que o `work review` faz |
|---|---|
| Parado, com o campo vazio | Manda o comando e o review começa na hora |
| Ainda trabalhando | Não manda nada e pede para rodar de novo quando o Claude terminar |
| Com uma pergunta aberta, como um pedido de permissão | Não manda nada, para nunca responder a pergunta por você |
| Com uma mensagem sua pela metade | Não manda nada, para nunca enviar a sua mensagem incompleta |

Com qualquer outro agente, o `work review` cola o comando sem apertar Enter:
confira no chat e aperte Enter você.

Sem nada por commitar, o `work review` ainda manda o `/code-review` para o
Claude quando a branch tem commits que não subiram, porque esse review cobre
esses commits. O painel separado só revisa o que não foi commitado.

## O seu comando de review

Para usar o review de um método como o
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD) ou de uma skill sua, defina
o comando numa linha `REVIEW_COMMAND`:

```bash
REVIEW_COMMAND="/bmad-code-review"
```

- em `.workdeck/review.conf` dentro do projeto, vale só nele;
- em `~/.config/workdeck/settings.conf`, vale para todos os projetos.

O arquivo do projeto tem prioridade, mas só aceita um comando de barra sem
argumentos, como `/bmad-code-review`: um repositório que você clonou não
consegue pôr instruções no chat do seu agente. O seu `settings.conf` aceita
qualquer texto, como `/code-review high`. O comando é colado como está, seja
qual for o recorte do `work review`, em qualquer agente aberto na janela; o
`work review staged` sempre usa o painel separado. Os arquivos são lidos, não executados, com as mesmas regras do `settings.conf`:
vale a primeira linha `REVIEW_COMMAND="…"`, e linhas em outro formato são
ignoradas.

## O painel separado

Com `--pane`, com `staged`, com o `REVIEW_AGENT_CMD` definido, ou quando nenhuma
opção acima se aplica, o `work review` abre o pedido de review do workdeck numa
janela própria, chamada `review: <projeto>`, logo depois da janela do projeto. A
janela do projeto continua com os painéis como estão. Rodar de novo manda o
pedido para a mesma janela.

A resposta é uma lista curta, uma bolinha por achado:

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
a escolhida na instalação, guardada como `AGENT_CMD`.

Outro modelo ou outra IA no review evita repetir os pontos cegos de quem escreveu
o código: agentes do mesmo modelo tendem a errar do mesmo jeito e a concordar
entre si. Com ele definido, todo `work review` roda numa janela própria com esse
agente, mesmo com o Claude Code aberto:

```bash
REVIEW_AGENT_CMD="claude --model opus"
```

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
