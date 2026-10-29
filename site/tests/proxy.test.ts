import { describe, expect, test } from "vitest"
import { NextRequest } from "next/server"
import { proxy } from "@/proxy"

const request = (path: string, headers: Record<string, string> = {}) => new NextRequest(new URL(path, "https://www.workdeck.dev"), { headers })

describe("proxy", () => {
  test("redirects the root to the preferred language", () => {
    const response = proxy(request("/", { "accept-language": "pt-BR,pt;q=0.9" }))
    expect(response?.status).toBe(307)
    expect(response?.headers.get("location")).toBe("https://www.workdeck.dev/pt-BR")
  })

  test("lets the language pages through", () => {
    expect(proxy(request("/en"))).toBeUndefined()
    expect(proxy(request("/pt-BR"))).toBeUndefined()
    expect(proxy(request("/en/anything"))).toBeUndefined()
  })

  test("answers 404 for unknown paths without rendering the page", async () => {
    const response = proxy(request("/junk123"))
    expect(response?.status).toBe(404)
    expect(await response?.text()).toBe("Not found")
  })
})
