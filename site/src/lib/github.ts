import { cacheLife } from "next/cache"
import { installScriptUrl, repoUrl, version } from "@/lib/site"

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

function semver(tag: string) {
  const match = /^v(\d+)\.(\d+)\.(\d+)$/.exec(tag)
  return match ? match.slice(1).map(Number) : null
}

export function newestTag(tags: string[]) {
  const versions = tags.flatMap((tag) => {
    const parts = semver(tag)
    return parts ? [{ tag, parts }] : []
  })
  versions.sort((a, b) => b.parts[0] - a.parts[0] || b.parts[1] - a.parts[1] || b.parts[2] - a.parts[2])
  return versions[0]?.tag ?? null
}

export async function getVersion() {
  "use cache"
  cacheLife("hours")
  const repo = new URL(repoUrl).pathname
  try {
    const res = await fetch(`https://api.github.com/repos${repo}/tags?per_page=100`, { headers: { Accept: "application/vnd.github+json" } })
    if (!res.ok) return version
    const data: unknown = await res.json()
    if (!Array.isArray(data)) return version
    const names = data.map((t: { name?: unknown }) => t?.name).filter((n): n is string => typeof n === "string")
    return newestTag(names) ?? version
  } catch {
    return version
  }
}

export async function getInstallScript() {
  "use cache"
  cacheLife("minutes")
  try {
    const res = await fetch(installScriptUrl)
    if (!res.ok) return null
    const script = await res.text()
    return script.startsWith("#!") ? script : null
  } catch {
    return null
  }
}
