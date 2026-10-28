"use client"

import { useState } from "react"
import { AnimatePresence, motion } from "motion/react"
import { Line, Pane, Prompt, StatusBar, TerminalWindow, useSteps } from "@/components/terminal-parts"
import { cycle } from "@/lib/site"
import { cn } from "@/lib/utils"

const timeline = [1100, 1400, 1700, 1600, 1100, 1300, 1200, 900, 1000, 1700, 1000, 1200, 900, 1000, 1000, 3600]
const scenes = [0, 4, 7, 11, timeline.length]

function sceneOf(step: number) {
  return Math.max(0, scenes.findLastIndex((start) => step >= start && start < timeline.length))
}

function sceneDuration(scene: number) {
  return timeline.slice(scenes[scene], scenes[scene + 1]).reduce((a, b) => a + b, 0)
}

export function CycleDemo() {
  const [s, setStep] = useSteps(timeline)
  const [runs, setRuns] = useState(0)
  const scene = s >= timeline.length ? cycle.length - 1 : sceneOf(s)
  const finished = s >= timeline.length

  const inSession = s >= 1
  const added = s >= 3
  const switching = s === 4
  const inProject = s >= 5
  const agentOpen = s >= 7
  const reviewOpen = s >= 12
  const focus = reviewOpen ? "review" : s === 11 ? "shell" : agentOpen ? "agent" : "shell"
  const path = inProject ? "~/api" : "~"

  return (
    <div className="mx-auto max-w-5xl">
      <div className="mb-4 grid grid-cols-2 gap-2 lg:grid-cols-4">
        {cycle.map((c, i) => {
          const active = i === scene && !finished
          const done = i < scene || finished
          return (
            <button
              key={c.label}
              type="button"
              onClick={() => {
                setRuns((r) => r + 1)
                setStep(scenes[i])
              }}
              aria-current={active ? "step" : undefined}
              className={cn(
                "group relative overflow-hidden rounded-xl border px-4 pt-3 pb-4 text-left transition-colors",
                active ? "border-ctp-mauve/60 bg-ctp-mantle" : "border-ctp-surface0 bg-ctp-mantle/50 hover:border-ctp-surface1"
              )}
            >
              <div className="flex items-baseline justify-between gap-2">
                <span className={cn("truncate text-sm", c.code ? "font-mono" : "font-medium", active || done ? (c.code ? "text-ctp-mauve" : "text-ctp-text") : "text-ctp-overlay1")}>{c.label}</span>
                <span className="font-mono text-[11px] text-ctp-overlay0">{i + 1}</span>
              </div>
              <p className="mt-0.5 font-mono text-[11px] text-ctp-overlay0">{c.when}</p>
              <div className="absolute inset-x-0 bottom-0 h-0.5 bg-ctp-surface0">
                {done && <div className="h-full w-full bg-ctp-mauve/50" />}
                {active && (
                  <motion.div
                    key={`${i}-${runs}`}
                    className="h-full bg-ctp-mauve"
                    initial={{ width: "0%" }}
                    animate={{ width: "100%" }}
                    transition={{ duration: sceneDuration(i) / 1000, ease: "linear" }}
                  />
                )}
              </div>
            </button>
          )
        })}
      </div>

      <TerminalWindow title={inSession ? "workdeck — tmux" : "kitty"}>
        <div className="grid h-[460px] grid-rows-[1fr_auto] font-mono text-[10.5px] leading-relaxed sm:h-[400px] sm:text-xs">
          <motion.div layout className={cn("grid min-h-0 gap-1.5 p-1.5", agentOpen ? "grid-cols-1 grid-rows-[1fr_auto] sm:grid-cols-2 sm:grid-rows-1" : "grid-cols-1")}>
            <AnimatePresence>
              {agentOpen && (
                <motion.div key="ia" layout className={cn("grid min-h-0 gap-1.5", reviewOpen ? "grid-rows-[auto_1fr]" : "grid-rows-1")}>
                  <Pane title="IA · claude" active={focus === "agent"}>
                    {s >= 8 && (
                      <Line>
                        <span className="text-ctp-peach">› </span>
                        <span className="text-ctp-text">valida o e-mail no login</span>
                      </Line>
                    )}
                    {s >= 9 && (
                      <>
                        <Line className="text-ctp-subtext0" delay={0.1}>  lendo src/auth/login.ts</Line>
                        <Line className="text-ctp-subtext0" delay={0.6}>  criando src/auth/email.ts</Line>
                        <Line className="text-ctp-subtext0" delay={1.1}>  editando src/auth/login.ts</Line>
                      </>
                    )}
                    {s >= 10 && <Line className="text-ctp-green">  ✓ pronto. revise antes de commitar.</Line>}
                  </Pane>
                  <AnimatePresence>
                    {reviewOpen && (
                      <Pane key="review" title="IA · review" active={focus === "review"}>
                        <Line className="text-ctp-subtext0">
                          lendo a mudança · <span className="text-ctp-green">+13</span> <span className="text-ctp-red">-2</span> em 2 arquivo(s)
                        </Line>
                        {s >= 13 && (
                          <>
                            <Line className="mt-1 text-ctp-yellow">● vale corrigir  <span className="text-ctp-subtext0">email.ts:3</span></Line>
                            <Line className="text-ctp-subtext0" delay={0.08}>  o regex aceita e-mail sem domínio</Line>
                          </>
                        )}
                        {s >= 14 && (
                          <>
                            <Line className="text-ctp-overlay1">○ opcional  <span className="text-ctp-subtext0">login.ts:13</span></Line>
                            <Line className="text-ctp-subtext0" delay={0.08}>  falta teste para e-mail inválido</Line>
                          </>
                        )}
                        {s >= 15 && (
                          <Line className="mt-1 text-ctp-text">
                            <span className="font-bold">veredito:</span> <span className="text-ctp-green">ajuste o regex e siga</span>
                          </Line>
                        )}
                      </Pane>
                    )}
                  </AnimatePresence>
                </motion.div>
              )}
            </AnimatePresence>

            <Pane title={!inSession ? "terminal" : inProject ? "shell · api" : "painel"} active={focus === "shell"}>
              {!inSession ? (
                <Prompt path="~" text="work" typing={s === 0} done={false} caret={s === 0} />
              ) : !inProject ? (
                <>
                  {!added && (
                    <div className="mb-2 space-y-0.5">
                      <Line>
                        <span className="text-ctp-mauve">Para começar</span>, no terminal aqui embaixo:
                      </Line>
                      <Line className="text-ctp-overlay1" delay={0.1}>
                        {"  "}
                        <span className="text-ctp-mauve">work add ~/projeto</span>   cada projeto vira uma janela
                      </Line>
                    </div>
                  )}
                  <Prompt path="~" text="work add ~/api" typing={s === 2} done={added} caret={s === 2} />
                  {added && (
                    <>
                      <Line className="text-ctp-subtext0">~/api entrou no seu work como api</Line>
                      <Line className="text-ctp-overlay1" delay={0.3}>a janela api já está aberta na sessão work</Line>
                    </>
                  )}
                  {switching && (
                    <Line className="mt-2 text-ctp-overlay1">
                      <kbd className="rounded border border-ctp-surface1 bg-ctp-surface0 px-1 text-ctp-text">Shift</kbd> + <kbd className="rounded border border-ctp-surface1 bg-ctp-surface0 px-1 text-ctp-text">→</kbd> vai para a janela api
                    </Line>
                  )}
                </>
              ) : (
                <>
                  <Prompt path={path} text="git status" typing={s === 5} done={s >= 6} caret={s === 5} />
                  {s >= 6 && (
                    <>
                      <Line className="text-ctp-subtext0">On branch main</Line>
                      <Line className="text-ctp-subtext0">nothing to commit, working tree clean</Line>
                    </>
                  )}
                  {s >= 11 && <Prompt path={path} text="work review" typing={s === 11} done={reviewOpen} caret={s === 11} />}
                  {reviewOpen && <Line className="text-ctp-overlay1">← review embaixo do agente</Line>}
                </>
              )}
            </Pane>
          </motion.div>

          {inSession ? (
            <StatusBar windows={added ? ["painel", "api"] : ["painel"]} active={inProject ? 1 : 0} mark={agentOpen} branch={inProject ? "main" : undefined} />
          ) : (
            <div className="bg-ctp-mantle py-1 text-[11px]">&nbsp;</div>
          )}
        </div>
      </TerminalWindow>

      <div className="mx-auto mt-4 min-h-12 max-w-2xl text-center text-sm text-pretty text-ctp-subtext0">
        <AnimatePresence mode="wait">
          <motion.p key={scene} initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -4 }} transition={{ duration: 0.25 }}>
            {cycle[scene].desc}
          </motion.p>
        </AnimatePresence>
      </div>
    </div>
  )
}
