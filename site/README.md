<div align="center">

# workdeck-site

**O site de apresentação do [workdeck](https://github.com/thiagofeliperibeiro/workdeck).**

Uma página só, com o terminal animado mostrando o workdeck em uso: o ciclo do
`work add` ao `work review`, o painel personalizável, os atalhos e os temas.

[![CI](https://github.com/thiagofeliperibeiro/workdeck-site/actions/workflows/ci.yml/badge.svg)](https://github.com/thiagofeliperibeiro/workdeck-site/actions/workflows/ci.yml)
![Next.js](https://img.shields.io/badge/Next.js-16-555?logo=nextdotjs)

</div>

---

## Rodando

```bash
npm install
npm run dev        # http://localhost:3000
```

| Script | O que faz |
|---|---|
| `npm run dev` | Servidor de desenvolvimento |
| `npm run build` | Build de produção |
| `npm run lint` | ESLint com as regras do Next.js |
| `npm run typecheck` | Gera os tipos das rotas (`next typegen`) e checa os tipos do TypeScript |
| `npm test` | Testes com Vitest, em modo watch; `npx vitest run` roda uma vez |

## Stack

- [Next.js](https://nextjs.org) com App Router, página estática
- [shadcn/ui](https://ui.shadcn.com) e componentes do [Magic UI](https://magicui.design) em `src/components/ui/`
- [Motion](https://motion.dev) para as animações dos terminais
- [Catppuccin Mocha](https://catppuccin.com) pelo `@catppuccin/tailwindcss`, a mesma paleta do tema padrão do workdeck
- [Vitest](https://vitest.dev) e [Testing Library](https://testing-library.com) nos testes

## Estrutura

```
src/app/page.tsx                  a página, seção por seção
src/lib/site.ts                   todo o conteúdo: comandos, ciclo, atalhos, temas, instalação
src/components/terminal-parts.tsx as peças dos terminais animados: janela, painéis, prompt, barra do tmux, linha do tempo
src/components/terminal-demo.tsx  o terminal do topo: agente ao lado e review
src/components/cycle-demo.tsx     o ciclo de trabalho, com capítulos clicáveis
src/components/panel-demo.tsx     o painel ganhando um bloco novo
src/components/ui/                componentes instalados pelo CLI do shadcn e do Magic UI
tests/                            os testes
```

## Mudando o conteúdo

Quase tudo o que a página diz está em `src/lib/site.ts`. Quando o workdeck
mudar um comando, um atalho ou um texto, o lugar de ajustar é ali, e a fonte
da verdade é o README e os guias em `docs/` do
[repositório do workdeck](https://github.com/thiagofeliperibeiro/workdeck).

Os terminais animados imitam o workdeck de verdade: as mensagens dos comandos,
a barra do tmux (`❯_ work`, as abas `1 painel`, `2 api` e o `✦` onde a IA está
aberta) e o painel. Se o workdeck mudar o que imprime, ajuste a animação junto.

### Versão

`version`, em `src/lib/site.ts`, é a versão mostrada no selo do topo e no painel
animado. Atualize a cada release do workdeck.

## Testes

```bash
npx vitest run
```

Os testes ficam em `tests/` e cobrem:

- **O conteúdo** (`site.test.ts`): os seis comandos do workdeck, os quatro passos do ciclo, o comando de instalação apontando para o repositório, a versão no formato `vX.Y.Z`, as cores dos temas e as listas que viram chave do React sem repetir.
- **A página** (`page.test.tsx`): o título, cada link do menu levando a uma seção que existe, todos os comandos na tela, e a versão, o GitHub e o comando de instalação.
- **A linha do tempo das animações** (`timeline.test.tsx`): avançar passo a passo, recomeçar no fim, pular para um passo e ir direto para o fim com movimento reduzido.
- **O ciclo animado** (`cycle-demo.test.tsx`): começar fora do workdeck, o `work add` abrindo a janela em segundo plano, o `Shift+→` levando até ela e os capítulos clicáveis.

O CI roda lint, typecheck, testes e build no Ubuntu a cada push na `main` e em
pull requests.

## Deploy

Na Vercel: importe o repositório. O framework é detectado sozinho e não há
variável de ambiente para configurar.
