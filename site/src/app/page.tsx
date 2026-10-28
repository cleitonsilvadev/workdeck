import { ArrowRight, Bot, History, KeyRound, LayoutPanelLeft, Palette, Terminal, Undo2, X } from "lucide-react"
import { AnimatedGridPattern } from "@/components/ui/animated-grid-pattern"
import { AnimatedShinyText } from "@/components/ui/animated-shiny-text"
import { buttonVariants } from "@/components/ui/button"
import { CommandLine } from "@/components/copy-button"
import { CycleDemo } from "@/components/cycle-demo"
import { GlowCard } from "@/components/glow-card"
import { InstallTabs } from "@/components/install-tabs"
import { PanelDemo } from "@/components/panel-demo"
import { Reveal, Stagger, StaggerItem } from "@/components/reveal"
import { ShortcutList } from "@/components/shortcut-list"
import { TerminalDemo } from "@/components/terminal-demo"
import { ThemePreview } from "@/components/theme-preview"
import { commands, features, installCommand, layers, notThis, panelRules, panelsUrl, principles, repoUrl, uninstall, version } from "@/lib/site"
import { getStars } from "@/lib/github"
import { formatStars, showStars } from "@/lib/stars"
import { cn } from "@/lib/utils"

const icons = {
  bot: Bot,
  terminal: Terminal,
  history: History,
  undo: Undo2,
  panels: LayoutPanelLeft,
  palette: Palette,
}

function GithubMark({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={className} fill="currentColor">
      <path d="M12 .5a11.5 11.5 0 0 0-3.64 22.41c.58.1.79-.25.79-.56v-2c-3.2.7-3.88-1.37-3.88-1.37-.53-1.33-1.28-1.69-1.28-1.69-1.05-.71.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.77 2.7 1.26 3.36.96.1-.75.4-1.26.73-1.55-2.55-.29-5.24-1.28-5.24-5.69 0-1.26.45-2.28 1.19-3.09-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.17 1.18a11 11 0 0 1 5.77 0c2.2-1.49 3.17-1.18 3.17-1.18.63 1.59.23 2.76.11 3.05.74.81 1.19 1.83 1.19 3.09 0 4.42-2.69 5.39-5.26 5.68.41.36.78 1.06.78 2.14v3.17c0 .31.21.67.8.56A11.5 11.5 0 0 0 12 .5Z" />
    </svg>
  )
}

function Section({ id, eyebrow, title, desc, children, className }: { id?: string; eyebrow: string; title: string; desc?: string; children: React.ReactNode; className?: string }) {
  return (
    <section id={id} className={cn("mx-auto w-full max-w-6xl scroll-mt-20 px-4 py-24 sm:px-6", className)}>
      <Reveal className="mx-auto mb-12 max-w-2xl text-center">
        <p className="mb-3 font-mono text-xs tracking-widest text-ctp-mauve uppercase">{eyebrow}</p>
        <h2 className="text-3xl font-semibold tracking-tight text-ctp-text sm:text-4xl">{title}</h2>
        {desc && <p className="mt-4 text-pretty text-ctp-subtext0">{desc}</p>}
      </Reveal>
      {children}
    </section>
  )
}

