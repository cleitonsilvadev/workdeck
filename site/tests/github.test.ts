import { afterEach, describe, expect, test, vi } from "vitest"
import { getStars, getVersion, newestTag } from "@/lib/github"
import { repoUrl, version } from "@/lib/site"
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

describe("latest version", () => {
  afterEach(() => vi.unstubAllGlobals())

  test("picks the highest vX.Y.Z tag, not the last in alphabetical order", () => {
    expect(newestTag(["v2.9.0", "v2.10.0", "v2.5.4", "beta", "v3.0.0-rc1"])).toBe("v2.10.0")
    expect(newestTag([])).toBeNull()
  })

  test("reads the tags of the workdeck repository", async () => {
    const fetch = vi.fn(async () => Response.json([{ name: "v2.5.3" }, { name: "v2.5.4" }]))
    vi.stubGlobal("fetch", fetch)
    expect(await getVersion()).toBe("v2.5.4")
    expect(fetch).toHaveBeenCalledWith(`https://api.github.com/repos${new URL(repoUrl).pathname}/tags?per_page=100`, expect.anything())
  })

  test("falls back to the version in the code when the API fails", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response("", { status: 403 })))
    expect(await getVersion()).toBe(version)
    vi.stubGlobal("fetch", vi.fn(async () => { throw new Error("offline") }))
    expect(await getVersion()).toBe(version)
  })
})
