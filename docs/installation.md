**English** · [Português](installation.pt-BR.md)

# Installation

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh | bash
```

`get.sh` downloads the latest published version to `~/.local/share/workdeck`
and runs `install.sh` from there. You do not need to clone the repository.

workdeck runs on macOS and Linux. On Windows, install it inside WSL: open your
WSL distribution (Ubuntu, for example) and run the command there. The installer
stops before writing anything when it runs in Git Bash, MSYS or Cygwin.

## What the installer does

1. Asks which language workdeck uses for its messages, English or Brazilian
   Portuguese. The default follows the system language (`LANG`); `--lang en`
   or `--lang pt-BR` answers without asking, and the choice is saved as
   `LANGUAGE` in `~/.config/workdeck/settings.conf`.
2. Detects the system and the package manager (brew on macOS; apt, dnf,
   pacman, zypper or apk on Linux) and installs tmux if it is missing.
3. Asks whether you want the workdeck shortcuts in
   [kitty](https://sw.kovidgoyal.net/kitty/), the recommended terminal. If kitty
   is missing, it offers to download it with kitty's official installer (no
   password), and writes the configuration either way. A second question offers
   the workdeck theme and the JetBrains Mono font in kitty. The answers are
   saved in `~/.config/workdeck/settings.conf` (`TERMINAL` and `VISUAL`), and
   `--terminal kitty` / `--terminal other` and `--visual` / `--no-visual`
   answer without asking. Other terminals, such as Warp or iTerm2, use the tmux
   shortcuts. Details in [terminals/README.md](../terminals/README.md).
4. Puts the `work` command in `~/.local/bin`.
5. Writes the configuration blocks to `.tmux.conf` and `.zshrc` (or
   `.bashrc`), and to `kitty.conf` if you said yes to kitty.
6. Offers the workdeck zsh setup and picks your AI agent from the `PATH`
   (`--agent codex` sets another). Integrations are only installed with
   `--with <name>`.

It is idempotent: running it again updates instead of duplicating. Everything
it writes to your files stays between `# >>> workdeck >>>` markers, and the
uninstaller removes exactly that block. If a script of yours with the same name
already exists in `~/.local/bin`, the installer leaves it alone and tells you.

## Options

Options go at the end of the command: `curl -fsSL … | bash -s -- --theme nord`.

| Option | What it does |
|---|---|
| `--lang en\|pt-BR` | Picks the language of the messages without asking; the choice is saved |
| `--theme <name>` | Picks a theme from `themes/` (default: `catppuccin-mocha`); the choice is saved |
| `--agent <command>` | Sets your AI agent without asking (`claude`, `codex`…) |
| `--with <name>` | Enables integrations without asking: `bmad`, `spec-kit`, `ai-memory` (comma separated) |
| `--list-integrations` | Lists the available integrations and exits |
| `--zsh` | Installs oh-my-zsh and zinit without asking |
| `--yes` | Asks nothing; uses the defaults |
| `--no-deps` | Installs nothing through the package manager |
| `--no-reload` | Does not reload tmux at the end (useful when installing into a test HOME) |
| `--dry-run` | Shows what it would do, without writing anything |

To change an option later, run the same install command with it.

## The workdeck zsh setup

The installer offers a ready-made zsh, with "yes" as the default answer:
[oh-my-zsh](https://ohmyz.sh) with the robbyrussell theme
(`➜  project git:(main) ✗`) and [zinit](https://github.com/zdharma-continuum/zinit)
with three plugins: suggestions as you type (zsh-autosuggestions), command
highlighting (fast-syntax-highlighting) and more Tab completions
(zsh-completions). All of it is loaded by the workdeck block in `.zshrc`; the
rest of the file stays as it is.

- If your `.zshrc` already loads oh-my-zsh, zinit, Starship or Powerlevel10k,
  the installer does not ask and does not touch it. An oh-my-zsh or zinit
  folder that `.zshrc` does not load (left over from another installation)
  does not count: the installer reuses the folder.
- On Linux without zsh, it installs zsh and asks before changing your default
  shell (it asks for your password).
- For another oh-my-zsh theme, add `export WORKDECK_ZSH_THEME=agnoster` (or any
  other) to `~/.zshrc`, before the workdeck block.
- To skip it, answer "n" during the installation.

## Where everything lives

```
~/.local/bin/work                   the only command on the PATH
~/.local/share/workdeck/            the code, at the installed version
~/.config/workdeck/projects.conf    your projects
~/.config/workdeck/panels/          your panels
~/.config/workdeck/settings.conf    your choices: agent, theme, terminal, visual, zsh, integrations, active pane
~/.tmux.conf                        block between the markers
~/.zshrc or ~/.bashrc               block between the markers
~/.config/kitty/kitty.conf          block between the markers, only if you chose kitty
~/.local/share/warp-terminal/themes/workdeck-*.yaml   the same, on Linux
~/.oh-my-zsh, ~/.local/share/zinit  the workdeck zsh setup, if you accepted it
```

## Updating

```bash
work update              # looks for a new version, shows what changed and asks
work update --off        # stops the notices; work update keeps working
work update --on         # turns the notices back on
```

`work` and the panel check on their own, at most once a day and in the
background: they never wait on the network, and without a connection nothing
happens. When there is a new version, `work` shows what changed and asks before
opening the session; if you say no, it does not ask again about that version.
While a version is waiting to be installed, the panel shows
`● v1.0.0 → v1.1.0: work update`.

Only versions published as tags (`v1.2.0`) count, not every commit. Updating
replaces the code and reapplies the installation; projects, panels, theme and
agent stay as they are.

## Uninstalling

```bash
work uninstall              # shows what will be removed and asks first
work uninstall --dry-run    # shows what it would do, without deleting
```

`work uninstall` removes everything workdeck installed: the blocks in
`.zshrc`, `.tmux.conf` and `kitty.conf` (if it was written), the Warp theme and
iTerm2 profile from older versions, tclock if workdeck installed it,
the `work` command, the code, the workdeck zsh setup, the font and the config
in `~/.config/workdeck`. What existed before the installation stays: a kitty or
oh-my-zsh you already had is not removed. If kitty is installed, it asks whether
to remove it too; the default answer is no.

To remove less, run the uninstaller directly:

```bash
bash ~/.local/share/workdeck/uninstall.sh             # removes the blocks and scripts; keeps the config
bash ~/.local/share/workdeck/uninstall.sh --restore   # restores your files to how they were before
```

Before touching a file for the first time, the installer saves a copy in
`~/.config/workdeck/.backups/` and records everything it does in a manifest.
`--restore` uses those copies: `.tmux.conf` and `.zshrc` go back byte for byte
to what they were. A script you changed after the installation is kept, with a
notice.
