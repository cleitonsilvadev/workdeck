import Image from "next/image"
import { Quote } from "lucide-react"
import { GlowCard } from "@/components/glow-card"
import { testimonials } from "@/lib/site"
import { cn } from "@/lib/utils"

function initials(name: string) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0])
    .join("")
    .toUpperCase()
}

export function Testimonials() {
  const single = testimonials.length === 1

  return (
    <div className={cn("mx-auto grid gap-4", single ? "max-w-3xl" : "max-w-5xl sm:grid-cols-2")}>
      {testimonials.map((t) => (
        <GlowCard key={t.name}>
          <figure className={cn("flex h-full flex-col", single ? "p-8 sm:p-10" : "p-6 sm:p-8")}>
            <Quote className="mb-6 size-6 text-ctp-mauve/70" />
            <blockquote className={cn("flex-1 leading-snug font-medium tracking-tight text-pretty text-ctp-text", single ? "text-xl sm:text-2xl" : "text-lg")}>{t.quote}</blockquote>
            <figcaption className="mt-8 flex items-center gap-4">
              {t.photo ? (
                <Image src={t.photo} alt={t.name} width={48} height={48} className="size-12 rounded-full object-cover ring-1 ring-ctp-surface1" />
              ) : (
                <span className="grid size-12 place-items-center rounded-full bg-ctp-surface0 font-mono text-sm font-semibold text-ctp-mauve ring-1 ring-ctp-surface1">
                  {initials(t.name)}
                </span>
              )}
              <div className="min-w-0">
                <a href={t.github} target="_blank" rel="noreferrer" className="font-medium text-ctp-text transition-colors hover:text-ctp-mauve">
                  {t.name}
                </a>
                <p className="text-sm text-ctp-subtext0">{t.role}</p>
              </div>
            </figcaption>
          </figure>
        </GlowCard>
      ))}
    </div>
  )
}
