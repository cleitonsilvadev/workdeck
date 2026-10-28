import { describe, expect, test } from "vitest"
import { commands, cycle, features, install, installCommand, panelRules, panelsUrl, repoUrl, shortcuts, themes, uninstall, version } from "@/lib/site"

function unique(values: readonly string[]) {
  return new Set(values).size === values.length
}

describe("conteúdo do site", () => {
  test("a versão segue vX.Y.Z", () => {
    expect(version).toMatch(/^v\d+\.\d+\.\d+$/)
  })

  test("os comandos são os do workdeck, sem repetir", () => {
    const names = commands.map((c) => c.cmd.split(" ").slice(0, 2).join(" "))
    expect(names).toEqual(["work", "work add", "work review", "work update", "work kill", "work uninstall"])
    expect(unique(commands.map((c) => c.cmd))).toBe(true)
    for (const c of commands) expect(c.desc.length).toBeGreaterThan(0)
  })

  test("o ciclo tem os quatro passos, do work add ao work review", () => {
    expect(cycle.map((c) => c.label)).toEqual(["work add ~/api", "janela do projeto", "agente ao lado", "work review"])
    for (const c of cycle) expect(c.desc.length).toBeGreaterThan(0)
  })

  test("a instalação baixa o instalar.sh do repositório com curl -fsSL", () => {
    const [, owner, repo] = new URL(repoUrl).pathname.split("/")
    expect(installCommand).toBe(`curl -fsSL https://raw.githubusercontent.com/${owner}/${repo}/main/instalar.sh | bash`)
    for (const steps of Object.values(install)) {
      expect(steps[0].cmd).toBe(installCommand)
      expect(steps.at(-1)?.cmd).toBe("work")
    }
  })

  test("o guia de painéis aponta para o repositório", () => {
    expect(panelsUrl.startsWith(`${repoUrl}/blob/main/docs/`)).toBe(true)
  })

  test("listas usadas como chave do React não repetem", () => {
    expect(unique(features.map((f) => f.title))).toBe(true)
    expect(unique(panelRules.map((r) => r.code))).toBe(true)
    expect(unique(uninstall.map((u) => u.cmd))).toBe(true)
    expect(unique([...shortcuts.navegar, ...shortcuts.agir].map((s) => s.desc))).toBe(true)
    expect(unique(themes.map((t) => t.id))).toBe(true)
  })

  test("o desinstalar começa pelo work uninstall", () => {
    expect(uninstall[0].cmd).toBe("work uninstall")
  })

  test("cada tema tem cores hexadecimais e oito cores na paleta", () => {
    for (const t of themes) {
      const { id, name, note, palette, ...colors } = t
      expect(id && name && note).toBeTruthy()
      for (const c of [...Object.values(colors), ...palette]) expect(c).toMatch(/^#[0-9a-f]{6}$/)
      expect(palette).toHaveLength(8)
    }
  })
})
