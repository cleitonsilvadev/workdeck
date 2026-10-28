import { describe, expect, test, vi } from "vitest"
import { render, screen, within } from "@testing-library/react"
import Home from "@/app/page"
import { commands, repoUrl } from "@/lib/site"

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

  test("enquanto não lança, mostra em breve e esconde o GitHub", () => {
    render(<Home />)
    expect(screen.getAllByText(/em breve/).length).toBeGreaterThan(0)
    expect(document.querySelector(`a[href="${repoUrl}"]`)).toBeNull()
  })
})
