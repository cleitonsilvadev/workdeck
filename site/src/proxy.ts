import { match } from "@formatjs/intl-localematcher"
import Negotiator from "negotiator"
import { NextResponse, type NextRequest } from "next/server"
import { defaultLocale, hasLocale, localeCookie, locales } from "@/lib/i18n"

function preferredLocale(request: NextRequest) {
  const saved = request.cookies.get(localeCookie)?.value
  if (saved && hasLocale(saved)) return saved
  const languages = new Negotiator({ headers: { "accept-language": request.headers.get("accept-language") ?? "" } }).languages()
  try {
    return match(languages, locales, defaultLocale)
  } catch {
    return defaultLocale
  }
}

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl
  if (pathname === "/") {
    request.nextUrl.pathname = `/${preferredLocale(request)}`
    return NextResponse.redirect(request.nextUrl)
  }
  if (hasLocale(pathname.split("/")[1] ?? "")) return
  return new NextResponse("Not found", { status: 404, headers: { "content-type": "text/plain; charset=utf-8" } })
}

export const config = {
  matcher: ["/((?!_next|api|.*\\..*).*)"],
}
