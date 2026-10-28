"use client"

import { motion } from "motion/react"
import { Keyboard } from "lucide-react"
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

function Group({ title, items }: { title: string; items: readonly { prefix: boolean; keys: readonly string[]; desc: string }[] }) {
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
              {s.prefix && (
                <>
                  <Key>Ctrl</Key>
                  <span className="text-xs text-ctp-overlay0">+</span>
                  <Key>b</Key>
                  <span className="px-1 text-xs text-ctp-overlay0">e</span>
                </>
              )}
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
            <Keyboard className="size-4 text-ctp-overlay1" />
            Prefere uma tecla só?
          </div>
          <p className="text-sm leading-relaxed text-ctp-subtext0">
            Há atalhos diretos com Alt: Alt+1…9 vai para a janela, Alt+setas troca de painel e Alt+Shift+letra faz as ações. No Mac, a Option precisa agir como Alt, e o work doctor diz onde ligar. Para usar cmd+1, há adaptadores para kitty, WezTerm e Alacritty; só o do kitty é instalado automaticamente:
          </p>
          <code className="mt-3 block font-mono text-xs text-ctp-mauve">work install --terminal kitty</code>
        </div>
      </div>
      <Group title="Agir" items={shortcuts.agir} />
    </div>
  )
}
