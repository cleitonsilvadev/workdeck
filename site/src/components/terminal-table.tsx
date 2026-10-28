import { Check, Minus } from "lucide-react"
import type { Dictionary } from "@/lib/dictionaries"
import { cn } from "@/lib/utils"

function Value({ value, terminals }: { value: string | boolean; terminals: Dictionary["terminals"] }) {
  if (value === true) return <Check aria-label={terminals.yes} className="mx-auto size-4 text-ctp-green" />
  if (value === false) return <Minus aria-label={terminals.no} className="mx-auto size-4 text-ctp-overlay0" />
  return <span className="text-ctp-subtext1">{value}</span>
}

export function TerminalTable({ terminals }: { terminals: Dictionary["terminals"] }) {
  return (
    <div className="overflow-x-auto rounded-2xl border border-border bg-ctp-mantle/70">
      <table className="w-full min-w-[520px] border-collapse text-sm">
        <thead>
          <tr className="border-b border-ctp-surface0">
            <th scope="col" className="w-1/3 p-4" />
            {terminals.columns.map((c, i) => (
              <th key={c.name} scope="col" className="p-4 text-center font-normal">
                <span className={cn("block font-mono text-sm", i === 0 ? "text-ctp-mauve" : "text-ctp-text")}>{c.name}</span>
                <span className="mt-1 block text-xs text-ctp-overlay1">{c.hint}</span>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {terminals.rows.map((r, i) => (
            <tr key={r.label} className={cn(i > 0 && "border-t border-ctp-surface0/60", i === 0 && "bg-ctp-green/5")}>
              <th scope="row" className="p-4 text-left font-medium text-ctp-text">{r.label}</th>
              {r.values.map((v, j) => (
                <td key={terminals.columns[j].name} className="p-4 text-center">
                  <Value value={v} terminals={terminals} />
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
