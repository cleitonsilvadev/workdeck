import { afterEach, describe, expect, test, vi } from "vitest"
import { getStars } from "@/lib/github"
import { repoUrl } from "@/lib/site"
import { formatStars } from "@/lib/stars"

vi.mock("next/cache", () => ({ cacheLife: () => {} }))

describe("GitHub stars", () => {
  afterEach(() => vi.unstubAllGlobals())

  test("formats like draculatheme.com", () => {
    expect(formatStars(0)).toBe("0")
    expect(formatStars(999)).toBe("999")
    expect(formatStars(1000)).toBe("+1K")
    expect(formatStars(23456)).toBe("+23K")
  })

  test("fetches the count from the GitHub API for the workdeck repository", async () => {
    const fetch = vi.fn(async () => Response.json({ stargazers_count: 42 }))
    vi.stubGlobal("fetch", fetch)
    expect(await getStars()).toBe(42)
    expect(fetch).toHaveBeenCalledWith(`https://api.github.com/repos${new URL(repoUrl).pathname}`, expect.anything())
  })

  test("returns null when the API fails or does not respond", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response("", { status: 403 })))
    expect(await getStars()).toBeNull()
    vi.stubGlobal("fetch", vi.fn(async () => { throw new Error("offline") }))
    expect(await getStars()).toBeNull()
  })
})
