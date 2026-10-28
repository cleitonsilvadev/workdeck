import { afterEach, describe, expect, test, vi } from "vitest"
import { getStars } from "@/lib/github"
import { repoUrl } from "@/lib/site"
import { formatStars } from "@/lib/stars"

vi.mock("next/cache", () => ({ cacheLife: () => {} }))

describe("estrelas do GitHub", () => {
  afterEach(() => vi.unstubAllGlobals())

  test("formata como o draculatheme.com", () => {
    expect(formatStars(0)).toBe("0")
    expect(formatStars(999)).toBe("999")
    expect(formatStars(1000)).toBe("+1K")
    expect(formatStars(23456)).toBe("+23K")
  })

  test("busca o número na API do GitHub para o repositório do workdeck", async () => {
    const fetch = vi.fn(async () => Response.json({ stargazers_count: 42 }))
    vi.stubGlobal("fetch", fetch)
    expect(await getStars()).toBe(42)
    expect(fetch).toHaveBeenCalledWith(`https://api.github.com/repos${new URL(repoUrl).pathname}`, expect.anything())
  })

  test("devolve null quando a API falha ou não responde", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response("", { status: 403 })))
    expect(await getStars()).toBeNull()
    vi.stubGlobal("fetch", vi.fn(async () => { throw new Error("sem rede") }))
    expect(await getStars()).toBeNull()
  })
})
