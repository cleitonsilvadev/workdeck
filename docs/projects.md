**English** · [Português](projects.pt-BR.md)

# Projects

Each project is a window in the tmux session. `work` opens all of them at once,
and the session survives closing the terminal or losing the connection: run
`work` again and everything is where you left it, agent included. Restarting
the machine closes the session; `work` opens the project windows again, and you
start the agent again.

## Adding

```bash
work add ~/code/api        # Tab completes the path
work add                   # without a path, uses the current folder
```

The window name is the folder name. With the session open, the window appears
right away; if the folder is already in your work, nothing changes. In the menu
(<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd>), "Adicionar um projeto…" does the
same.

## Removing

Close the project window: `exit` in the last pane, or
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd>. It leaves the list, and the next
`work` no longer opens it. Closing only one of the split panes, or the agent,
removes nothing. To bring it back, run `work add` again.

## `projects.conf`

Projects are stored in `~/.config/workdeck/projects.conf`, one line per window:

```
name|path|optional command
```

```
painel|$HOME|work-panel
api|$HOME/projects/my-api
web|$HOME/projects/my-frontend
notes|~/notes
```

- **name** becomes the tmux window name.
- **path** is where the window opens; it accepts `~` and `$HOME`.
- **command** is optional: when present, the window runs it instead of a shell.

The order of the file is the order of the windows, numbered from 1. A project
that does not exist on disk is skipped without an error, so you can keep lines
for repositories you have not cloned yet.

To reorder, edit the file, close the session with `work kill` and open it again
with `work`. Windows are created when the session opens; without closing it,
the session keeps the old list.

## Knowing when an agent finishes

While you work in one window, workdeck watches the agents open in the others.
When an agent finishes, or stops to ask you something, its window gets a ✦ in
the status bar. A window with several agents still shows a single star:

```
 ❯_ work   1 painel   2 api ✦   3 web   4 mobile
```

The star goes away when you open the window, or when every agent in it is
working again. Nothing is marked for the window you are looking at.

For Claude Code and Codex, workdeck knows an agent is working while its screen
shows "esc to interrupt". For other agents, it watches the screen change and
marks the window after 10 seconds without changes.

To also get a system notification ("o claude terminou em api"), add this to
`~/.config/workdeck/settings.conf`:

```
NOTIFY_AGENTS="yes"
```

It uses `osascript` on macOS and `notify-send` on Linux, when installed.

## Three panes per project

Each project window opens with a single shell by default. To open it already
split into the agent, the server and a free shell, add this to
`~/.config/workdeck/settings.conf`:

```
PROJECT_LAYOUT="agent-server-shell"
```

```
┌──────────────┬──────────────┐
│              │ 2 server     │
│  1 agent     │              │
│              ├──────────────┤
│              │ 3 shell      │
└──────────────┴──────────────┘
```

- **1, the agent:** the command saved as `AGENT_CMD` (such as `claude`) is typed
  in, without running. Press Enter in the projects you are going to work on.
  Without an `AGENT_CMD`, the pane opens as a plain shell.
- **2, the server:** the command in the project's `.workdeck/project.conf` is
  typed in, also without running:

  ```
  SERVER_COMMAND="npm run dev"
  ```

  The file follows the same rules as `settings.conf`: one `KEY="value"` per
  line, comments on lines of their own. A line in any other shape, such as one
  with a comment after the value, is ignored. Control characters are removed
  before typing, so a value never runs on its own. Without that file, the pane
  opens as a plain shell.
- **3, a free shell** for git, tests and anything else.

The commands are typed once the shell shows its prompt. Nothing starts on its
own, so opening many projects does not start many agents
or servers at once, and ports do not clash. The layout applies to windows opened
after you turn it on: run `work kill` and `work`, or add a project with
`work add`. <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> then adds a fourth pane
below the agent, completing the grid.

## Another session

To use a different session name: `export WORKDECK_SESSION=other`.
