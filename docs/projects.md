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

## Another session

To use a different session name: `export WORKDECK_SESSION=other`.
