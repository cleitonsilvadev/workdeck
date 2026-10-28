# workdeck

## Language

| What | Language |
|---|---|
| Code: identifiers, functions, variables, file and folder names, comments, tests, CI | English |
| What the user sees in the terminal: CLI output, prompts, `--help`, panel titles, the AI review request, integration texts, `CHANGELOG.md` (shown by `work update`) | Brazilian Portuguese |
| READMEs and guides (`README.md`, `docs/`, `integrations/README.md`, `terminals/README.md`) | Both: `<name>.md` in English, `<name>.pt-BR.md` in Brazilian Portuguese |
| `CONTRIBUTING.md`, `SECURITY.md` | English |
| Commit messages, tag annotations | English |

- Each README and doc starts with a language switcher (`English | Português`) linking to its pair.
  A change to one language is mirrored in the other in the same commit, with the same structure.
- Files whose name the user sees on screen keep the Portuguese name, because the name is the text
  shown: panels in `config/panels/` (the file name becomes the panel title).
- File and config names the user does not read on screen are English. When a config file under
  `~/.config/workdeck/` is renamed, `install.sh` migrates the old name on the next `work update`,
  so nobody loses a choice already made.
- `instalar.sh` stays as a forwarder to `get.sh`, so the old one-line install URL keeps working.

## Writing style

- Professional and neutral, in the tone of a well-maintained open source CLI: short sentences,
  active voice, second person in docs ("you" / "você"), imperative in instructions.
- No first person, no jokes, no emoji in docs or CLI output.
- Name things the way the user sees them on screen: commands, keys, file paths.
- The Portuguese README and docs are written as natural Brazilian Portuguese, not as a literal
  translation of the English text.

## Commits

- Imperative subject line in English, up to 72 characters, no trailing period
  (`Add sprint panel example`, `Fix integration prompt parsing`).
- Optional body after a blank line explaining what changed and why, wrapped at 72 columns.
- One logical change per commit.
