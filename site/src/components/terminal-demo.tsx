"use client"

import { AnimatePresence, motion } from "motion/react"
import { Line, Pane, Prompt, StatusBar, TerminalWindow, useTimeline } from "@/components/terminal-parts"
import type { Dictionary } from "@/lib/dictionaries"
import { cn } from "@/lib/utils"

const timeline = [700, 900, 800, 700, 1600, 700, 600, 700, 900, 1100, 900, 5200]

export function TerminalDemo({ demo }: { demo: Dictionary["demo"] }) {
  const s = useTimeline(timeline)

  const agentOpen = s >= 3
  const reviewOpen = s >= 7
  const focus = s >= 7 ? "review" : s === 6 ? "shell" : s >= 3 ? "agent" : "shell"

  return (
    <TerminalWindow>
        <div className="grid h-[560px] grid-rows-[1fr_auto] gap-0 font-mono text-[11.5px] leading-relaxed sm:h-[380px] sm:text-xs">
          <motion.div layout className={cn("grid min-h-0 gap-1.5 p-1.5", agentOpen ? "grid-cols-1 grid-rows-[auto_1fr] sm:grid-cols-2 sm:grid-rows-1" : "grid-cols-1")}>
            <Pane title="shell" active={focus === "shell"}>
              <Prompt text="work" typing={s === 0} done={s >= 1} caret={s === 0} />
              {s >= 1 && (
                <Line className="text-ctp-overlay1">
                  {demo.session} <span className="text-ctp-mauve">work</span> · {demo.windows}
                </Line>
              )}
              {s >= 2 && <Line className="text-ctp-overlay1">{demo.agentHint}</Line>}
              {s >= 6 && <Prompt text="work review" typing={s === 6} done={s >= 7} caret={s === 6} />}
              {reviewOpen && <Line className="text-ctp-overlay1">{demo.reviewHint}</Line>}
            </Pane>

            <AnimatePresence>
              {agentOpen && (
                <motion.div key="ia" layout className={cn("grid min-h-0 gap-1.5", reviewOpen ? "grid-rows-[auto_1fr]" : "grid-rows-1")}>
                  <Pane title={demo.agentPane} active={focus === "agent"}>
                    <Line>
                      <span className="text-ctp-peach">› </span>
                      <span className="text-ctp-text">{demo.prompt}</span>
                    </Line>
                    {s >= 4 && (
                      <>
                        <Line className="text-ctp-subtext0" delay={0.1}>  {demo.reading} src/auth/login.ts</Line>
                        <Line className="text-ctp-subtext0" delay={0.5}>  {demo.creating} src/auth/email.ts</Line>
                        <Line className="text-ctp-subtext0" delay={0.9}>  {demo.editing} src/auth/login.ts</Line>
                      </>
                    )}
                    {s >= 5 && <Line className="text-ctp-green">  {demo.done}</Line>}
                  </Pane>
                  <AnimatePresence>
                    {reviewOpen && (
                      <Pane key="review" title={demo.reviewPane} active={focus === "review"}>
                        <Line className="text-ctp-overlay0">separado da conversa que escreveu</Line>
                        <Line className="text-ctp-subtext0">
                          lendo a mudança · <span className="text-ctp-green">+13</span> <span className="text-ctp-red">-2</span> em 2 arquivo(s)
                        </Line>
                        {s >= 8 && (
                          <>
                            <Line className="mt-1 text-ctp-text" delay={0.05}><span className="text-ctp-red">●</span> email.ts:3 <span className="text-ctp-subtext0">— o regex aceita e-mail sem domínio</span></Line>
                            <Line className="text-ctp-subtext0" delay={0.12}>  → exija um ponto depois do @</Line>
                          </>
                        )}
                        {s >= 9 && (
                          <>
                            <Line className="text-ctp-text" delay={0}><span className="text-ctp-peach">●</span> login.ts:13 <span className="text-ctp-subtext0">— falta teste para e-mail inválido</span></Line>
                            <Line className="text-ctp-subtext0" delay={0.08}>  → acrescente um caso sem domínio</Line>
                          </>
                        )}
                        {s >= 10 && (
                          <Line className="mt-1 text-ctp-text" delay={0}>
                            <span className="text-ctp-red">●</span> <span className="font-bold">corrija os vermelhos antes do commit</span>
                          </Line>
                        )}
                      </Pane>
                    )}
                  </AnimatePresence>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>

          <StatusBar windows={["painel", "api", "web", "notas"]} active={2} mark={agentOpen} branch="feature/login" />
        </div>
    </TerminalWindow>
  )
}
