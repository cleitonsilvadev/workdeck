"use client"

import { motion } from "motion/react"
import { Apple } from "lucide-react"
import { shortcuts } from "@/lib/site"

function Key({ children }: { children: string }) {
  return (
    <motion.kbd
      variants={{ rest: { y: 0, boxShadow: "0 3px 0 0 var(--catppuccin-color-surface0)" }, pressed: { y: 2, boxShadow: "0 1px 0 0 var(--catppuccin-color-surface0)" } }}
      transition={{ duration: 0.12 }}
      className="inline-flex h-7 min-w-7 items-center justify-center rounded-md border border-ctp-surface1 bg-ctp-base px-2 font-mono text-xs text-ctp-text"
    >
      {children}
    </motion.kbd>
  )
}

function Group({ title, items }: { title: string; items: readonly { keys: readonly string[]; desc: string }[] }) {
  return (
    <div className="rounded-2xl border border-border bg-ctp-mantle/70 p-2">
      <div className="px-3 pt-2 pb-1 text-xs font-medium tracking-wider text-ctp-overlay1 uppercase">{title}</div>
      <ul>
        {items.map((s) => (
          <motion.li
            key={s.desc}
            initial="rest"
            animate="rest"
            whileHover="pressed"
            whileTap="pressed"
            className="flex items-center justify-between gap-4 rounded-lg px-3 py-2.5 transition-colors hover:bg-ctp-surface0/50"
          >
            <span className="text-sm text-ctp-subtext1">{s.desc}</span>
            <span className="flex shrink-0 items-center gap-1">
              {s.keys.map((k, i) => (
                <span key={k} className="flex items-center gap-1">
                  {i > 0 && <span className="text-xs text-ctp-overlay0">+</span>}
                  <Key>{k}</Key>
                </span>
              ))}
            </span>
          </motion.li>
        ))}
      </ul>
    </div>
  )
}

export function ShortcutList() {
  return (
    <div className="grid gap-4 lg:grid-cols-2">
      <div className="flex flex-col gap-4">
        <Group title="Navegar" items={shortcuts.navegar} />
        <div className="flex-1 rounded-2xl border border-dashed border-ctp-surface1 p-5">
          <div className="mb-2 flex items-center gap-2 text-sm font-medium text-ctp-text">
            <Apple className="size-4 text-ctp-overlay1" />
            Prefere cmd no Mac?
          </div>
          <p className="text-sm leading-relaxed text-ctp-subtext0">
            No macOS, o cmd nunca chega ao tmux: o sistema intercepta antes. Há adaptadores prontos para kitty, WezTerm e Alacritty que traduzem cmd+1 em Alt+1. Só o kitty é instalado automaticamente:
          </p>
          <code className="mt-3 block font-mono text-xs text-ctp-mauve">./install.sh --terminal kitty</code>
        </div>
      </div>
      <Group title="Agir" items={shortcuts.agir} />
    </div>
  )
}
