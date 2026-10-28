**English** · [Português](shortcuts.pt-BR.md)

# Shortcuts

## Day to day

| To | Keys |
|---|---|
| **Open the menu** (projects, review, split…) | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Previous / next project | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Go to window N | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>1</kbd>…<kbd>9</kbd> |
| Split the screen (side by side or stacked, whichever fits) | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> |
| Pick the direction: side by side / stacked | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>v</kbd> / <kbd>-</kbd> |
| Previous / next pane | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Zoom the pane, and again to restore | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>z</kbd> |
| Close the pane | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd> |
| Detach and leave the session running | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd> |

<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> means: press
<kbd>Ctrl</kbd>+<kbd>b</kbd>, release, then the key. The mouse works too:
click a window in the bottom bar, or a pane, and drag a border to resize.

In the menu, each project uses its window number as the key (pressing
<kbd>2</kbd> goes straight to the second one). <kbd>q</kbd> or <kbd>Esc</kbd>
closes the menu.

Only workdeck keys work after <kbd>Ctrl</kbd>+<kbd>b</kbd>; any other key shows
"tecla sem uso no workdeck — Ctrl+b h abre o menu" (key not used by workdeck).

## Single-key shortcuts with Alt

- <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> goes to the window.
- <kbd>Alt</kbd>+arrows switches panes.
- <kbd>Alt</kbd>+<kbd>Shift</kbd>+letter runs the actions: <kbd>D</kbd> splits
  side by side, <kbd>S</kbd> stacked, <kbd>Z</kbd> zooms, <kbd>X</kbd> closes,
  <kbd>T</kbd> opens a window, <kbd>R</kbd> renames the window, <kbd>E</kbd>
  detaches without closing.

In the workdeck kitty they work out of the box, including on a Mac, where
Option already acts as Alt. The actions use Shift because `Alt`+lowercase
letter belongs to readline (moving and deleting words on the command line).

## kitty

kitty is the workdeck terminal, and the installer sets it up for you: theme,
JetBrains Mono, the Mac Option key as Alt and, on a Mac, `cmd` shortcuts
(`cmd+1…9` goes to a window, `cmd+d` splits side by side, `cmd+h` opens the
menu). The full list is in [terminals/README.md](../terminals/README.md).

In another terminal, or over SSH, `work` opens the same way, because the
shortcuts belong to tmux, and the panel tells you that you are outside kitty.
The look and the `cmd` shortcuts, however, are only guaranteed in kitty.

## Creating or changing a shortcut

Add the `bind` to your `~/.tmux.conf`, **after** the workdeck block: anything
before it is turned off together with the default tmux bindings, and the block
is rewritten on every update.

```tmux
bind -n M-S-G new-window -c "#{pane_current_path}" lazygit
```

Then <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> reloads the configuration.
