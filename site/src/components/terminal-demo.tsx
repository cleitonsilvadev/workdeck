"use client"

import { AnimatePresence, motion } from "motion/react"
import { Line, Pane, Prompt, StatusBar, TerminalWindow, useTimeline } from "@/components/terminal-parts"
import { cn } from "@/lib/utils"

const timeline = [700, 900, 800, 700, 1600, 700, 600, 700, 900, 1100, 900, 5200]

export function TerminalDemo() {
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
                  sessão <span className="text-ctp-mauve">workdeck</span> · 4 janelas
                </Line>
              )}
              {s >= 2 && <Line className="text-ctp-overlay1">Ctrl+b v · claude no painel ao lado →</Line>}
              {s >= 6 && <Prompt text="work review" typing={s === 6} done={s >= 7} caret={s === 6} />}
              {reviewOpen && <Line className="text-ctp-overlay1">review embaixo do chat →</Line>}
            </Pane>

            <AnimatePresence>
              {agentOpen && (
                <motion.div key="ia" layout className={cn("grid min-h-0 gap-1.5", reviewOpen ? "grid-rows-[auto_1fr]" : "grid-rows-1")}>
                  <Pane title="IA · claude" active={focus === "agent"}>
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
                  <AnimatePresence>
                    {reviewOpen && (
                      <Pane key="review" title="IA · review" active={focus === "review"}>
                        <Line className="text-ctp-overlay0">separado da conversa que escreveu</Line>
                        <Line className="text-ctp-subtext0">
                          lendo a mudança · <span className="text-ctp-green">+13</span> <span className="text-ctp-red">-2</span> em 2 arquivo(s)
                        </Line>
                        {s >= 8 && (
                          <>
                            <Line className="mt-1 text-ctp-yellow" delay={0.05}>● vale corrigir  <span className="text-ctp-subtext0">email.ts:3</span></Line>
                            <Line className="text-ctp-subtext0" delay={0.12}>  o regex aceita e-mail sem domínio</Line>
                          </>
                        )}
                        {s >= 9 && (
                          <>
                            <Line className="text-ctp-overlay1" delay={0}>○ opcional  <span className="text-ctp-subtext0">login.ts:13</span></Line>
                            <Line className="text-ctp-subtext0" delay={0.08}>  falta teste para e-mail inválido</Line>
                          </>
                        )}
                        {s >= 10 && (
                          <Line className="mt-1 text-ctp-text" delay={0}>
                            <span className="font-bold">veredito:</span> <span className="text-ctp-green">commit depois do ajuste</span>
                          </Line>
                        )}
                      </Pane>
                    )}
                  </AnimatePresence>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>

          <StatusBar windows={["painel", "api", "web", "notas"]} active={2} mark={agentOpen} hint="Ctrl+b h abre o menu" />
        </div>
    </TerminalWindow>
  )
}
