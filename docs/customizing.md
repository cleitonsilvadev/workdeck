**English** · [Português](customizing.pt-BR.md)

# Customizing

Almost everything in workdeck is meant to be changed.

| To change | Where | Then |
|---|---|---|
| The projects and the window order | `~/.config/workdeck/projects.conf` | `work kill` and `work` |
| A keyboard shortcut | your `~/.tmux.conf`, after the workdeck block | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> |
| The `cmd` shortcuts and the kitty look | your `kitty.conf`, outside the workdeck block | reopen kitty |
| The colors | the installer with `--theme <name>` | — |
| What the panel shows | `~/.config/workdeck/panels/` | nothing, it rereads on its own |
| What every review asks for | `~/.config/workdeck/review.md` or `.workdeck/review.md` | — |
| The oh-my-zsh theme | `export WORKDECK_ZSH_THEME=<theme>` in `.zshrc` | reopen the terminal |
| The session name | `export WORKDECK_SESSION=other` | — |
| Something not listed here | a fork, with your command in `bin/work` | `./install.sh` in the fork |

The installer only manages what is between the `# >>> workdeck >>>` markers;
the rest of your files remains yours. Anything you put outside those blocks
survives updates.

## Keeping your own version

Only `work` goes on the `PATH`. The other scripts in `bin/` are internal pieces,
called from the installation in `~/.local/share/workdeck`.

To go beyond configuration, fork the repository, change what you want and run
`./install.sh` from inside it. The installer copies your fork to
`~/.local/share/workdeck`, and `work update` then follows its versions.
