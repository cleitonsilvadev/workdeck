**English** · [Português](README.pt-BR.md)

# Terminals

tmux is the only dependency, so `work`, the panel and the shortcuts behave the
same in any terminal. What changes from one terminal to another are the extras:
the colors, the font and the terminal's own shortcuts.

The installer asks which terminals you use (kitty, iTerm2 on a Mac, Warp or the
default terminal, which covers the system one and any other; you can pick more
than one) and sets up the extras each one supports.
**It does not install a terminal:** if the one you chose is missing, it writes
the configuration anyway and tells you where to download it, so the terminal
opens ready once you install it. To answer without the question, use
`--terminal kitty`, `--terminal kitty,iterm`, `--terminal warp` or
`--terminal other`; the choice is saved
in `~/.config/workdeck/settings.conf` (`TERMINAL`).

For kitty and Warp, a second question offers the workdeck **look**: the theme
and the JetBrains Mono font, downloaded from the official releases without sudo.
The default answer is no (Enter declines). `--visual` accepts without asking and
`--no-visual` declines; the answer is saved in `~/.config/workdeck/settings.conf` (`VISUAL`).

## kitty

With kitty chosen, the installer adds a block to your
`~/.config/kitty/kitty.conf`, even before kitty is installed, with:

- **The workdeck shortcuts**, <kbd>⌘</kbd> on a Mac and
  <kbd>Ctrl</kbd>+<kbd>Shift</kbd> on Linux: H menu, P add a project, 1…9 go to
  a project, A agent, T terminal, Z zoom, W close,
  R review. The full table is in [docs/shortcuts.md](../docs/shortcuts.md).
- **Option as Alt** on a Mac, for the direct Alt shortcuts.
- **Shift+Enter** is sent in the extended format, so agents such as Claude Code
  get a new line instead of a submit. It only applies while tmux runs in the
  window, so a plain shell is not affected.

If you accept the look, the same block also gets:

- **Theme** from workdeck (`--theme`), the same as the tmux status bar.
- **Font** JetBrains Mono, with slightly larger line spacing.
- **Padding** of 8 points between the text and the window edge. With the
  theme, the kitty background matches the tmux background and the padding
  blends into it.

Without the look, kitty keeps its own theme and font. If an older workdeck
version already wrote the theme and font to your `kitty.conf`, the update keeps
them and saves that as your choice.

The installer finds kitty in `/Applications` or `~/Applications` (Mac), in
`~/.local/kitty.app` (Linux) or in the `PATH`. What you wrote outside the
`# >>> workdeck >>>` markers does not change, and the uninstaller removes only
the block. kitty itself stays installed.

## iTerm2

On a Mac, with iTerm2 chosen, the installer writes a **workdeck** profile to
`~/Library/Application Support/iTerm2/DynamicProfiles/workdeck.json`, even
before iTerm2 is installed. It has the same workdeck shortcuts as kitty, with
<kbd>⌘</kbd>, and the left Option key as Meta for the Alt shortcuts.

iTerm2 does not switch to a new profile on its own. Pick it once in Settings ›
Profiles › workdeck › Other Actions › Set as Default; the installer reminds you
at the end. `work uninstall` removes the profile, unless you edited it.

## Warp

With [Warp](https://www.warp.dev/) chosen, the installer checks that it is
installed. `work` opens and tmux does the rest: the Alt shortcuts and the status
bar work as usual. The panel recognizes Warp through the `WARP_CLIENT_VERSION`
variable.

If you accept the look, the installer copies the theme to the Warp themes folder
and downloads the JetBrains Mono font:

| System | Where the theme goes |
|---|---|
| macOS | `~/.warp/themes/workdeck-<theme>.yaml` |
| Linux | `~/.local/share/warp-terminal/themes/workdeck-<theme>.yaml` |

Warp does not switch theme or font from a file, so the last step is yours:

- **Theme.** In **Settings › Appearance › Themes**, pick `workdeck <theme>`. You
  can also search for "Open theme picker" in the Command Palette. Warp may take a
  few minutes to notice the new folder; reopening the app fixes it.
- **Font.** In **Settings › Appearance › Text › Font type**, pick JetBrains Mono.
- **Option as Alt (Mac only).** The tmux Alt shortcuts (`Alt+1…9`, `Alt+↑/↓`)
  only work when Option is treated as Alt. In **Settings › Features**, turn on
  **Left Option key is Meta**. The installer does not turn it on for you, because
  Warp keeps this option in its own `settings.toml` and rewrites it.

What does **not** come to Warp: the workdeck shortcuts. Warp's `keybindings.yaml`
only binds keys to Warp's own actions and has no action to send text, which is
what turns the workdeck shortcuts into tmux keys. In Warp, use
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> for the menu.

`work uninstall` removes the copied theme, unless you edited it.

If you attach from another terminal to a tmux session started in Warp, the
`WARP_CLIENT_VERSION` variable stays in the tmux environment and the panel shows
the Warp notice.

## Default terminal

Ghostty, WezTerm, the terminal that ships with your system or an SSH connection:
`work` opens the same way, with the tmux shortcuts (<kbd>Ctrl</kbd>+<kbd>b</kbd>
<kbd>h</kbd> for the menu, <kbd>Shift</kbd>+arrows to move). On a
Mac, set Option as Meta in the terminal settings to use the Alt shortcuts. The
theme and the font, if you want them, are set in the terminal itself.
