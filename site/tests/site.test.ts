import { describe, expect, test } from "vitest"
import { commands, cycle, features, install, installCommand, panelRules, panelsUrl, repoUrl, shortcuts, themes, uninstall, version } from "@/lib/site"

function unique(values: readonly string[]) {
  return new Set(values).size === values.length
}

describe("site content", () => {
  test("the version follows vX.Y.Z", () => {
    expect(version).toMatch(/^v\d+\.\d+\.\d+$/)
  })

  test("the commands are workdeck's, without duplicates", () => {
    const names = commands.map((c) => c.cmd.split(" ").slice(0, 2).join(" "))
    expect(names).toEqual(["work", "work add", "work review", "work update", "work kill", "work uninstall"])
    expect(unique(commands.map((c) => c.cmd))).toBe(true)
    for (const c of commands) expect(c.desc.length).toBeGreaterThan(0)
  })

  test("the workflow has four steps, from work add to work review", () => {
    expect(cycle.map((c) => c.label)).toEqual(["work add ~/api", "janela do projeto", "agente ao lado", "work review"])
    for (const c of cycle) expect(c.desc.length).toBeGreaterThan(0)
  })

  test("the install command downloads get.sh from the repository with curl -fsSL", () => {
    const [, owner, repo] = new URL(repoUrl).pathname.split("/")
    expect(installCommand).toBe(`curl -fsSL https://raw.githubusercontent.com/${owner}/${repo}/main/get.sh | bash`)
    for (const steps of Object.values(install)) {
      expect(steps[0].cmd).toBe(installCommand)
      expect(steps.at(-1)?.cmd).toBe("work")
    }
  })

  test("the panels guide points to the repository", () => {
    expect(panelsUrl.startsWith(`${repoUrl}/blob/main/docs/`)).toBe(true)
  })

  test("lists used as React keys have no duplicates", () => {
    expect(unique(features.map((f) => f.title))).toBe(true)
    expect(unique(panelRules.map((r) => r.code))).toBe(true)
    expect(unique(uninstall.map((u) => u.cmd))).toBe(true)
    expect(unique([...shortcuts.navigate, ...shortcuts.act].map((s) => s.desc))).toBe(true)
    expect(unique(themes.map((t) => t.id))).toBe(true)
  })

  test("uninstall starts with work uninstall", () => {
    expect(uninstall[0].cmd).toBe("work uninstall")
  })

  test("each theme has hex colors and eight palette colors", () => {
    for (const t of themes) {
      const { id, name, note, palette, ...colors } = t
      expect(id && name && note).toBeTruthy()
      for (const c of [...Object.values(colors), ...palette]) expect(c).toMatch(/^#[0-9a-f]{6}$/)
      expect(palette).toHaveLength(8)
    }
  })
})
