export const minStars = 10

export function showStars(stars: number | null): stars is number {
  return stars !== null && stars >= minStars
}

export function formatStars(stars: number) {
  return stars >= 1000 ? `+${Math.floor(stars / 1000)}K` : String(stars)
}
