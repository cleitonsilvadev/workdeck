"use client"

import { motion } from "motion/react"
import { Keyboard } from "lucide-react"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import type { Dictionary } from "@/lib/dictionaries"

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

function List({ items, modifiers, where }: { items: Dictionary["shortcuts"]["items"]; modifiers: string[]; where: string }) {
  return (
    <div className="rounded-2xl border border-border bg-ctp-mantle/70 p-2">
      <div className="px-3 pt-2 pb-1 text-xs font-medium tracking-wider text-ctp-overlay1 uppercase">{where}</div>
      <ul className="grid sm:grid-cols-2">
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
              {("keys" in s && s.keys ? s.keys : [...modifiers, s.key]).map((k, i) => (
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

export function ShortcutList({ shortcuts }: { shortcuts: Dictionary["shortcuts"] }) {
  return (
    <div className="flex flex-col gap-4">
      <Tabs defaultValue="macos" className="w-full">
        <TabsList className="mx-auto mb-4 bg-ctp-mantle">
          <TabsTrigger value="macos" className="px-4">{shortcuts.macTab}</TabsTrigger>
          <TabsTrigger value="linux" className="px-4">{shortcuts.linuxTab}</TabsTrigger>
        </TabsList>
        <TabsContent value="macos">
          <List items={shortcuts.items} modifiers={["⌘"]} where={shortcuts.macWhere} />
        </TabsContent>
        <TabsContent value="linux">
          <List items={shortcuts.items} modifiers={["Ctrl", "Shift"]} where={shortcuts.linuxWhere} />
        </TabsContent>
      </Tabs>
      <div className="rounded-2xl border border-dashed border-ctp-surface1 p-5">
        <div className="mb-2 flex items-center gap-2 text-sm font-medium text-ctp-text">
          <Keyboard className="size-4 text-ctp-overlay1" />
          {shortcuts.othersTitle}
        </div>
        <p className="text-sm leading-relaxed text-ctp-subtext0">{shortcuts.othersText}</p>
      </div>
    </div>
  )
}
