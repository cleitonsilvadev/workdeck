import type { Metadata } from "next";
import { Geist, JetBrains_Mono } from "next/font/google";
import { Providers } from "@/components/providers";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "workdeck — um workflow de terminal para agentes de IA",
  description:
    "Uma sessão do tmux, uma janela por projeto, o agente num pane ao lado e o git review para ver o que ele escreveu. macOS, Linux e WSL.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="pt-BR"
      className={`${geistSans.variable} ${jetbrainsMono.variable} dark mocha h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-ctp-crust">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
