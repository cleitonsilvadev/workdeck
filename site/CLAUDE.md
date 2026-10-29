@AGENTS.md

# workdeck-site

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

- Professional and neutral: short sentences, active voice, no first person, no emoji in docs.

## Commits

- Imperative subject line in English, up to 72 characters, no trailing period
  (`Show the GitHub star count in the header`).
- Optional body after a blank line explaining what changed and why, wrapped at 72 columns.
- One logical change per commit.
