import { describe, expect, test, vi } from "vitest"
import { render, screen, within } from "@testing-library/react"
import Home from "@/app/page"
import { commands, installCommand, repoUrl, version } from "@/lib/site"

vi.mock("next/font/google", () => ({ Geist: () => ({ variable: "" }), JetBrains_Mono: () => ({ variable: "" }) }))

const github = vi.hoisted(() => ({ stars: 23456 as number | null }))

vi.mock("@/lib/github", () => ({ getStars: async () => github.stars }))

describe("home page", () => {
  test("the GitHub link in the header shows the stars", async () => {
    github.stars = 23456
    render(await Home())
    const link = within(screen.getByRole("banner")).getByRole("link", { name: "GitHub, 23456 estrelas" })
    expect(link.getAttribute("href")).toBe(repoUrl)
    expect(link.textContent).toBe("+23K")
  })

  test.each([null, 0, 9])("with %s stars, the link shows only GitHub", async (stars) => {
    github.stars = stars
    render(await Home())
    expect(within(screen.getByRole("banner")).getByRole("link", { name: "GitHub" }).textContent).toBe("GitHub")
    github.stars = 23456
  })

  test("from 10 stars on, the number appears", async () => {
    github.stars = 10
    render(await Home())
    expect(within(screen.getByRole("banner")).getByRole("link", { name: "GitHub, 10 estrelas" }).textContent).toBe("10")
    github.stars = 23456
  })

  test("has the main heading", async () => {
    render(await Home())
    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("agente de IA")
  })

  test("each menu link points to an existing section", async () => {
    const { container } = render(await Home())
    const nav = screen.getByRole("navigation")
    const links = within(nav).getAllByRole("link")
    expect(links.length).toBeGreaterThan(0)
    for (const link of links) {
      const id = link.getAttribute("href")?.slice(1)
      expect(id && container.querySelector(`#${id}`)).toBeTruthy()
    }
  })

  test("shows every command", async () => {
    render(await Home())
    for (const c of commands) expect(screen.getAllByText(c.cmd).length).toBeGreaterThan(0)
  })

  test("shows the version, GitHub and the install command", async () => {
    render(await Home())
    expect(screen.getByText(new RegExp(`${version} · open source`))).toBeTruthy()
    expect(document.querySelectorAll(`a[href="${repoUrl}"]`).length).toBeGreaterThan(0)
    expect(screen.getAllByText(installCommand).length).toBeGreaterThan(0)
    expect(screen.queryByText(/em breve/)).toBeNull()
  })
})
