"use client"

import { useEffect, useState } from "react"
import { AnimatePresence, motion, useReducedMotion } from "motion/react"
import { BorderBeam } from "@/components/ui/border-beam"
import { cn } from "@/lib/utils"

const timeline = [700, 900, 800, 700, 1600, 700, 600, 700, 900, 1100, 900, 5200]
const last = timeline.length

function Typed({ text, speed = 55 }: { text: string; speed?: number }) {
  const [count, setCount] = useState(0)
  useEffect(() => {
    const id = setInterval(() => {
      setCount((c) => {
        if (c >= text.length) {
          clearInterval(id)
          return c
        }
        return c + 1
      })
    }, speed)
    return () => clearInterval(id)
  }, [text, speed])
  return <>{text.slice(0, count)}</>
}

function Caret({ show }: { show: boolean }) {
  if (!show) return null
  return (
    <motion.span
      className="ml-px inline-block h-[1.05em] w-[0.55em] translate-y-[0.15em] bg-ctp-text"
      animate={{ opacity: [1, 1, 0, 0] }}
      transition={{ duration: 1, repeat: Infinity, times: [0, 0.5, 0.5, 1] }}
    />
  )
}

function Prompt({ text, typing, done, caret }: { text: string; typing: boolean; done: boolean; caret: boolean }) {
  return (
    <div className="whitespace-pre">
      <span className="text-ctp-green">~/projetos/web</span>
      <span className="text-ctp-mauve"> ❯ </span>
      <span className="text-ctp-text">{done ? text : typing ? <Typed text={text} /> : null}</span>
      <Caret show={caret} />
    </div>
  )
}

function Line({ children, className, delay = 0 }: { children: React.ReactNode; className?: string; delay?: number }) {
  return (
    <motion.div
      className={cn("whitespace-pre", className)}
      initial={{ opacity: 0, x: -6 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.25, delay }}
    >
      {children}
    </motion.div>
  )
}

function Pane({ title, active, children, className }: { title: string; active: boolean; children: React.ReactNode; className?: string }) {
  return (
    <motion.div
      layout
      initial={{ opacity: 0, scale: 0.97 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.97 }}
      transition={{ layout: { duration: 0.5, ease: [0.22, 1, 0.36, 1] }, duration: 0.35 }}
      className={cn(
        "relative flex min-h-0 flex-col overflow-hidden rounded-md border bg-ctp-base/70 transition-colors duration-500",
        active ? "border-ctp-overlay0" : "border-ctp-surface0",
        className
      )}
    >
      <div className="flex items-center justify-between border-b border-ctp-surface0/80 px-3 py-1 text-[10px] tracking-wide text-ctp-overlay0 uppercase">
        <span>{title}</span>
        {active && <motion.span layoutId="active-dot" className="size-1.5 rounded-full bg-ctp-mauve" />}
      </div>
      <div className="min-h-0 flex-1 space-y-0.5 overflow-hidden p-3">{children}</div>
    </motion.div>
  )
}

