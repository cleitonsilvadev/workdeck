<div align="center">

# workdeck-site

**The landing page for [workdeck](https://github.com/thiagofeliperibeiro/workdeck).**

A single page with an animated terminal showing workdeck in use: the workflow
from `work add` to `work review`, the customizable panel, the shortcuts and the
themes.

**English** · [Português](README.pt-BR.md)

[![CI](https://github.com/thiagofeliperibeiro/workdeck-site/actions/workflows/ci.yml/badge.svg)](https://github.com/thiagofeliperibeiro/workdeck-site/actions/workflows/ci.yml)
![Next.js](https://img.shields.io/badge/Next.js-16-555?logo=nextdotjs)

</div>

---

> The site content is in Brazilian Portuguese, like the workdeck interface.

## Running

```bash
npm install
npm run dev        # http://localhost:3000
```

| Script | What it does |
|---|---|
| `npm run dev` | Development server |
| `npm run build` | Production build |
| `npm run lint` | ESLint with the Next.js rules |
| `npm run typecheck` | Generates the route types (`next typegen`) and type-checks with TypeScript |
| `npm test` | Vitest in watch mode; `npx vitest run` runs once |

## Stack

- [Next.js](https://nextjs.org) with the App Router, static page
- [shadcn/ui](https://ui.shadcn.com) and [Magic UI](https://magicui.design) components in `src/components/ui/`
- [Motion](https://motion.dev) for the terminal animations
- [Catppuccin Mocha](https://catppuccin.com) through `@catppuccin/tailwindcss`, the same palette as the default workdeck theme
- [Vitest](https://vitest.dev) and [Testing Library](https://testing-library.com) for tests

## Layout

```
src/app/page.tsx                  the page, section by section
src/lib/site.ts                   all the content: commands, workflow, shortcuts, themes, install
src/lib/github.ts                 fetches the repository stars from the GitHub API, cached for hours
src/lib/stars.ts                  when to show the stars (10 or more) and how to format them (+23K)
src/components/terminal-parts.tsx the pieces of the animated terminals: window, panes, prompt, tmux bar, timeline
src/components/terminal-demo.tsx  the hero terminal: agent beside the code and the review
src/components/cycle-demo.tsx     the workflow, with clickable chapters
src/components/panel-demo.tsx     the panel gaining a new block
src/components/ui/                components installed with the shadcn and Magic UI CLIs
tests/                            the tests
```

## Changing the content

Almost everything the page says lives in `src/lib/site.ts`. When workdeck
changes a command, a shortcut or a message, that is the place to update it,
and the source of truth is the README and the guides in `docs/` of the
[workdeck repository](https://github.com/thiagofeliperibeiro/workdeck).

The animated terminals mimic the real workdeck: the command messages, the tmux
bar (`❯_ work`, the `1 painel` and `2 api` tabs, and the `✦` where the AI is
open) and the panel. If workdeck changes what it prints, update the animation
too.

### Version

`version`, in `src/lib/site.ts`, is the version shown in the top badge and in
the animated panel. Update it on every workdeck release.

## Tests

```bash
npx vitest run
```

The tests live in `tests/` and cover:

- **The content** (`site.test.ts`): the six workdeck commands, the four workflow steps, the install command pointing to the repository, the version in `vX.Y.Z` format, the theme colors and the lists used as React keys having no duplicates.
- **The page** (`page.test.tsx`): the heading, each menu link pointing to an existing section, every command on screen, the version, GitHub and the install command, and the stars on the GitHub link.
- **The stars** (`github.test.ts`): the GitHub API request, `null` when it fails and the `+23K` format.
- **The animation timeline** (`timeline.test.tsx`): advancing step by step, restarting at the end, jumping to a step and going straight to the end with reduced motion.
- **The animated workflow** (`cycle-demo.test.tsx`): starting outside workdeck, `work add` opening the window in the background, `Shift+→` going to it and the clickable chapters.

CI runs lint, typecheck, tests and the build on Ubuntu on every push to `main`
and on pull requests.

## Deploy

On Vercel: import the repository. The framework is detected automatically and
there are no environment variables to set.
