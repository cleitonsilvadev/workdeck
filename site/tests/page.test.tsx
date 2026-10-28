import { describe, expect, test, vi } from "vitest"
import { render, screen, within } from "@testing-library/react"
import Home from "@/app/page"
import { commands, installCommand, repoUrl, version } from "@/lib/site"

vi.mock("next/font/google", () => ({ Geist: () => ({ variable: "" }), JetBrains_Mono: () => ({ variable: "" }) }))

describe("página inicial", () => {
  test("tem o título principal", () => {
    render(<Home />)
    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("agente de IA")
  })

  test("cada link do menu leva a uma seção que existe", () => {
    const { container } = render(<Home />)
    const nav = screen.getByRole("navigation")
    const links = within(nav).getAllByRole("link")
    expect(links.length).toBeGreaterThan(0)
    for (const link of links) {
      const id = link.getAttribute("href")?.slice(1)
      expect(id && container.querySelector(`#${id}`)).toBeTruthy()
    }
  })

  test("mostra todos os comandos", () => {
    render(<Home />)
    for (const c of commands) expect(screen.getAllByText(c.cmd).length).toBeGreaterThan(0)
  })

  test("mostra a versão, o GitHub e o comando de instalação", () => {
    render(<Home />)
    expect(screen.getByText(new RegExp(`${version} · open source`))).toBeTruthy()
    expect(document.querySelectorAll(`a[href="${repoUrl}"]`).length).toBeGreaterThan(0)
    expect(screen.getAllByText(installCommand).length).toBeGreaterThan(0)
    expect(screen.queryByText(/em breve/)).toBeNull()
  })
})