export function TerminalDemo() {
  const reduce = useReducedMotion()
  const [step, setStep] = useState(0)
  const s = reduce ? last : step

  useEffect(() => {
    if (reduce) return
    const id = setTimeout(() => setStep((v) => (v >= last ? 0 : v + 1)), timeline[Math.min(step, last - 1)])
    return () => clearTimeout(id)
  }, [step, reduce])

  const agentOpen = s >= 3
  const reviewOpen = s >= 7
  const focus = s >= 7 ? "review" : s >= 3 ? "agent" : "shell"

  return (
    <div className="relative">
      <div className="absolute -inset-8 -z-10 rounded-[2rem] bg-[radial-gradient(60%_60%_at_50%_40%,color-mix(in_oklch,var(--catppuccin-color-mauve)_22%,transparent),transparent)] blur-2xl" />
      <div className="relative overflow-hidden rounded-2xl border border-ctp-surface0 bg-ctp-mantle/90 shadow-2xl shadow-black/50 backdrop-blur">
        <BorderBeam size={120} duration={9} colorFrom="var(--catppuccin-color-mauve)" colorTo="var(--catppuccin-color-blue)" />
        <div className="flex items-center gap-2 border-b border-ctp-surface0 px-4 py-2.5">
          <span className="size-3 rounded-full bg-ctp-red/80" />
          <span className="size-3 rounded-full bg-ctp-yellow/80" />
          <span className="size-3 rounded-full bg-ctp-green/80" />
          <span className="ml-3 font-mono text-xs text-ctp-overlay0">workdeck — tmux</span>
        </div>

        <div className="grid h-[560px] grid-rows-[1fr_auto] gap-0 font-mono text-[11.5px] leading-relaxed sm:h-[380px] sm:text-xs">
          <motion.div layout className={cn("grid min-h-0 gap-1.5 p-1.5", agentOpen ? "grid-cols-1 grid-rows-[1.4fr_1fr] sm:grid-cols-2 sm:grid-rows-1" : "grid-cols-1")}>
            <motion.div layout className={cn("grid min-h-0 gap-1.5", reviewOpen ? "grid-rows-[auto_1fr]" : "grid-rows-1")}>
              <Pane title="shell" active={focus === "shell"}>
                <Prompt text="work" typing={s === 0} done={s >= 1} caret={s === 0} />
                {s >= 1 && (
                  <Line className="text-ctp-overlay1">
                    sessão <span className="text-ctp-mauve">workdeck</span> · 4 janelas
                  </Line>
                )}
                {s >= 2 && <Prompt text="ai" typing={s === 2} done={s >= 3} caret={s === 2} />}
                {s >= 3 && !reviewOpen && <Line className="text-ctp-overlay1">agente aberto ao lado →</Line>}
                {s >= 6 && <Prompt text="git review" typing={s === 6} done={s >= 7} caret={s === 6} />}
              </Pane>
              <AnimatePresence>
                {reviewOpen && (
                  <Pane key="review" title="git review" active={focus === "review"}>
                    <Line>
                      <span className="font-bold text-ctp-sky">git review</span>
                      <span className="font-bold text-ctp-text">  feature/login</span>
                    </Line>
                    {s >= 8 && (
                      <>
                        <Line className="text-ctp-subtext0" delay={0.05}> src/auth/login.ts   | 9 <span className="text-ctp-green">+++++++</span><span className="text-ctp-red">--</span></Line>
                        <Line className="text-ctp-subtext0" delay={0.12}> src/auth/email.ts   <span className="text-ctp-green">(novo, 6 linhas)</span></Line>
                      </>
                    )}
                    {s >= 9 && (
                      <>
                        <Line className="mt-1 text-ctp-overlay0" delay={0}>  12 │ export function login(form) {"{"}</Line>
                        <Line className="bg-ctp-red/10 text-ctp-red" delay={0.08}>- 13 │   return auth(form)</Line>
                        <Line className="bg-ctp-green/10 text-ctp-green" delay={0.16}>+ 13 │   if (!isEmail(form.email)) throw …</Line>
                        <Line className="bg-ctp-green/10 text-ctp-green" delay={0.24}>+ 14 │   return auth(form)</Line>
                      </>
                    )}
                    {s >= 10 && (
                      <Line className="mt-1 text-ctp-text" delay={0}>
                        <span className="font-bold">2 arquivo(s)</span>  <span className="text-ctp-green">+13</span>  <span className="text-ctp-red">-2</span>
                      </Line>
                    )}
                  </Pane>
                )}
              </AnimatePresence>
            </motion.div>

            <AnimatePresence>
              {agentOpen && (
                <Pane key="agent" title="agente" active={focus === "agent"}>
                  <Line className="text-ctp-overlay0">o comando que você escolheu</Line>
                  <Line>
                    <span className="text-ctp-peach">› </span>
                    <span className="text-ctp-text">valida o e-mail no login</span>
                  </Line>
                  {s >= 4 && (
                    <>
                      <Line className="text-ctp-subtext0" delay={0.1}>  lendo src/auth/login.ts</Line>
                      <Line className="text-ctp-subtext0" delay={0.5}>  criando src/auth/email.ts</Line>
                      <Line className="text-ctp-subtext0" delay={0.9}>  editando src/auth/login.ts</Line>
                    </>
                  )}
                  {s >= 5 && <Line className="text-ctp-green">  ✓ pronto. revise antes de commitar.</Line>}
                </Pane>
              )}
            </AnimatePresence>
          </motion.div>

          <div className="flex items-center justify-between bg-ctp-mantle px-2 py-1 text-[11px]">
            <div className="flex items-center gap-1">
              <span className="px-1.5 font-bold text-ctp-mauve">workdeck</span>
              {["api", "web", "notas", "painel"].map((w, i) => (
                <span key={w} className="relative px-1.5 py-0.5 text-ctp-overlay1">
                  {i === 1 && <motion.span layoutId="win" className="absolute inset-0 rounded-sm bg-ctp-surface0" />}
                  <span className={cn("relative", i === 1 && "font-bold text-ctp-text")}>
                    {i + 1}:{w}
                  </span>
                </span>
              ))}
            </div>
            <span className="hidden text-ctp-overlay0 sm:inline">Alt+1…9 troca de janela</span>
          </div>
        </div>
      </div>
    </div>
  )
}
