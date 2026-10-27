"use client"

import { useState } from "react"
import { AnimatePresence, motion } from "motion/react"
import { Check, Copy } from "lucide-react"
import { cn } from "@/lib/utils"

export function CopyButton({ text, className }: { text: string; className?: string }) {
  const [copied, setCopied] = useState(false)

  async function copy() {
    try {
      await navigator.clipboard.writeText(text)
      setCopied(true)
      setTimeout(() => setCopied(false), 1600)
    } catch {
      setCopied(false)
    }
  }

  return (
    <button
      type="button"
      onClick={copy}
      aria-label={copied ? "Copiado" : "Copiar comando"}
      className={cn(
        "relative inline-flex size-8 shrink-0 items-center justify-center rounded-md text-ctp-overlay1 transition-colors hover:bg-ctp-surface0 hover:text-ctp-text focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
        className
      )}
    >
      <AnimatePresence mode="wait" initial={false}>
        <motion.span
          key={copied ? "ok" : "copy"}
          initial={{ scale: 0.6, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.6, opacity: 0 }}
          transition={{ duration: 0.15 }}
        >
          {copied ? <Check className="size-4 text-ctp-green" /> : <Copy className="size-4" />}
        </motion.span>
      </AnimatePresence>
    </button>
  )
}

export function CommandLine({ command, className }: { command: string; className?: string }) {
  return (
    <div
      className={cn(
        "flex items-center gap-3 rounded-xl border border-border bg-ctp-mantle/80 py-1.5 pr-1.5 pl-4 font-mono text-sm backdrop-blur",
        className
      )}
    >
      <span className="select-none text-ctp-mauve">$</span>
      <code className="min-w-0 flex-1 truncate text-ctp-text">{command}</code>
      <CopyButton text={command} />
    </div>
  )
}
