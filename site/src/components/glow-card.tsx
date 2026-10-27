import { MagicCard } from "@/components/ui/magic-card"
import { cn } from "@/lib/utils"

export function GlowCard({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <MagicCard
      className={cn("h-full rounded-2xl", className)}
      gradientSize={320}
      gradientFrom="var(--catppuccin-color-mauve)"
      gradientTo="var(--catppuccin-color-blue)"
      gradientColor="color-mix(in oklch, var(--catppuccin-color-mauve) 12%, transparent)"
      gradientOpacity={1}
    >
      {children}
    </MagicCard>
  )
}
