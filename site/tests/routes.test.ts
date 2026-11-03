import { afterEach, describe, expect, test, vi } from "vitest"
import { GET as install } from "@/app/install/route"
import { GET as latestVersion } from "@/app/api/version/route"
import { installScriptUrl, version } from "@/lib/site"

vi.mock("next/cache", () => ({ cacheLife: () => {} }))
vi.mock("next/server", () => ({ connection: async () => {} }))

describe("routes for the work command", () => {
  afterEach(() => vi.unstubAllGlobals())

  test("/install serves get.sh as plain text, never cached", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response("#!/usr/bin/env bash\necho hi\n")))
    const response = await install()
    expect(await response.text()).toBe("#!/usr/bin/env bash\necho hi\n")
    expect(response.headers.get("content-type")).toContain("text/plain")
    expect(response.headers.get("cache-control")).toBe("no-store")
  })

  test("/install redirects to the repository when GitHub does not answer with the script", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => new Response("rate limited", { status: 429 })))
    const response = await install()
    expect(response.status).toBe(302)
    expect(response.headers.get("location")).toBe(installScriptUrl)
  })

  test("/api/version answers the newest tag in one line", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => Response.json([{ name: "v2.5.4" }, { name: "v2.10.0" }])))
    const response = await latestVersion()
    expect(await response.text()).toBe("v2.10.0\n")
    expect(response.headers.get("cache-control")).toBe("no-store")
  })

  test("/api/version falls back to the version in the code", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => { throw new Error("offline") }))
    expect(await (await latestVersion()).text()).toBe(`${version}\n`)
  })
})
