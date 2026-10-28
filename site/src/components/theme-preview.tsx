"use client"

import { useState } from "react"
import { motion } from "motion/react"
import { themes } from "@/lib/site"
import { cn } from "@/lib/utils"

const ease = { duration: 0.5, ease: [0.22, 1, 0.36, 1] } as const

export function ThemePreview() {
  const [id, setId] = useState<(typeof themes)[number]["id"]>(themes[0].id)
  const t = themes.find((x) => x.id === id) ?? themes[0]

  return (
    <div className="grid grid-cols-1 items-center gap-8 lg:grid-cols-[1fr_1.3fr]">
      <div className="space-y-3" role="radiogroup" aria-label="Tema">
        {themes.map((theme) => {
          const active = theme.id === id
          return (
            <button
              key={theme.id}
              type="button"
              role="radio"
              aria-checked={active}
              onClick={() => setId(theme.id)}
              className={cn(
                "relative w-full rounded-xl border p-4 text-left transition-colors focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
                active ? "border-ctp-surface1" : "border-transparent hover:bg-ctp-mantle/60"
              )}
            >
              {active && (
                <motion.span layoutId="theme-active" className="absolute inset-0 -z-10 rounded-xl bg-ctp-mantle" transition={ease} />
              )}
              <div className="flex items-center justify-between gap-3">
                <span className="font-medium text-ctp-text">{theme.name}</span>
                <span className="flex gap-1">
                  {theme.palette.slice(1, 7).map((c) => (
                    <span key={c} className="size-3 rounded-full" style={{ backgroundColor: c }} />
                  ))}
                </span>
              </div>
              <p className="mt-1 text-sm text-ctp-subtext0">{theme.note}</p>
              <code className="mt-2 block font-mono text-xs text-ctp-overlay1">curl … | bash -s -- --theme {theme.id}</code>
            </button>
          )
        })}
      </div>

      <motion.div
        className="overflow-hidden rounded-2xl border border-ctp-surface0 font-mono text-xs leading-relaxed shadow-2xl shadow-black/40 sm:text-[13px]"
        animate={{ backgroundColor: t.bg, color: t.fg }}
        transition={ease}
      >
        <div className="space-y-0.5 overflow-x-auto p-5 whitespace-pre">
          <div>
            <motion.span animate={{ color: t.green }} transition={ease}>~/projetos/api</motion.span>
            <motion.span animate={{ color: t.accent }} transition={ease}> ❯ </motion.span>
            git diff
          </div>
          <div className="pt-2">
            <motion.span className="font-bold" animate={{ color: t.blue }} transition={ease}>diff</motion.span>
            <span className="font-bold">  main</span>
          </div>
          <div> src/server.ts | 4 <motion.span animate={{ color: t.green }} transition={ease}>+++</motion.span><motion.span animate={{ color: t.red }} transition={ease}>-</motion.span></div>
          <div className="pt-2 opacity-60">  8 │ app.listen(port)</div>
          <motion.div animate={{ color: t.red, backgroundColor: `${t.red}1f` }} transition={ease}>- 9 │ console.log(&quot;ok&quot;)</motion.div>
          <motion.div animate={{ color: t.green, backgroundColor: `${t.green}1f` }} transition={ease}>+ 9 │ logger.info(&#123; port &#125;, &quot;servidor no ar&quot;)</motion.div>
          <motion.div animate={{ color: t.green, backgroundColor: `${t.green}1f` }} transition={ease}>+10 │ await ready()</motion.div>
          <div className="pt-2">
            <motion.span animate={{ color: t.yellow }} transition={ease}>!</motion.span> 1 arquivo  <motion.span animate={{ color: t.green }} transition={ease}>+3</motion.span>  <motion.span animate={{ color: t.red }} transition={ease}>-1</motion.span>
          </div>
        </div>
        <motion.div className="flex items-center gap-3 px-3 py-1.5" animate={{ backgroundColor: t.bar, color: t.muted }} transition={ease}>
          <motion.span className="font-bold" animate={{ color: t.accent }} transition={ease}>workdeck</motion.span>
          <span>1:api</span>
          <motion.span className="rounded-sm px-1 font-bold" animate={{ color: t.fg, backgroundColor: `${t.muted}55` }} transition={ease}>2:web</motion.span>
          <span>3:notas</span>
        </motion.div>
      </motion.div>
    </div>
  )
}
