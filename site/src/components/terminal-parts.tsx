"use client"

import { useEffect, useId, useState } from "react"
import { LayoutGroup, motion, useReducedMotion } from "motion/react"
import { BorderBeam } from "@/components/ui/border-beam"
import { cn } from "@/lib/utils"

export function Typed({ text, speed = 55 }: { text: string; speed?: number }) {
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

export function Caret({ show }: { show: boolean }) {
  if (!show) return null
  return (
    <motion.span
      className="ml-px inline-block h-[1.05em] w-[0.55em] translate-y-[0.15em] bg-ctp-text"
      animate={{ opacity: [1, 1, 0, 0] }}
      transition={{ duration: 1, repeat: Infinity, times: [0, 0.5, 0.5, 1] }}
    />
  )
}

export function Prompt({ text, typing, done, caret, path = "~/projetos/web", speed }: { text: string; typing: boolean; done: boolean; caret: boolean; path?: string; speed?: number }) {
  return (
    <div className="whitespace-pre">
      <span className="text-ctp-green">{path}</span>
      <span className="text-ctp-mauve"> ❯ </span>
      <span className="text-ctp-text">{done ? text : typing ? <Typed text={text} speed={speed} /> : null}</span>
      <Caret show={caret} />
    </div>
  )
}

export function Line({ children, className, delay = 0 }: { children: React.ReactNode; className?: string; delay?: number }) {
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

export function Pane({ title, active, children, className }: { title: string; active: boolean; children: React.ReactNode; className?: string }) {
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

export function TerminalWindow({ children, title = "workdeck — tmux" }: { children: React.ReactNode; title?: string }) {
  const id = useId()
  return (
    <div className="relative">
      <div className="absolute -inset-8 -z-10 rounded-[2rem] bg-[radial-gradient(60%_60%_at_50%_40%,color-mix(in_oklch,var(--catppuccin-color-mauve)_22%,transparent),transparent)] blur-2xl" />
      <div className="relative overflow-hidden rounded-2xl border border-ctp-surface0 bg-ctp-mantle/90 shadow-2xl shadow-black/50 backdrop-blur">
        <BorderBeam size={120} duration={9} colorFrom="var(--catppuccin-color-mauve)" colorTo="var(--catppuccin-color-blue)" />
        <div className="flex items-center gap-2 border-b border-ctp-surface0 px-4 py-2.5">
          <span className="size-3 rounded-full bg-ctp-red/80" />
          <span className="size-3 rounded-full bg-ctp-yellow/80" />
          <span className="size-3 rounded-full bg-ctp-green/80" />
          <span className="ml-3 font-mono text-xs text-ctp-overlay0">{title}</span>
        </div>
        <LayoutGroup id={id}>{children}</LayoutGroup>
      </div>
    </div>
  )
}

export function StatusBar({ windows, active, mark, branch }: { windows: readonly string[]; active: number; mark?: boolean; branch?: string }) {
  return (
    <div className="flex items-center justify-between gap-3 bg-ctp-mantle py-1 pr-2 text-[11px] whitespace-pre">
      <div className="flex min-w-0 items-center">
        <span className="mr-1 bg-ctp-mauve px-1.5 font-bold text-ctp-crust">❯_ work</span>
        {windows.map((w, i) => (
          <span key={w} className={cn("px-1", i === active ? "font-bold text-ctp-text" : "text-ctp-overlay1")}>
            <span className={cn(i === active && "text-ctp-mauve")}>{i + 1}</span> {w}
            {mark && i === active && <span className="text-ctp-mauve"> ✦</span>}
          </span>
        ))}
      </div>
      <span className="hidden shrink-0 sm:inline">
        {branch && <span className="text-ctp-mauve">{branch} · </span>}
        <span className="text-ctp-overlay0">ctrl+b h menu · 14:32</span>
      </span>
    </div>
  )
}

export function useTimeline(timeline: readonly number[]) {
  return useSteps(timeline)[0]
}

export function useSteps(timeline: readonly number[]) {
  const last = timeline.length
  const reduce = useReducedMotion()
  const [step, setStep] = useState(0)

  useEffect(() => {
    const id = setTimeout(() => setStep((v) => (reduce ? last : v >= last ? 0 : v + 1)), reduce ? 0 : timeline[Math.min(step, last - 1)])
    return () => clearTimeout(id)
  }, [step, reduce, last, timeline])

  return [step, setStep] as const
}