export default async function Home() {
  const stars = await getStars()

  return (
    <>
      <header className="sticky top-0 z-50 border-b border-ctp-surface0/60 bg-ctp-crust/70 backdrop-blur-xl">
        <div className="mx-auto flex h-14 max-w-6xl items-center justify-between px-4 sm:px-6">
          <a href="#" className="flex items-center gap-2 font-mono text-sm font-semibold text-ctp-text">
            <span className="grid size-6 place-items-center rounded-md bg-ctp-mauve text-ctp-crust">
              <Terminal className="size-3.5" />
            </span>
            <span>
              workdeck<span className="text-ctp-mauve">.dev</span>
            </span>
          </a>
          <nav className="hidden items-center gap-6 text-sm text-ctp-subtext0 md:flex">
            <a href="#o-que-e" className="transition-colors hover:text-ctp-text">O que é</a>
            <a href="#como-funciona" className="transition-colors hover:text-ctp-text">Como funciona</a>
            <a href="#recursos" className="transition-colors hover:text-ctp-text">Recursos</a>
            <a href="#atalhos" className="transition-colors hover:text-ctp-text">Atalhos</a>
            <a href="#painel" className="transition-colors hover:text-ctp-text">Painel</a>
            <a href="#temas" className="transition-colors hover:text-ctp-text">Temas</a>
            <a href="#instalar" className="transition-colors hover:text-ctp-text">Instalar</a>
          </nav>
          <a href={repoUrl} target="_blank" rel="noreferrer" aria-label={showStars(stars) ? `GitHub, ${stars} estrelas` : "GitHub"} className={cn(buttonVariants({ variant: "outline", size: "sm" }), "gap-2")}>
            <GithubMark className="size-3.5" />
            {showStars(stars) ? <span className="font-mono tabular-nums">{formatStars(stars)}</span> : "GitHub"}
          </a>
        </div>
      </header>

      <main className="flex-1">
        <section className="relative overflow-hidden">
          <AnimatedGridPattern
            numSquares={36}
            maxOpacity={0.18}
            duration={3}
            className="[mask-image:radial-gradient(700px_circle_at_50%_30%,white,transparent)] inset-x-0 h-[130%] fill-ctp-mauve/20 stroke-ctp-surface0"
          />
          <div className="relative mx-auto grid max-w-6xl grid-cols-1 items-center gap-14 px-4 pt-20 pb-24 sm:px-6 lg:grid-cols-[1fr_1.15fr] lg:pt-28">
            <Reveal className="min-w-0">
              <a href={repoUrl} target="_blank" rel="noreferrer" className="group mb-6 inline-flex items-center rounded-full border border-ctp-surface0 bg-ctp-mantle/80 px-3 py-1 text-xs">
                <AnimatedShinyText className="mx-0 inline-flex items-center gap-1.5 text-ctp-subtext0 dark:via-ctp-text/90">
                  {version} · open source · MIT · macOS e Linux
                  <ArrowRight className="size-3 transition-transform group-hover:translate-x-0.5" />
                </AnimatedShinyText>
              </a>
              <h1 className="text-4xl leading-[1.05] font-semibold tracking-tight text-balance text-ctp-text sm:text-6xl">
                O terminal onde você e o <span className="text-gradient">agente de IA</span> trabalham lado a lado.
              </h1>
              <p className="mt-6 max-w-xl text-lg text-pretty text-ctp-subtext0">
                Uma sessão do tmux, uma janela por projeto, o agente num pane ao lado e o que você precisa olhar enquanto ele trabalha: o estado dos seus repositórios e um self code review antes do commit.
              </p>
              <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
                <a href="#instalar" className={cn(buttonVariants({ size: "lg" }), "h-11 gap-2 px-5 text-sm")}>
                  Instalar
                  <ArrowRight className="size-4" />
                </a>
                <a href={repoUrl} target="_blank" rel="noreferrer" className={cn(buttonVariants({ variant: "outline", size: "lg" }), "h-11 gap-2 px-5 text-sm")}>
                  <GithubMark className="size-4" />
                  Ver no GitHub
                </a>
              </div>
              <CommandLine command={installCommand} className="mt-8 max-w-xl" />
            </Reveal>
            <Reveal delay={0.15} className="min-w-0">
              <TerminalDemo />
            </Reveal>
          </div>
        </section>

        <Section id="o-que-e" eyebrow="o que é" title="Um fluxo de trabalho sobre o tmux" desc="O workdeck organiza o trabalho com agentes de IA de CLI. O tmux cuida das sessões, das janelas e dos painéis; o workdeck monta os projetos, o agente, o review e o contexto em cima dele.">
          <div className="grid gap-10 lg:grid-cols-[1fr_1.1fr]">
            <Reveal className="min-w-0">
              <ol className="flex flex-col gap-3">
                {layers.map((l, i) => (
                  <li
                    key={l.name}
                    className={cn(
                      "flex items-baseline gap-4 rounded-2xl border px-5 py-4",
                      i === 0 ? "border-ctp-mauve/60 bg-ctp-mauve/10" : "border-ctp-surface0 bg-ctp-mantle/70",
                    )}
                  >
                    <span className={cn("w-20 shrink-0 font-mono text-sm", i === 0 ? "text-ctp-mauve" : "text-ctp-text")}>{l.name}</span>
                    <span className="text-sm text-ctp-subtext0">{l.desc}</span>
                  </li>
                ))}
              </ol>
              <ul className="mt-8 grid gap-4 sm:grid-cols-2">
                {notThis.map((n) => (
                  <li key={n.title} className="flex items-start gap-3 text-sm">
                    <X className="mt-0.5 size-4 shrink-0 text-ctp-red" />
                    <div>
                      <p className="font-medium text-ctp-text">{n.title}</p>
                      <p className="mt-1 text-ctp-subtext0">{n.desc}</p>
                    </div>
                  </li>
                ))}
              </ul>
            </Reveal>
            <Reveal delay={0.1} className="min-w-0">
              <GlowCard>
                <div className="p-6">
                  <h3 className="mb-5 font-medium text-ctp-text">O que entra no workdeck</h3>
                  <ol className="flex flex-col gap-5">
                    {principles.map((p, i) => (
                      <li key={p.title} className="flex items-start gap-4 text-sm">
                        <span className="grid size-7 shrink-0 place-items-center rounded-full border border-ctp-surface1 font-mono text-xs text-ctp-mauve">{i + 1}</span>
                        <div>
                          <p className="font-medium text-ctp-text">{p.title}</p>
                          <p className="mt-1 text-ctp-subtext0">{p.desc}</p>
                        </div>
                      </li>
                    ))}
                  </ol>
                </div>
              </GlowCard>
            </Reveal>
          </div>
        </Section>

        <Section id="como-funciona" eyebrow="como funciona" title="Do projeto ao review" desc="Cada projeto é uma janela, o agente fica ao lado do seu shell e o review abre embaixo dele quando você pede.">
          <Reveal>
            <CycleDemo />
          </Reveal>
        </Section>

        <Section eyebrow="o dia a dia" title="Tudo o que você digita" desc="O resto está no menu: Ctrl+b e h, de dentro do work, com os seus projetos, as ações e os atalhos do dia a dia. Nada de alias para decorar.">
          <Stagger className="mx-auto flex max-w-5xl flex-wrap justify-center gap-3">
            {commands.map((c) => (
              <StaggerItem key={c.cmd} className="w-full sm:w-[calc(50%_-_0.375rem)] lg:w-[calc((100%_-_1.5rem)/3)]">
                <GlowCard className="rounded-xl">
                  <div className="p-5">
                    <code className="font-mono text-sm text-ctp-mauve">
                      <span className="text-ctp-overlay0">$ </span>
                      {c.cmd}
                    </code>
                    <p className="mt-2 text-sm text-ctp-subtext0">{c.desc}</p>
                  </div>
                </GlowCard>
              </StaggerItem>
            ))}
          </Stagger>
        </Section>

        <Section id="recursos" eyebrow="por que" title="Feito para quem trabalha com agentes" desc="O agente escreve código que você precisa ver. Com ele ao lado, o shell fica no outro painel para rodar os testes e o work review sem trocar de contexto.">
          <Stagger className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {features.map((f) => {
              const Icon = icons[f.icon]
              return (
                <StaggerItem key={f.title}>
                  <GlowCard>
                    <div className="p-6">
                      <div className="mb-4 grid size-10 place-items-center rounded-lg border border-ctp-surface0 bg-ctp-base text-ctp-mauve">
                        <Icon className="size-5" />
                      </div>
                      <h3 className="font-medium text-ctp-text">{f.title}</h3>
                      <p className="mt-2 text-sm leading-relaxed text-ctp-subtext0">{f.desc}</p>
                    </div>
                  </GlowCard>
                </StaggerItem>
              )
            })}
          </Stagger>
        </Section>

        <Section id="atalhos" eyebrow="teclado" title="Ctrl+b e uma tecla" desc="Aperte Ctrl+b, solte e aperte a tecla. Quem interpreta é o tmux, não o terminal, e o mouse também funciona: clique na janela na barra ou arraste a borda do painel.">
          <Reveal>
            <ShortcutList />
          </Reveal>
        </Section>

        <Section id="painel" eyebrow="painel" title="O que você quer ver enquanto o agente trabalha" desc="A janela 1 é o painel: a branch e as mudanças de cada projeto, e o que mais você quiser. Cada bloco é um executável em ~/.config/workdeck/panels/, e o que ele imprimir aparece ali.">
          <div className="grid items-center gap-10 lg:grid-cols-[1.15fr_1fr]">
            <Reveal className="min-w-0">
              <PanelDemo />
            </Reveal>
            <Reveal delay={0.1} className="min-w-0 space-y-4">
              <p className="text-sm text-ctp-subtext0">
                Containers, PRs abertos, o build do CI, as tarefas do dia. Qualquer linguagem serve, Bash, Python, Node ou um binário, desde que imprima texto. Não precisa reinstalar nem reiniciar: o painel relê a pasta a cada ciclo, de 60 em 60 segundos.
              </p>
              <dl className="grid gap-x-5 gap-y-3 rounded-2xl border border-border bg-ctp-mantle/70 p-5 text-sm sm:grid-cols-[auto_1fr]">
                {panelRules.map((r) => (
                  <div key={r.code} className="contents">
                    <dt className="font-mono text-ctp-mauve">{r.code}</dt>
                    <dd className="text-ctp-subtext0">{r.desc}</dd>
                  </div>
                ))}
              </dl>
              <div className="flex items-start gap-3 rounded-2xl border border-dashed border-ctp-surface1 p-5 text-sm text-ctp-subtext0">
                <KeyRound className="mt-0.5 size-4 shrink-0 text-ctp-yellow" />
                <p>
                  Painel que fala com uma API? Deixe o token fora do script, num arquivo em <code className="font-mono text-ctp-text">~/.config/workdeck/</code>. Assim o painel pode ser compartilhado e as credenciais continuam só suas.
                </p>
              </div>
              <a href={panelsUrl} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-sm text-ctp-mauve transition-colors hover:text-ctp-text">
                Mais sobre painéis
                <ArrowRight className="size-3.5" />
              </a>
            </Reveal>
          </div>
        </Section>

        <Section id="temas" eyebrow="cores" title="Três temas para começar" desc="Em fundo escuro, texto acima de 11:1 cansa em sessão longa. Vermelho e verde precisam se separar também em luminosidade, senão o diff fica difícil de ler.">
          <Reveal>
            <ThemePreview />
          </Reveal>
        </Section>

        <Section id="instalar" eyebrow="instalar" title="Um script, e ele desfaz o que fez" desc="Uma linha, sem clonar nada. Funciona no macOS e no Linux, inclusive no WSL. O instalador detecta o sistema e o gerenciador de pacotes e instala o tmux, se faltar, e o kitty, já com tema e fonte. Depois, o work update avisa e traz as versões novas.">
          <Reveal className="mx-auto max-w-3xl">
            <InstallTabs />
            <p className="mt-4 text-center text-sm text-ctp-subtext0">
              No fim, abra o kitty, ou feche e abra, se a instalação rodou nele, para ele carregar o <code className="font-mono text-ctp-subtext1">work</code>. Quer ler o script antes? Baixe com <code className="font-mono text-ctp-subtext1">-o get.sh</code> em vez de <code className="font-mono text-ctp-subtext1">| bash</code>.
            </p>
          </Reveal>
          <Reveal className="mx-auto mt-10 max-w-3xl">
            <GlowCard>
              <div className="p-6">
                <div className="mb-4 flex items-center gap-2 text-ctp-text">
                  <Undo2 className="size-4 text-ctp-green" />
                  <h3 className="font-medium">Desinstalar devolve tudo</h3>
                </div>
                <p className="mb-5 text-sm text-ctp-subtext0">
                  Antes de tocar num arquivo pela primeira vez, o instalador guarda uma cópia e anota o que fez num manifesto. Seu <code className="font-mono text-ctp-subtext1">.tmux.conf</code> e seu <code className="font-mono text-ctp-subtext1">.zshrc</code> voltam byte a byte. Para tirar menos, use o <code className="font-mono text-ctp-subtext1">uninstall.sh</code> direto, em <code className="font-mono text-ctp-subtext1">~/.local/share/workdeck</code>, com <code className="font-mono text-ctp-subtext1">bash</code>.
                </p>
                <dl className="grid gap-x-6 gap-y-3 font-mono text-sm sm:grid-cols-[auto_1fr]">
                  {uninstall.map((u) => (
                    <div key={u.cmd} className="contents">
                      <dt className="text-ctp-text">{u.cmd}</dt>
                      <dd className="font-sans text-ctp-subtext0">{u.desc}</dd>
                    </div>
                  ))}
                </dl>
              </div>
            </GlowCard>
          </Reveal>
          <Reveal className="mx-auto mt-6 flex max-w-3xl items-start gap-3 rounded-2xl border border-dashed border-ctp-surface1 p-5 text-sm text-ctp-subtext0">
            <LayoutPanelLeft className="mt-0.5 size-4 shrink-0 text-ctp-teal" />
            <p>
              Depois de instalar, o painel, a janela 1 do work, mostra o que falta: adicionar os projetos com <code className="font-mono text-ctp-text">work add</code>, uma versão nova para o <code className="font-mono text-ctp-text">work update</code> e se você abriu fora do kitty.
            </p>
          </Reveal>
        </Section>

        <section className="mx-auto w-full max-w-4xl px-4 pb-28 sm:px-6">
          <Reveal className="relative overflow-hidden rounded-3xl border border-ctp-surface0 bg-ctp-mantle px-6 py-14 text-center sm:px-12">
            <div className="absolute inset-0 -z-0 bg-[radial-gradient(50%_80%_at_50%_0%,color-mix(in_oklch,var(--catppuccin-color-mauve)_18%,transparent),transparent)]" />
            <div className="relative">
              <h2 className="text-3xl font-semibold tracking-tight text-balance text-ctp-text sm:text-4xl">Um ponto de partida, não um produto.</h2>
              <p className="mx-auto mt-4 max-w-xl text-pretty text-ctp-subtext0">
                Ele não traz os seus projetos, os seus painéis nem o seu tema: traz a estrutura para você montar os seus. Use, copie, dê fork, mude o que precisar.
              </p>
              <CommandLine command={installCommand} className="mx-auto mt-8 max-w-xl text-left" />
            </div>
          </Reveal>
        </section>
      </main>

      <footer className="border-t border-ctp-surface0/60">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-3 px-4 py-8 text-sm text-ctp-overlay1 sm:flex-row sm:px-6">
          <span className="font-mono">workdeck · licença MIT</span>
          <a href={repoUrl} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 transition-colors hover:text-ctp-text">
            <GithubMark className="size-4" />
            código no GitHub
          </a>
        </div>
      </footer>
    </>
  )
}
