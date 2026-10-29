import type { Locale } from "@/lib/i18n"
import { en } from "@/lib/dictionaries/en"
import { ptBR, type Dictionary } from "@/lib/dictionaries/pt-BR"

const dictionaries: Record<Locale, Dictionary> = { en, "pt-BR": ptBR }

export function getDictionary(locale: Locale) {
  return dictionaries[locale]
}

export type { Dictionary }
