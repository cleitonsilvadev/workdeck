**English** · [Português](README.pt-BR.md)

# Integrations

Nothing here is installed by default. Each integration is a third-party tool
you may or may not want. On the first installation, `install.sh` lists the ones
available here and asks which you use; after that, it only touches them when
you ask:

```bash
./install.sh --with ai-memory          # one
./install.sh --with ai-memory,mcp-git  # several
./install.sh --list-integrations       # see what is available
```

Each `<name>.sh` file here is a script with three functions: `describe`,
`is_installed` and `setup`. The installer calls the first two before asking
anything, and the third only after you confirm.

A fourth one, `usage`, is optional: it explains how to get the AI working with
the integration (what to put in `CLAUDE.md`, for example). The installer shows
it after `setup` and also when the integration was already installed.

The text these functions print is shown in the terminal, so it is written in
Brazilian Portuguese, like the rest of the workdeck interface.

## Writing one

Copy `example.sh` and fill it in:

```bash
describe() {
  echo "Short name"
  echo "One or two lines about what it does and who maintains it."
  echo "https://project-link"
}

is_installed() {        # 0 = already installed
  command -v my-tool >/dev/null
}

setup() {               # what to do; may ask the user to confirm
  echo "running the official installer…"
  # ...
}

usage() {               # optional: how to use it once installed
  echo "point to it in the project's CLAUDE.md"
}
```

Keep `setup()` honest: if the integration downloads something from the
internet, say from where. If it needs an API key, say so up front, not
afterwards.

## Why separate

workdeck is a workflow, not a package manager. These integrations exist because
they come up often when working with AI agents, not because the project
endorses, maintains or has audited them. Read what each one does before running
it.
