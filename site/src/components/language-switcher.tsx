"use client"

import { useRouter } from "next/navigation"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"
import { localeCookie, locales, type Locale } from "@/lib/i18n"

export function LanguageSwitcher({ current, label, names }: { current: Locale; label: string; names: Record<Locale, string> }) {
  const router = useRouter()

  function choose(next: Locale) {
    if (next === current) return
    document.cookie = `${localeCookie}=${next}; path=/; max-age=31536000; samesite=lax`
    router.push(`/${next}${window.location.hash}`)
  }

  return (
    <ToggleGroup
      aria-label={label}
      size="sm"
      spacing={0}
      value={[current]}
      onValueChange={(value) => value[0] && choose(value[0] as Locale)}
      className="rounded-md border border-ctp-surface0 bg-ctp-mantle/80 p-0.5"
    >
      {locales.map((l) => (
        <ToggleGroupItem
          key={l}
          value={l}
          aria-label={names[l]}
          className="h-7 min-w-9 px-2 font-mono text-xs text-ctp-overlay1 data-[pressed]:bg-ctp-surface0 data-[pressed]:text-ctp-text"
        >
          {names[l]}
        </ToggleGroupItem>
      ))}
    </ToggleGroup>
  )
}
