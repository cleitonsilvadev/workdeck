import { notFound } from "next/navigation"
import { ArrowRight, Info, KeyRound, Terminal, Undo2 } from "lucide-react"
import { AnimatedGridPattern } from "@/components/ui/animated-grid-pattern"
import { AnimatedShinyText } from "@/components/ui/animated-shiny-text"
import { buttonVariants } from "@/components/ui/button"
import { CommandLine } from "@/components/copy-button"
import { CycleDemo } from "@/components/cycle-demo"
import { GlowCard } from "@/components/glow-card"
import { InstallTabs } from "@/components/install-tabs"
import { LanguageSwitcher } from "@/components/language-switcher"
import { PanelDemo } from "@/components/panel-demo"
import { Reveal, Stagger, StaggerItem } from "@/components/reveal"
import { ShortcutList } from "@/components/shortcut-list"
import { TerminalDemo } from "@/components/terminal-demo"
import { TerminalTable } from "@/components/terminal-table"
import { getDictionary } from "@/lib/dictionaries"
import { hasLocale } from "@/lib/i18n"
import { installCommand, repoUrl, version } from "@/lib/site"
import { getStars } from "@/lib/github"
import { formatStars, showStars } from "@/lib/stars"
import { cn } from "@/lib/utils"

function GithubMark({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={className} fill="currentColor">
      <path d="M12 .5a11.5 11.5 0 0 0-3.64 22.41c.58.1.79-.25.79-.56v-2c-3.2.7-3.88-1.37-3.88-1.37-.53-1.33-1.28-1.69-1.28-1.69-1.05-.71.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.77 2.7 1.26 3.36.96.1-.75.4-1.26.73-1.55-2.55-.29-5.24-1.28-5.24-5.69 0-1.26.45-2.28 1.19-3.09-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.17 1.18a11 11 0 0 1 5.77 0c2.2-1.49 3.17-1.18 3.17-1.18.63 1.59.23 2.76.11 3.05.74.81 1.19 1.83 1.19 3.09 0 4.42-2.69 5.39-5.26 5.68.41.36.78 1.06.78 2.14v3.17c0 .31.21.67.8.56A11.5 11.5 0 0 0 12 .5Z" />
    </svg>
  )
}

