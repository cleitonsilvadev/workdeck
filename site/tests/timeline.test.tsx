import { afterEach, beforeEach, describe, expect, test, vi } from "vitest"
import { act, render, screen } from "@testing-library/react"
import { useSteps, useTimeline } from "@/components/terminal-parts"

const reduced = vi.hoisted(() => ({ value: false }))

vi.mock("motion/react", async (original) => ({
  ...(await original<typeof import("motion/react")>()),
  useReducedMotion: () => reduced.value,
}))

function Steps({ timeline }: { timeline: number[] }) {
  const step = useTimeline(timeline)
  return <output>{step}</output>
}

function Jump({ timeline }: { timeline: number[] }) {
  const [step, setStep] = useSteps(timeline)
  return (
    <>
      <output>{step}</output>
      <button onClick={() => setStep(2)}>pular</button>
    </>
  )
}

describe("linha do tempo dos terminais animados", () => {
  beforeEach(() => vi.useFakeTimers())
  afterEach(() => {
    vi.useRealTimers()
    reduced.value = false
  })

  test("avança um passo a cada intervalo e recomeça no fim", () => {
    render(<Steps timeline={[100, 200]} />)
    expect(screen.getByRole("status").textContent).toBe("0")
    act(() => vi.advanceTimersByTime(100))
    expect(screen.getByRole("status").textContent).toBe("1")
    act(() => vi.advanceTimersByTime(200))
    expect(screen.getByRole("status").textContent).toBe("2")
    act(() => vi.advanceTimersByTime(200))
    expect(screen.getByRole("status").textContent).toBe("0")
  })

  test("com movimento reduzido, vai direto para o fim e para lá", () => {
    reduced.value = true
    render(<Steps timeline={[100, 200, 300]} />)
    expect(screen.getByRole("status").textContent).toBe("0")
    act(() => vi.advanceTimersByTime(0))
    expect(screen.getByRole("status").textContent).toBe("3")
    act(() => vi.advanceTimersByTime(5000))
    expect(screen.getByRole("status").textContent).toBe("3")
  })

  test("pular leva a um passo e continua dali", () => {
    render(<Jump timeline={[100, 100, 100, 100]} />)
    act(() => screen.getByRole("button").click())
    expect(screen.getByRole("status").textContent).toBe("2")
    act(() => vi.advanceTimersByTime(100))
    expect(screen.getByRole("status").textContent).toBe("3")
  })
})
