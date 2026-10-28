# Self code review

Um review antes do commit: a sua IA lê a mudança e o código em volta e revisa
como a pessoa sênior que vai ser chamada se aquilo quebrar.

```bash
work review            # o que ainda não foi commitado
work review staged     # só o que está no stage (git add)
work review branch     # tudo o que a branch mudou em relação à principal
```

## O que ela procura

Bugs, falhas de segurança e segredos, código arriscado sem teste, trechos
lentos, o que dá para cortar e arquivos fora do escopo. Cada achado vem com:

- a gravidade — corrigir antes do commit, vale corrigir ou opcional;
- o que o código faz e o que dá errado;
- como corrigir e o que acontece se não corrigir.

No fim, um veredito. A IA não altera nada: só revisa.

## Onde ele roda

O review abre num painel embaixo do chat da sua IA (ou do painel em que você
está), separado da conversa que escreveu o código. Rodar de novo manda o pedido
para o mesmo painel.

Com o `claude`, cada branch tem uma sessão de review só: o `work review` retoma
a mesma conversa (`claude --resume`) em vez de criar uma por vez, e o `/resume`
não enche de reviews. Na conversa retomada, a IA diz o que da revisão anterior
foi corrigido e o que continua.

Com `claude`, `codex` e `gemini`, o pedido entra direto na conversa. Com outra
IA, ele vai para a área de transferência e para
`~/.cache/workdeck/pedido-de-review.md`, para colar.

Qual IA é usada: a que estiver aberta num painel da janela. Se não houver
nenhuma, a escolhida na instalação, guardada em `~/.config/workdeck/agent.conf`.

## O seu fluxo de review

O pedido manda a IA usar o agente de review e os PRDs ou stories que as
instruções dela apontam (`CLAUDE.md`, `AGENTS.md`, skills) — como um
`bmad-code-review` ou uma skill própria de review de PR — e dizer na primeira
linha qual usou. Se o framework fica fora do projeto, num repositório do time,
por exemplo, diga onde nas instruções da IA: assim ele vale também quando a
revisão é pedida direto, sem o workdeck.

## Personalizar

Para acrescentar algo a todo review, como a branch base ou a skill preferida,
escreva em:

- `~/.config/workdeck/review.md` — vale para todos os projetos;
- `.workdeck/review.md` dentro do projeto — vale só nele.

O texto vai no fim do pedido e tem prioridade sobre as instruções padrão.

A ideia vem do passo de revisão do
[ponytail](https://github.com/dietrichgebert/ponytail).
