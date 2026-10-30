@AGENTS.md

# workdeck site (site/)

## Language

| What | Language |
|---|---|
| Code: identifiers, props, object keys, file names, test names, comments, CI | English |
| What visitors see on the page: copy, labels, `aria-label`, section anchors (`#temas`), metadata | Brazilian Portuguese |
| README | Both: `README.md` in English, `README.pt-BR.md` in Brazilian Portuguese |
| Commit messages | English |

- Both READMEs start with a language switcher (`English | Português`) linking to each other.
  A change to one is mirrored in the other in the same commit, with the same structure.
- The Portuguese README is written as natural Brazilian Portuguese, not as a literal translation.
- Links from the page to workdeck docs point to the Portuguese version (`docs/<name>.pt-BR.md`),
  since the page is in Portuguese.

## Writing style

- Human and direct, like a developer talking about their own project: short sentences, active voice,
  "we" when it reads naturally ("we don't support Warp yet :(").
- No semicolons. Split into two sentences or use a comma.
- A simple emoticon such as `:(` or `:)` is fine when it fits, never emoji in a row.
- Write site copy with a PM and marketing eye: lead with what the person gains, keep it short, and
  say plainly what is not supported yet.

## Commits

- Imperative subject line in English, up to 72 characters, no trailing period
  (`Show the GitHub star count in the header`).
- Optional body after a blank line explaining what changed and why, wrapped at 72 columns.
- One logical change per commit.
