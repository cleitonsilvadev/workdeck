import { describe, expect, test, vi } from "vitest"
import { render, screen, within } from "@testing-library/react"
import Home from "@/app/page"
import { commands, installCommand, repoUrl, version } from "@/lib/site"

vi.mock("next/font/google", () => ({ Geist: () => ({ variable: "" }), JetBrains_Mono: () => ({ variable: "" }) }))

const github = vi.hoisted(() => ({ stars: 23456 as number | null }))

vi.mock("@/lib/github", () => ({ getStars: async () => github.stars }))

describe("página inicial", () => {
  test("o link do GitHub no cabeçalho mostra as estrelas", async () => {
    github.stars = 23456
    render(await Home())
    const link = within(screen.getByRole("banner")).getByRole("link", { name: "GitHub, 23456 estrelas" })
    expect(link.getAttribute("href")).toBe(repoUrl)
    expect(link.textContent).toBe("+23K")
  })

  test.each([null, 0, 9])("com %s estrelas, o link mostra só GitHub", async (stars) => {
    github.stars = stars
    render(await Home())
    expect(within(screen.getByRole("banner")).getByRole("link", { name: "GitHub" }).textContent).toBe("GitHub")
    github.stars = 23456
  })

  test("a partir de 10 estrelas, o número aparece", async () => {
    github.stars = 10
    render(await Home())
    expect(within(screen.getByRole("banner")).getByRole("link", { name: "GitHub, 10 estrelas" }).textContent).toBe("10")
    github.stars = 23456
  })

  test("tem o título principal", async () => {
    render(await Home())
    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("agente de IA")
  })

  test("cada link do menu leva a uma seção que existe", async () => {
    const { container } = render(await Home())
    const nav = screen.getByRole("navigation")
    const links = within(nav).getAllByRole("link")
    expect(links.length).toBeGreaterThan(0)
    for (const link of links) {
      const id = link.getAttribute("href")?.slice(1)
      expect(id && container.querySelector(`#${id}`)).toBeTruthy()
    }
  })

  test("mostra todos os comandos", async () => {
    render(await Home())
    for (const c of commands) expect(screen.getAllByText(c.cmd).length).toBeGreaterThan(0)
  })

  test("mostra a versão, o GitHub e o comando de instalação", async () => {
    render(await Home())
    expect(screen.getByText(new RegExp(`${version} · open source`))).toBeTruthy()
    expect(document.querySelectorAll(`a[href="${repoUrl}"]`).length).toBeGreaterThan(0)
    expect(screen.getAllByText(installCommand).length).toBeGreaterThan(0)
    expect(screen.queryByText(/em breve/)).toBeNull()
  })
})
