"use client"

import type React from "react"
import { AnimatePresence, motion } from "motion/react"
import { Line, Pane, Prompt, StatusBar, TerminalWindow, useTimeline } from "@/components/terminal-parts"
import type { Dictionary } from "@/lib/dictionaries"
import { version } from "@/lib/site"
import { cn } from "@/lib/utils"

const timeline = [2300, 500, 700, 500, 2000, 900, 5600]

const logo = [
  ".MMMMMMMMM.",
  "MMMMMMMMMMM",
  "MMEMMMMMMMM",
  "MMMEMMMMMMM",
  "MMMMEMMMMMM",
  "MMMEMMMMMMM",
  "MMEMMEEEEMM",
  "MMMMMMMMMMM",
  ".MMMMMMMMM.",
]

const projects = [
  { name: "api", branch: "main", dirty: 0 },
  { name: "web", branch: "feature/login", dirty: 6 },
  { name: "mobile", branch: "main", dirty: 0 },
]

const containers = [
  { name: "postgres", status: "Up 2 hours" },
  { name: "redis", status: "Up 2 hours" },
  { name: "api-worker", status: "Up 14 minutes" },
]

const file = "~/.config/workdeck/panels/30-docker"

const glyphs: Record<string, string[]> = {
  "0": ["###", "#.#", "#.#", "#.#", "###"],
  "1": [".#.", "##.", ".#.", ".#.", "###"],
  "2": ["###", "..#", "###", "#..", "###"],
  "3": ["###", "..#", "###", "..#", "###"],
  "4": ["#.#", "#.#", "###", "..#", "..#"],
  "5": ["###", "#..", "###", "..#", "###"],
  "6": ["###", "#..", "###", "#.#", "###"],
  "7": ["###", "..#", "..#", "..#", "..#"],
  "8": ["###", "#.#", "###", "#.#", "###"],
  "9": ["###", "#.#", "###", "..#", "###"],
  ":": [".", "#", ".", "#", "."],
}

function Clock({ time }: { time: string }) {
  return (
    <div className="flex justify-center gap-2" aria-label={time}>
      {time.split("").map((ch, i) => (
        <div key={i} className="grid gap-px" style={{ gridTemplateColumns: `repeat(${glyphs[ch][0].length}, 0.55rem)` }}>
          {glyphs[ch].flatMap((row, y) => row.split("").map((c, x) => <span key={`${y}-${x}`} className={cn("h-[0.55rem]", c === "#" && "bg-ctp-mauve")} />))}
        </div>
      ))}
    </div>
  )
}

function Widget({ title, children, className }: { title?: string; children: React.ReactNode; className?: string }) {
  return (
    <div className={cn("min-w-0 rounded-md border border-ctp-surface0 p-2", className)}>
      {title && <div className="mb-1 font-bold text-ctp-mauve">{title}</div>}
      {children}
    </div>
  )
}

function Logo() {
  return (
    <div className="grid shrink-0 grid-cols-[repeat(11,0.35rem)] grid-rows-[repeat(9,0.35rem)]">
      {logo.flatMap((row, y) =>
        row.split("").map((c, x) => <span key={`${y}-${x}`} className={cn(c === "M" && "bg-ctp-mauve", c === "E" && "bg-ctp-crust")} />)
      )}
    </div>
  )
}

export function PanelDemo({ demo }: { demo: Dictionary["demo"] }) {
  const s = useTimeline(timeline)
  const saved = s >= 5
  const shown = s >= 6
  const focus = shown ? "painel" : "terminal"

  return (
    <TerminalWindow>
      <div className="grid h-[480px] grid-rows-[1fr_auto] font-mono text-[10.5px] leading-relaxed sm:h-[460px] sm:text-xs">
        <div className="grid min-h-0 grid-rows-[1fr_auto] gap-1.5 p-1.5">
          <Pane title="painel" active={focus === "painel"}>
            <Clock time="09:41" />
            <div className="pt-1.5 pb-2 text-center text-ctp-overlay0">{demo.panelDate}</div>
            <div className="grid grid-cols-2 gap-1.5">
              <Widget>
                <div className="flex items-center gap-2">
                  <Logo />
                  <div className="min-w-0 space-y-0.5">
                    <div>
                      <span className="font-bold text-ctp-mauve">workdeck</span> <span className="text-ctp-overlay0">{version}</span>
                    </div>
                    <div>
                      <span className="text-ctp-green">✓</span> projetos  {projects.length}
                    </div>
                  </div>
                </div>
                <div className="pt-1 text-ctp-overlay0">⌘H abre o menu</div>
              </Widget>
              <Widget title="Projetos">
                {projects.map((p) => (
                  <div key={p.name} className="truncate whitespace-pre">
                    {p.name.padEnd(7)}
                    <span className="text-ctp-mauve">{p.branch.padEnd(14)}</span>
                    {p.dirty ? <span className="text-ctp-yellow">● {p.dirty}</span> : <span className="text-ctp-green">✓</span>}
                  </div>
                ))}
              </Widget>
              <AnimatePresence>
                {shown && (
                  <motion.div
                    key="docker"
                    className="col-span-2 rounded-md"
                    initial={{ opacity: 0, y: 6, backgroundColor: "color-mix(in oklch, var(--catppuccin-color-mauve) 18%, transparent)" }}
                    animate={{ opacity: 1, y: 0, backgroundColor: "color-mix(in oklch, var(--catppuccin-color-mauve) 0%, transparent)" }}
                    transition={{ duration: 0.4, backgroundColor: { duration: 1.6, delay: 0.3 } }}
                  >
                    <Widget title="Docker">
                      {containers.map((c, i) => (
                        <Line key={c.name} className="text-ctp-subtext0" delay={0.15 + i * 0.12}>
                          <span className="text-ctp-text">{c.name}</span>
                          {"  "}
                          {c.status}
                        </Line>
                      ))}
                    </Widget>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </Pane>

          <Pane title="terminal" active={focus === "terminal"} className="h-[9.5rem] sm:h-[10.5rem]">
            <Prompt path="~" text={`cat > ${file} <<'PAINEL'`} typing={s === 0} done={s >= 1} caret={s === 0} speed={32} />
            {s >= 1 && <Line><span className="text-ctp-overlay0">heredoc&gt; </span>#!/usr/bin/env bash</Line>}
            {s >= 2 && <Line><span className="text-ctp-overlay0">heredoc&gt; </span>docker ps --format &apos;{"{{.Names}}  {{.Status}}"}&apos;</Line>}
            {s >= 3 && <Line><span className="text-ctp-overlay0">heredoc&gt; </span>PAINEL</Line>}
            {s >= 4 && <Prompt path="~" text={`chmod +x ${file}`} typing={s === 4} done={saved} caret={s === 4} speed={32} />}
            {saved && <Line className="text-ctp-overlay1">{demo.panelReload}</Line>}
          </Pane>
        </div>

        <StatusBar windows={["painel", "api", "web", "mobile"]} active={0} />
      </div>
    </TerminalWindow>
  )
}
