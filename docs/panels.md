**English** · [Português](panels.pt-BR.md)

# Panels

The panel is window 1 of the session: an overview of your work at the top and
an 8-line terminal at the bottom for typing. With no projects yet, `work` opens
with only the panel, showing what is left to do, and a `work add` typed there
creates the window right away.

What appears at the top is built from a folder:

```
~/.config/workdeck/panels/
├── 00-workdeck     the logo, the version and what is left to set up
├── 20-projetos     the branch and changes of each project
└── 30-docker       ← yours
```

Each file is a program. The panel runs all of them in alphabetical order and
shows what each one prints, one below the other. Every 60 seconds it runs them
again. Customizing the panel means creating, editing or turning off files in
that folder.

## Writing your own, step by step

A panel with the commits you made today in each project:

**1. Create the file.** The name becomes the title and sets the position: `30-`
comes after the two built-in panels.

```bash
cat > ~/.config/workdeck/panels/30-commits-today <<'PANEL'
#!/usr/bin/env bash
while IFS='|' read -r name path _; do
  path="${path/#\~/$HOME}"; path="${path/#\$HOME/$HOME}"
  [ -d "$path/.git" ] || continue
  n=$(git -C "$path" log --oneline --since=midnight --author="$(git config user.email)" | wc -l | tr -d ' ')
  [ "$n" -gt 0 ] && echo "$name  $n commit(s)"
done < ~/.config/workdeck/projects.conf
PANEL
```

**2. Make it executable.** Without that, it does not show up: a file without
execute permission is a disabled panel.

```bash
chmod +x ~/.config/workdeck/panels/30-commits-today
```

**3. Test it outside the panel.** Run the file directly in the terminal and
check that the output is what you want:

```bash
~/.config/workdeck/panels/30-commits-today
```

**4. Done.** No need to reinstall or restart: on the next cycle it appears in
the panel with the title "Commits today".

## Rules

- **Any language.** Bash, Python, Node, a binary: it only needs to be
  executable and print text. For Python, start the file with
  `#!/usr/bin/env python3`.
- **The name is the title.** The numeric prefix is dropped and hyphens become
  spaces: `30-commits-today` shows up as "Commits today". Files starting with
  `00-` have no title.
- **The order is alphabetical.** Use the prefix to sort: `10-`, `20-`, `30-`.
- **Colors work.** ANSI codes pass straight through, as in
  `printf '\033[32m✓\033[0m all good\n'`.
- **Be fast.** Panels run one after the other, and the panel only redraws when
  all of them finish. A command that takes 10 seconds delays everything. For
  something slow, like an API, save the result to a file and refresh it only
  once in a while.
- **Errors show up.** Whatever the program writes to stderr also goes to the
  panel, which helps you find out why it broke.

## Ideas

| Panel | Main command |
|---|---|
| Running containers | `docker ps --format '{{.Names}}  {{.Status}}'` |
| Open pull requests | `gh pr list --author @me` |
| Latest CI build | `gh run list --limit 3` |
| Ports in use | `lsof -iTCP -sTCP:LISTEN -P \| awk 'NR>1 {print $1, $9}'` |
| Disk space | `df -h / \| tail -1` |
| Today's tasks | `cat ~/notes/today.md` |

## Changing the built-in panels

**Turn one off.** Remove the execute permission. The panel stops showing it,
and `work update` respects that: it does not turn it back on.

```bash
chmod -x ~/.config/workdeck/panels/20-projetos
```

To turn it back on, `chmod +x`. Deleting the file does not help: the next
update creates it again.

**Edit one.** Change it as much as you like. A built-in panel you edited is
never overwritten by `work update`; the ones you did not touch receive the
improvements from new versions.

## Changing the interval

The default is 60 seconds. For another value, put the number of seconds at the
end of the panel line in `~/.config/workdeck/projects.conf`:

```
painel|~|work-panel 30
```

Then run `work kill` and `work` to apply it. Inside the panel, <kbd>q</kbd>
quits.

## Panels that need credentials

If the panel talks to an API (a board, a CI, an internal service), do not put a
token or URL in the script. Read them from a file in `~/.config/workdeck/`:

```bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/my-panel.conf"
[ -f "$CONFIG" ] || { echo "configure it first: $CONFIG"; exit 1; }
. "$CONFIG"
```

That way the panel can be shared and the credentials stay yours.
