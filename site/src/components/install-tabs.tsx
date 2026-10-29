"use client"

import { CopyButton, type CopyLabels } from "@/components/copy-button"
import type { Dictionary } from "@/lib/dictionaries"

export function InstallTabs({ install, labels }: { install: Dictionary["install"]; labels: CopyLabels }) {
  return (
    <div className="overflow-hidden rounded-2xl border border-border bg-ctp-mantle">
      <ol className="divide-y divide-ctp-surface0/70 font-mono text-sm">
        {install.macos.map((step, i) => (
          <li key={step.cmd} className="flex items-center gap-4 px-4 py-3 sm:px-5">
            <span className="w-4 shrink-0 text-right text-xs text-ctp-overlay0">{i + 1}</span>
            <div className="min-w-0 flex-1">
              <div className="truncate">
                <span className="select-none text-ctp-mauve">$ </span>
                <span className="text-ctp-text">{step.cmd}</span>
              </div>
              {step.out && <div className="truncate text-xs text-ctp-overlay1"># {step.out}</div>}
            </div>
            <CopyButton text={step.cmd} labels={labels} />
          </li>
        ))}
      </ol>
    </div>
  )
}
