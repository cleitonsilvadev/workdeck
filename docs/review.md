**English** · [Português](review.pt-BR.md)

# Self code review

A review before the commit. `work review` opens a separate pane, below your AI
chat, with an agent that starts from scratch: it reads only the change and the
code around it, not the conversation that wrote it.

```bash
work review            # what is not committed yet, or the commits not pushed yet
work review branch     # everything the branch changed compared to the main branch
work review staged     # only what is staged (git add)
work review --chat     # the quick review, in the chat you are already using
```

In kitty, <kbd>⌘</kbd>+<kbd>R</kbd> runs `work review`, and the menu has it too.

## Why a separate pane

A review in the same chat shares the conversation and the model that wrote the
code, so it tends to agree with the choices already made and to miss the same
things. In the separate pane, the reviewer starts clean, and with
`REVIEW_AGENT_CMD` it can even be another model or another AI:

```bash
REVIEW_AGENT_CMD="claude --model opus"
```

The price is one step: you take the findings back to the agent chat to fix
them. For a small change where speed matters more, `work review --chat` runs the
review in the chat you are using.

## The separate pane

`work review` opens the workdeck review request in a pane below your AI chat (or
below the pane you are in). Running it again sends the request to the same pane.

The answer is a short list, one colored dot per finding, in the language you
chose at install:

```
Used: default checklist

🔴 src/api/orders.ts:42 — the whole token goes to the log
   → log only the user id
🟠 src/list.tsx:18 — one query per item inside the map
   → fetch them all before the map
🟢 the tests cover the new case

🔴 fix the reds before the commit
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
found at install, stored as `AGENT_CMD`.

## Your own review command

To use the review of a method such as
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD) or a skill of your own, set
the command as a `REVIEW_COMMAND` line:

```bash
REVIEW_COMMAND="/bmad-code-review"
```

- in `.workdeck/review.conf` inside the project, for that project only;
- in `~/.config/workdeck/settings.conf`, for all projects.

The command becomes the first message of the agent in the separate pane, instead
of the workdeck request. With `--chat`, it is pasted into the chat you are using.
The project file takes precedence, but it only accepts a slash command without
arguments, such as `/bmad-code-review`: a repository you cloned cannot put
instructions in your agent. Your own `settings.conf` accepts any text, such as
`/code-review high`. The files are read, not run, with the same rules as
`settings.conf`.

## The review in the chat

`work review --chat` sends the review to the agent open in the window instead:
your `REVIEW_COMMAND`, or `/code-review` with Claude Code
(`/code-review main...HEAD` with `branch`). With Claude Code, it reads the chat
screen first:

| The Claude chat | What `work review --chat` does |
|---|---|
| Idle, with an empty prompt | Sends the command and the review starts right away |
| Still working | Sends nothing and asks you to run it again when Claude finishes |
| Showing a question, such as a permission request | Sends nothing, so it never answers the question for you |
| Holding a message you were typing | Sends nothing, so it never sends your message half written |

With any other agent, it pastes the command without pressing Enter: check the
chat and press Enter yourself. When the chat cannot take the review (no agent
open, `staged`, or `REVIEW_AGENT_CMD` set), it falls back to the separate pane.

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
