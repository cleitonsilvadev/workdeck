import { connection } from "next/server"
import { getVersion } from "@/lib/github"

export async function GET() {
  await connection()
  return new Response(`${await getVersion()}\n`, {
    headers: { "Content-Type": "text/plain; charset=utf-8", "Cache-Control": "no-store" },
  })
}
