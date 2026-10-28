**English** · [Português](README.pt-BR.md)

# kitty

workdeck requires [kitty](https://sw.kovidgoyal.net/kitty/), which runs on
macOS and Linux. The installer downloads kitty with the official installer,
without sudo, and adds the `kitty.conf` block to your
`~/.config/kitty/kitty.conf`:

- **Theme** from workdeck (`--theme`), the same as the tmux status bar.
- **Font** JetBrains Mono, with slightly larger line spacing.
- **Option as Alt** on a Mac, for the direct Alt shortcuts.
- **cmd** on a Mac: `cmd+h` opens the menu, `cmd+enter` splits the screen,
  `cmd+1…9` goes to a window, `cmd+d` / `cmd+shift+d` splits side by side /
  stacked, `cmd+shift+enter` zooms, `cmd+shift+w` closes the pane.

| System | Where kitty goes |
|---|---|
| macOS | `~/Applications/kitty.app` |
| Linux | `~/.local/kitty.app`, with `kitty` in `~/.local/bin` and a launcher in the applications menu |

If you already have kitty, the installer uses yours and only adds the block.
What you wrote outside the `# >>> workdeck >>>` markers does not change, and the
uninstaller removes only the block. kitty itself stays installed.

**Another terminal**, or an SSH connection, also opens `work`, because the
shortcuts belong to tmux, and the panel tells you that you are outside kitty.
The look and the `cmd` shortcuts are only guaranteed in kitty.
