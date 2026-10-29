**English** · [Português](review.pt-BR.md)

# Self code review

A review before the commit. `work review` asks the agent you already have open
to review the change, using the best review available to it.

```bash
work review            # what is not committed yet (with Claude Code, also the branch commits not pushed yet)
work review branch     # everything the branch changed compared to the main branch
work review staged     # only what is staged (git add), in the separate pane
work review --pane     # forces the separate pane, described below
```

## Which review runs

`work review` looks for the agent open in a pane of the current window and
picks the first option that applies:

| | When | What happens |
|---|---|---|
| 1 | The project or your config sets a review command | That command is pasted into the agent chat |
| 2 | The agent is Claude Code | `/code-review` is pasted into the chat; `work review branch` pastes `/code-review main...HEAD` |
| 3 | Any other case | The workdeck review request opens in a separate pane |

In cases 1 and 2 the review runs in the chat you are already using, so the
agent that wrote the code is right there to fix what the review finds. Claude
Code runs `/code-review` as a background subagent with its own context, so the
review does not inherit the conversation that wrote the code. Its findings show
up in the chat when it finishes.

The review is meant for when the agent has finished. With Claude Code,
`work review` reads the chat screen first:

| The Claude chat | What `work review` does |
|---|---|
| Idle, with an empty prompt | Sends the command and the review starts right away |
| Still working | Sends nothing and asks you to run it again when Claude finishes |
| Showing a question, such as a permission request | Sends nothing, so it never answers the question for you |
| Holding a message you were typing | Sends nothing, so it never sends your message half written |

With any other agent, `work review` pastes the command without pressing Enter:
check the chat and press Enter yourself.

With nothing uncommitted, `work review` still sends `/code-review` to Claude
when the branch has commits not pushed yet, since that review covers them. With
`REVIEW_AGENT_CMD` set, the separate pane reviews those commits too; otherwise it
only reviews uncommitted changes.

## Your own review command

To use the review of a method such as
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD) or a skill of your own, set
the command as a `REVIEW_COMMAND` line:

```bash
REVIEW_COMMAND="/bmad-code-review"
```

- in `.workdeck/review.conf` inside the project, for that project only;
- in `~/.config/workdeck/settings.conf`, for all projects.

The project file takes precedence, but it only accepts a slash command without
arguments, such as `/bmad-code-review`: a repository you cloned cannot put
instructions in your agent chat. Your own `settings.conf` accepts any text, such
as `/code-review high`. The command is pasted as is, whatever the `work review`
target, into any agent open in the window; `work review staged` always uses the
separate pane. The files are read, not run, with the same rules as `settings.conf`: the first
`REVIEW_COMMAND="…"` line counts, and lines in any other shape are ignored.

## The separate pane

With `--pane`, with `staged`, with `REVIEW_AGENT_CMD` set, or when no option
above applies, `work review` opens the workdeck review request in a pane below
your AI chat (or below the pane you are in). Running it again sends the request
to the same pane.

The answer is a short list, one colored dot per finding. The request is written
in Portuguese, like the rest of the workdeck interface:

```
Usei: roteiro padrão

🔴 src/api/pedidos.ts:42 — o token vai inteiro para o log
   → logar só o id do usuário
🟠 src/lista.tsx:18 — uma consulta por item dentro do map
   → buscar todos de uma vez antes do map
🟢 os testes cobrem o caso novo

🔴 corrija os vermelhos antes do commit
```

| | Means | What to do |
|---|---|---|
| 🔴 | Bug: breaks something, loses data, opens a security hole or does not do what the change promises | Fix it before the commit |
| 🟠 | Attention: works, but is risky, slow, untested or unnecessary | Worth fixing; can wait |
| 🟢 | Fine: what was checked and is correct | Nothing |

The last line is the verdict: 🟢 ready to commit, 🟠 ready to commit with the
orange items left for later, or 🔴 fix the red items first.

With `claude`, each branch has a single review session in the pane: `work review`
resumes the same conversation (`claude --resume`) instead of starting a new one
each time. With `claude`, `codex` and `gemini`, the request goes straight into
the conversation. With another AI, it goes to the clipboard and to
`~/.cache/workdeck/review-request.md`, for you to paste.

Which AI the review uses: `REVIEW_AGENT_CMD` in `~/.config/workdeck/settings.conf`,
when set. Otherwise the one open in the window, and if there is none, the one
chosen during installation, stored as `AGENT_CMD`.

A different model or AI for the review avoids repeating the blind spots of the
one that wrote the code: agents built on the same model tend to make the same
mistakes and to agree with each other. Set it once, and every `work review`
runs in the separate pane with that agent, even with Claude Code open:

```bash
REVIEW_AGENT_CMD="claude --model opus"
```

## Extra instructions

To add something to the workdeck review request, such as the base branch or a
preferred skill, write it in:

- `~/.config/workdeck/review.md`, for all projects;
- `.workdeck/review.md` inside the project, for that project only.

The text goes at the end of the request and takes precedence over the default
instructions. It only applies to the separate pane: `/code-review` follows the
project's `CLAUDE.md`, so put rules for it there.

The separate-pane review comes from the review step in
[ponytail](https://github.com/dietrichgebert/ponytail).
