import { connection } from "next/server"
import { getInstallScript } from "@/lib/github"
import { installScriptUrl } from "@/lib/site"

export async function GET() {
  await connection()
  const script = await getInstallScript()
  if (!script) return Response.redirect(installScriptUrl, 302)
  return new Response(script, {
    headers: { "Content-Type": "text/plain; charset=utf-8", "Cache-Control": "no-store" },
  })
}
