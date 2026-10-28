import { describe, expect, test, vi } from "vitest"
import { render, screen } from "@testing-library/react"
import Home from "@/app/page"
import { installCommand, repoUrl, version } from "@/lib/site"

vi.mock("@/lib/site", async (original) => ({
  ...(await original<typeof import("@/lib/site")>()),
  released: true,
}))

describe("página inicial depois do lançamento", () => {
  test("mostra a versão, o GitHub e o comando de instalação", () => {
    render(<Home />)
    expect(screen.getByText(new RegExp(`${version} · open source`))).toBeTruthy()
    expect(document.querySelectorAll(`a[href="${repoUrl}"]`).length).toBeGreaterThan(0)
    expect(screen.getAllByText(installCommand).length).toBeGreaterThan(0)
    expect(screen.queryByText("em breve")).toBeNull()
  })
})
