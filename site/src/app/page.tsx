import { ArrowRight, Bot, History, LayoutPanelLeft, Palette, Stethoscope, Terminal, Undo2 } from "lucide-react"
import { AnimatedGridPattern } from "@/components/ui/animated-grid-pattern"
import { AnimatedShinyText } from "@/components/ui/animated-shiny-text"
import { buttonVariants } from "@/components/ui/button"
import { ComingSoon } from "@/components/coming-soon"
import { CommandLine } from "@/components/copy-button"
import { GlowCard } from "@/components/glow-card"
import { InstallTabs } from "@/components/install-tabs"
import { Reveal, Stagger, StaggerItem } from "@/components/reveal"
import { ShortcutList } from "@/components/shortcut-list"
import { TerminalDemo } from "@/components/terminal-demo"
import { Testimonials } from "@/components/testimonials"
import { ThemePreview } from "@/components/theme-preview"
import { commands, features, installCommand, released, repoUrl, uninstall } from "@/lib/site"
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

export default function Home() {
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
            <a href="#recursos" className="transition-colors hover:text-ctp-text">Recursos</a>
            <a href="#atalhos" className="transition-colors hover:text-ctp-text">Atalhos</a>
            <a href="#temas" className="transition-colors hover:text-ctp-text">Temas</a>
            <a href="#instalar" className="transition-colors hover:text-ctp-text">Instalar</a>
          </nav>
          {released ? (
            <a href={repoUrl} target="_blank" rel="noreferrer" className={cn(buttonVariants({ variant: "outline", size: "sm" }), "gap-2")}>
              <GithubMark className="size-3.5" />
              GitHub
            </a>
          ) : (
            <span className="rounded-full border border-ctp-surface0 px-3 py-1 font-mono text-xs text-ctp-subtext0">em breve</span>
          )}
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
              {released ? (
                <a href={repoUrl} target="_blank" rel="noreferrer" className="group mb-6 inline-flex items-center rounded-full border border-ctp-surface0 bg-ctp-mantle/80 px-3 py-1 text-xs">
                  <AnimatedShinyText className="mx-0 inline-flex items-center gap-1.5 text-ctp-subtext0 dark:via-ctp-text/90">
                    open source · MIT · macOS, Linux e WSL
                    <ArrowRight className="size-3 transition-transform group-hover:translate-x-0.5" />
                  </AnimatedShinyText>
                </a>
              ) : (
                <span className="mb-6 inline-flex items-center rounded-full border border-ctp-surface0 bg-ctp-mantle/80 px-3 py-1 text-xs">
                  <AnimatedShinyText className="mx-0 inline-flex items-center gap-1.5 text-ctp-subtext0 dark:via-ctp-text/90">
                    em breve · macOS, Linux e WSL
                  </AnimatedShinyText>
                </span>
              )}
              <h1 className="text-4xl leading-[1.05] font-semibold tracking-tight text-balance text-ctp-text sm:text-6xl">
                O terminal onde você e o <span className="text-gradient">agente de IA</span> trabalham lado a lado.
              </h1>
              <p className="mt-6 max-w-xl text-lg text-pretty text-ctp-subtext0">
                Uma sessão do tmux, uma janela por projeto, o agente num pane ao lado e o que você precisa olhar enquanto ele trabalha: o diff do que ele escreveu e o estado dos seus repositórios.
              </p>
              <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
                <a href="#instalar" className={cn(buttonVariants({ size: "lg" }), "h-11 gap-2 px-5 text-sm")}>
                  Instalar
                  <ArrowRight className="size-4" />
                </a>
                {released && (
                  <a href={repoUrl} target="_blank" rel="noreferrer" className={cn(buttonVariants({ variant: "outline", size: "lg" }), "h-11 gap-2 px-5 text-sm")}>
                    <GithubMark className="size-4" />
                    Ver no GitHub
                  </a>
                )}
              </div>
              {released ? <CommandLine command={installCommand} className="mt-8 max-w-xl" /> : <ComingSoon className="mt-8 max-w-xl" />}
            </Reveal>
            <Reveal delay={0.15} className="min-w-0">
              <TerminalDemo />
            </Reveal>
          </div>
        </section>

        <Section eyebrow="o dia a dia" title="Tudo o que você digita" desc="O resto está no menu: Ctrl+b e h, de dentro do work. Nada de alias para decorar.">
          <Stagger className="mx-auto grid max-w-5xl gap-3 sm:grid-cols-2 lg:grid-cols-4">
            {commands.map((c) => (
              <StaggerItem key={c.cmd}>
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

        <Section id="recursos" eyebrow="por que" title="Feito para quem trabalha com agentes" desc="O agente escreve código que você precisa ver. Com ele ao lado, o work review roda no pane de baixo sem trocar de contexto.">
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

        <Section id="atalhos" eyebrow="teclado" title="Ctrl+b e uma tecla, em qualquer terminal" desc="Aperte Ctrl+b, solte e aperte a tecla. Quem interpreta é o tmux, não o terminal, e o mouse também funciona: clique na janela na barra ou arraste a borda do painel.">
          <Reveal>
            <ShortcutList />
          </Reveal>
        </Section>

        <Section id="temas" eyebrow="cores" title="Três temas para começar" desc="Em fundo escuro, texto acima de 11:1 cansa em sessão longa. Vermelho e verde precisam se separar também em luminosidade, senão o diff fica difícil de ler.">
          <Reveal>
            <ThemePreview />
          </Reveal>
        </Section>

        <Section id="instalar" eyebrow="instalar" title="Um script, e ele desfaz o que fez" desc="O instalador detecta o sistema e o gerenciador de pacotes e instala o que faltar: tmux e git-delta. É idempotente; rodar de novo atualiza em vez de duplicar.">
          <Reveal className="mx-auto max-w-3xl">
            {released ? <InstallTabs /> : <ComingSoon />}
          </Reveal>
          <Reveal className="mx-auto mt-10 max-w-3xl">
            <GlowCard>
              <div className="p-6">
                <div className="mb-4 flex items-center gap-2 text-ctp-text">
                  <Undo2 className="size-4 text-ctp-green" />
                  <h3 className="font-medium">Desinstalar devolve tudo</h3>
                </div>
                <p className="mb-5 text-sm text-ctp-subtext0">
                  Antes de tocar num arquivo pela primeira vez, o instalador guarda uma cópia e anota o que fez num manifesto. Seu <code className="font-mono text-ctp-subtext1">.tmux.conf</code> e seu <code className="font-mono text-ctp-subtext1">.zshrc</code> voltam byte a byte.
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
            <Stethoscope className="mt-0.5 size-4 shrink-0 text-ctp-teal" />
            <p>
              Antes de abrir uma issue, rode <code className="font-mono text-ctp-text">work doctor</code>: ele diz se o tmux e o delta estão instalados, se o terminal suporta cores de 24 bits, se há um agente configurado e se o <code className="font-mono text-ctp-text">~/.local/bin</code> está no PATH.
            </p>
          </Reveal>
        </Section>

        <Section id="quem-usa" eyebrow="quem usa" title="O que mudou no dia a dia">
          <Reveal>
            <Testimonials />
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
              {released ? <CommandLine command={installCommand} className="mx-auto mt-8 max-w-xl text-left" /> : <ComingSoon className="mx-auto mt-8 max-w-xl text-left" />}
            </div>
          </Reveal>
        </section>
      </main>

      <footer className="border-t border-ctp-surface0/60">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-3 px-4 py-8 text-sm text-ctp-overlay1 sm:flex-row sm:px-6">
          <span className="font-mono">workdeck · licença MIT</span>
          {released && (
            <a href={repoUrl} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 transition-colors hover:text-ctp-text">
              <GithubMark className="size-4" />
              código no GitHub
            </a>
          )}
        </div>
      </footer>
    </>
  )
}
