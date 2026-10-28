import { afterEach, beforeEach, describe, expect, test, vi } from "vitest"
import { act, render, screen } from "@testing-library/react"
import { CycleDemo } from "@/components/cycle-demo"
import { cycle } from "@/lib/site"

describe("animated workflow", () => {
  beforeEach(() => vi.useFakeTimers())
  afterEach(() => vi.useRealTimers())

  function advance(...durations: number[]) {
    for (const ms of durations) act(() => vi.advanceTimersByTime(ms))
  }

  function chapters() {
    return cycle.map((c) => screen.getByRole("button", { name: new RegExp(c.label.replace(/[~/]/g, "\\$&")) }))
  }

  test("starts outside workdeck, typing work in kitty", () => {
    render(<CycleDemo />)
    expect(screen.getByText("kitty")).toBeTruthy()
    expect(chapters()[0].getAttribute("aria-current")).toBe("step")
    expect(screen.getByText(cycle[0].desc)).toBeTruthy()
  })

  test("work add reports the window opened in the background, and Shift+→ goes to it", () => {
    render(<CycleDemo />)
    advance(1100, 1400, 1700)
    expect(screen.getByText("workdeck — tmux")).toBeTruthy()
    expect(screen.getByText("~/api entrou no seu work como api")).toBeTruthy()
    expect(screen.getByText("a janela api já está aberta na sessão work")).toBeTruthy()
    expect(screen.queryByText("shell · api")).toBeNull()
    advance(1600)
    expect(screen.getByText(/vai para a janela api/)).toBeTruthy()
    expect(chapters()[1].getAttribute("aria-current")).toBe("step")
  })

  test("clicking a chapter jumps to it and changes the caption", async () => {
    vi.useRealTimers()
    render(<CycleDemo />)
    act(() => chapters()[3].click())
    expect(chapters()[3].getAttribute("aria-current")).toBe("step")
    expect(chapters()[0].getAttribute("aria-current")).toBeNull()
    expect(screen.getByText("shell · api")).toBeTruthy()
    expect(await screen.findByText(cycle[3].desc, {}, { timeout: 2000 })).toBeTruthy()
  })
})
