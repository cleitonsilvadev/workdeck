import { cacheLife } from "next/cache"
import { repoUrl } from "@/lib/site"

export async function getStars() {
  "use cache"
  cacheLife("hours")
  const repo = new URL(repoUrl).pathname
  try {
    const res = await fetch(`https://api.github.com/repos${repo}`, { headers: { Accept: "application/vnd.github+json" } })
    if (!res.ok) return null
    const data: { stargazers_count?: unknown } = await res.json()
    return typeof data.stargazers_count === "number" ? data.stargazers_count : null
  } catch {
    return null
  }
}