function Rich({ parts, code }: { parts: readonly string[]; code: string }) {
  return parts.map((p, i) => (i % 2 ? <code key={i} className={code}>{p}</code> : p))
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

export default async function Home({ params }: PageProps<"/[lang]">) {
  const { lang } = await params
  if (!hasLocale(lang)) notFound()
  const t = getDictionary(lang)
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
            <a href="#como-funciona" className="transition-colors hover:text-ctp-text">{t.nav.how}</a>
            <a href="#terminais" className="transition-colors hover:text-ctp-text">{t.nav.terminals}</a>
            <a href="#atalhos" className="transition-colors hover:text-ctp-text">{t.nav.shortcuts}</a>
            <a href="#painel" className="transition-colors hover:text-ctp-text">{t.nav.panel}</a>
            <a href="#instalar" className="transition-colors hover:text-ctp-text">{t.nav.install}</a>
          </nav>
          <div className="flex items-center gap-2">
            <LanguageSwitcher current={lang} label={t.language.label} names={t.language.names} />
            <a href={repoUrl} target="_blank" rel="noreferrer" aria-label={showStars(stars) ? t.github.stars(stars) : "GitHub"} className={cn(buttonVariants({ variant: "outline", size: "sm" }), "gap-2")}>
              <GithubMark className="size-3.5" />
              {showStars(stars) ? <span className="font-mono tabular-nums">{formatStars(stars)}</span> : "GitHub"}
            </a>
          </div>
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
                  {version} · {t.hero.badge}
                  <ArrowRight className="size-3 transition-transform group-hover:translate-x-0.5" />
                </AnimatedShinyText>
              </a>
              <h1 className="text-4xl leading-[1.05] font-semibold tracking-tight text-balance text-ctp-text sm:text-6xl">
                {t.hero.titleBefore}<span className="text-gradient">{t.hero.titleHighlight}</span>{t.hero.titleAfter}
              </h1>
              <p className="mt-6 max-w-xl text-lg text-pretty text-ctp-subtext0">
                {t.hero.subtitle}
              </p>
              {t.hero.notice && (
                <p className="mt-4 flex max-w-xl items-start gap-2 text-sm text-ctp-overlay1">
                  <Info className="mt-0.5 size-4 shrink-0 text-ctp-blue" />
                  {t.hero.notice}
                </p>
              )}
              <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
                <a href="#instalar" className={cn(buttonVariants({ size: "lg" }), "h-11 gap-2 px-5 text-sm")}>
                  {t.hero.install}
                  <ArrowRight className="size-4" />
                </a>
                <a href={repoUrl} target="_blank" rel="noreferrer" className={cn(buttonVariants({ variant: "outline", size: "lg" }), "h-11 gap-2 px-5 text-sm")}>
                  <GithubMark className="size-4" />
                  {t.github.view}
                </a>
              </div>
              <CommandLine command={installCommand} labels={t.copy} className="mt-8 max-w-xl" />
            </Reveal>
            <Reveal delay={0.15} className="min-w-0">
              <TerminalDemo demo={t.demo} />
            </Reveal>
          </div>
        </section>

        <Section id="como-funciona" eyebrow={t.how.eyebrow} title={t.how.title} desc={t.how.desc}>
          <Reveal>
            <CycleDemo cycle={t.cycle} demo={t.demo} />
          </Reveal>
          <Reveal className="mx-auto mt-12 max-w-2xl">
            <ol className="flex flex-col gap-3">
              {t.layers.map((l, i) => (
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
          </Reveal>
        </Section>

        <Section eyebrow={t.commandsSection.eyebrow} title={t.commandsSection.title} desc={t.commandsSection.desc}>
          <Stagger className="mx-auto flex max-w-5xl flex-wrap justify-center gap-3">
            {t.commands.map((c) => (
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

        <Section id="terminais" eyebrow={t.terminalsSection.eyebrow} title={t.terminalsSection.title} desc={t.terminalsSection.desc}>
          <Reveal className="mx-auto max-w-4xl">
            <TerminalTable terminals={t.terminals} />
          </Reveal>
        </Section>

        <Section id="atalhos" eyebrow={t.shortcutsSection.eyebrow} title={t.shortcutsSection.title} desc={t.shortcutsSection.desc}>
          <Reveal>
            <ShortcutList shortcuts={t.shortcuts} />
          </Reveal>
        </Section>

        <Section id="painel" eyebrow={t.panelSection.eyebrow} title={t.panelSection.title} desc={t.panelSection.desc}>
          <div className="grid items-center gap-10 lg:grid-cols-[1.15fr_1fr]">
            <Reveal className="min-w-0">
              <PanelDemo demo={t.demo} />
            </Reveal>
            <Reveal delay={0.1} className="min-w-0 space-y-4">
              <p className="text-sm text-ctp-subtext0">
                {t.panelSection.body}
              </p>
              <dl className="grid gap-x-5 gap-y-3 rounded-2xl border border-border bg-ctp-mantle/70 p-5 text-sm sm:grid-cols-[auto_1fr]">
                {t.panelRules.map((r) => (
                  <div key={r.code} className="contents">
                    <dt className="font-mono text-ctp-mauve">{r.code}</dt>
                    <dd className="text-ctp-subtext0">{r.desc}</dd>
                  </div>
                ))}
              </dl>
              <div className="flex items-start gap-3 rounded-2xl border border-dashed border-ctp-surface1 p-5 text-sm text-ctp-subtext0">
                <KeyRound className="mt-0.5 size-4 shrink-0 text-ctp-yellow" />
                <p>
                  <Rich parts={t.panelSection.token} code="font-mono text-ctp-text" />
                </p>
              </div>
              <a href={t.panelSection.url} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-sm text-ctp-mauve transition-colors hover:text-ctp-text">
                {t.panelSection.more}
                <ArrowRight className="size-3.5" />
              </a>
            </Reveal>
          </div>
        </Section>

        <Section id="instalar" eyebrow={t.installSection.eyebrow} title={t.installSection.title} desc={t.installSection.desc}>
          <Reveal className="mx-auto max-w-3xl">
            <InstallTabs install={t.install} labels={t.copy} />
            <p className="mt-4 text-center text-sm text-ctp-subtext0">
              <Rich parts={t.installSection.after} code="font-mono text-ctp-subtext1" />
            </p>
          </Reveal>
          <Reveal className="mx-auto mt-10 max-w-3xl">
            <GlowCard>
              <div className="p-6">
                <div className="mb-4 flex items-center gap-2 text-ctp-text">
                  <Undo2 className="size-4 text-ctp-green" />
                  <h3 className="font-medium">{t.installSection.uninstallTitle}</h3>
                </div>
                <p className="mb-5 text-sm text-ctp-subtext0">
                  <Rich parts={t.installSection.uninstallText} code="font-mono text-ctp-subtext1" />
                </p>
                <dl className="grid gap-x-6 gap-y-3 font-mono text-sm sm:grid-cols-[auto_1fr]">
                  {t.uninstall.map((u) => (
                    <div key={u.cmd} className="contents">
                      <dt className="text-ctp-text">{u.cmd}</dt>
                      <dd className="font-sans text-ctp-subtext0">{u.desc}</dd>
                    </div>
                  ))}
                </dl>
              </div>
            </GlowCard>
          </Reveal>
        </Section>

        <section className="mx-auto w-full max-w-4xl px-4 pb-28 sm:px-6">
          <Reveal className="relative overflow-hidden rounded-3xl border border-ctp-surface0 bg-ctp-mantle px-6 py-14 text-center sm:px-12">
            <div className="absolute inset-0 -z-0 bg-[radial-gradient(50%_80%_at_50%_0%,color-mix(in_oklch,var(--catppuccin-color-mauve)_18%,transparent),transparent)]" />
            <div className="relative">
              <h2 className="text-3xl font-semibold tracking-tight text-balance text-ctp-text sm:text-4xl">{t.cta.title}</h2>
              <p className="mx-auto mt-4 max-w-xl text-pretty text-ctp-subtext0">
                {t.cta.text}
              </p>
              <CommandLine command={installCommand} labels={t.copy} className="mx-auto mt-8 max-w-xl text-left" />
            </div>
          </Reveal>
        </section>
      </main>

      <footer className="border-t border-ctp-surface0/60">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-3 px-4 py-8 text-sm text-ctp-overlay1 sm:flex-row sm:px-6">
          <span className="font-mono">{t.footer.license}</span>
          <a href={repoUrl} target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 transition-colors hover:text-ctp-text">
            <GithubMark className="size-4" />
            {t.github.code}
          </a>
        </div>
      </footer>
    </>
  )
}
