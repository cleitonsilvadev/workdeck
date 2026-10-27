"use client"

import { useEffect, useState } from "react"
import { motion, useReducedMotion } from "motion/react"
import { comingSoonPhrases } from "@/lib/site"
import { cn } from "@/lib/utils"

function useTypewriter(phrases: readonly string[], { type = 55, erase = 25, hold = 2200, gap = 400 } = {}) {
  const [index, setIndex] = useState(0)
  const [count, setCount] = useState(0)
  const [erasing, setErasing] = useState(false)

  useEffect(() => {
    const phrase = phrases[index]
    let delay = erasing ? erase : type
    if (!erasing && count === phrase.length) delay = hold
    if (erasing && count === 0) delay = gap

    const id = setTimeout(() => {
      if (!erasing && count === phrase.length) setErasing(true)
      else if (erasing && count === 0) {
        setErasing(false)
        setIndex((i) => (i + 1) % phrases.length)
      } else setCount((c) => c + (erasing ? -1 : 1))
    }, delay)
    return () => clearTimeout(id)
  }, [phrases, index, count, erasing, type, erase, hold, gap])

  return phrases[index].slice(0, count)
}

function Typing() {
  const text = useTypewriter(comingSoonPhrases)
  return (
    <>
      {text}
      <motion.span
        aria-hidden="true"
        className="ml-px inline-block h-[1.05em] w-[0.55em] translate-y-[0.15em] bg-ctp-overlay1"
        animate={{ opacity: [1, 1, 0, 0] }}
        transition={{ duration: 1, repeat: Infinity, times: [0, 0.5, 0.5, 1] }}
      />
    </>
  )
}

export function ComingSoon({ className }: { className?: string }) {
  const reduce = useReducedMotion()

  return (
    <div
      className={cn(
        "flex items-center gap-3 rounded-xl border border-dashed border-ctp-surface1 bg-ctp-mantle/80 px-4 py-3 font-mono text-sm backdrop-blur",
        className
      )}
    >
      <span className="relative flex size-2 shrink-0">
        <span className="absolute inline-flex size-full animate-ping rounded-full bg-ctp-mauve/60" />
        <span className="relative inline-flex size-2 rounded-full bg-ctp-mauve" />
      </span>
      <span className="shrink-0 text-ctp-text">em breve</span>
      <span className="shrink-0 text-ctp-overlay0">·</span>
      <span className="sr-only">{comingSoonPhrases[0]}</span>
      <span aria-hidden="true" className="min-w-0 truncate text-ctp-overlay1">
        {reduce ? comingSoonPhrases[0] : <Typing />}
      </span>
    </div>
  )
}
