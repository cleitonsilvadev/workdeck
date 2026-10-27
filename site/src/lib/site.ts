export const released = false

export const comingSoonPhrases = [
  "repositório público, licença mit",
  "polindo o readme antes de abrir",
  "feat: abrir o código para todos",
  "git push origin main",
  "private → public",
] as const

export const repoUrl = "https://github.com/thiagofeliperibeiro/workdeck"

export const installCommand = `git clone ${repoUrl}.git && cd workdeck && ./install.sh`

export const commands = [
  { cmd: "work", desc: "Abre a sessão, uma janela por projeto. Ou volta para ela." },
  { cmd: "work add ~/code/api", desc: "Acrescenta um projeto. Sem caminho, usa a pasta atual." },
  { cmd: "ai", desc: "Abre a IA ao lado, para te ajudar no projeto, já na pasta dele. O ai help explica." },
  { cmd: "work review", desc: "Revisa o que o agente escreveu antes do commit. O mesmo que git review." },
  { cmd: "work agent claude", desc: "Define qual é o seu agente de IA. Qualquer comando serve." },
  { cmd: "work painel", desc: "Abre o painel de contexto: branches, mudanças soltas, o que você quiser." },
  { cmd: "work doctor", desc: "Diz o que funciona no seu ambiente e o que não vai funcionar." },
  { cmd: "work help", desc: "O menu com as ações, os atalhos e o que falta configurar." },
]

export const features = [
  {
    icon: "bot",
    title: "Qualquer agente de CLI",
    desc: "Claude Code, Codex, Copilot CLI, Aider, Gemini. O workdeck não embute nenhum: abre o comando que você escolher.",
  },
  {
    icon: "terminal",
    title: "Qualquer terminal",
    desc: "Os atalhos são do tmux, não do terminal. macOS e Linux; no Windows, pelo WSL.",
  },
  {
    icon: "history",
    title: "A sessão sobrevive",
    desc: "Fechar o terminal, cair a conexão ou reiniciar a máquina. Você volta com work e tudo está onde estava, agente incluso.",
  },
  {
    icon: "undo",
    title: "Instalação reversível",
    desc: "Cópia de cada arquivo antes do primeiro toque e um manifesto do que foi feito. O --restore devolve tudo byte a byte.",
  },
  {
    icon: "panels",
    title: "Painéis seus",
    desc: "Qualquer executável que imprima texto vira painel. Containers, CI, tarefas do dia. Sem reinstalar nada.",
  },
  {
    icon: "palette",
    title: "Temas com contraste medido",
    desc: "Catppuccin Mocha, Nord e Min Dark, com verde e vermelho separados também em luminosidade, para ler diff sem cansar.",
  },
] as const

export const shortcuts = {
  navegar: [
    { prefix: true, keys: ["h"], desc: "Abre o menu com tudo" },
    { prefix: false, keys: ["Shift", "← →"], desc: "Projeto anterior / próximo" },
    { prefix: true, keys: ["1…9"], desc: "Vai direto para a janela N" },
    { prefix: false, keys: ["Shift", "↑ ↓"], desc: "Troca de painel na janela" },
  ],
  agir: [
    { prefix: true, keys: ["a"], desc: "Abre a IA ao lado" },
    { prefix: true, keys: ["Enter"], desc: "Divide a tela onde couber" },
    { prefix: true, keys: ["v"], desc: "Divide ao lado" },
    { prefix: true, keys: ["-"], desc: "Divide embaixo" },
    { prefix: true, keys: ["z"], desc: "Zoom no painel, e de novo para voltar" },
    { prefix: true, keys: ["x"], desc: "Fecha o painel" },
  ],
} as const

export const themes = [
  {
    id: "catppuccin-mocha",
    name: "Catppuccin Mocha",
    note: "Pastel por construção. O padrão.",
    bg: "#1e1e2e",
    fg: "#cdd6f4",
    bar: "#181825",
    muted: "#7f849c",
    accent: "#cba6f7",
    red: "#f38ba8",
    green: "#a6e3a1",
    yellow: "#f9e2af",
    blue: "#89b4fa",
    cyan: "#94e2d5",
    palette: ["#45475a", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7", "#94e2d5", "#bac2de"],
  },
  {
    id: "nord",
    name: "Nord",
    note: "Frio e dessaturado. Verde e vermelho próximos em luminosidade pesam ao ler diff.",
    bg: "#2e3440",
    fg: "#d8dee9",
    bar: "#3b4252",
    muted: "#4c566a",
    accent: "#88c0d0",
    red: "#bf616a",
    green: "#a3be8c",
    yellow: "#ebcb8b",
    blue: "#81a1c1",
    cyan: "#8fbcbb",
    palette: ["#3b4252", "#bf616a", "#a3be8c", "#ebcb8b", "#81a1c1", "#b48ead", "#88c0d0", "#e5e9f0"],
  },
  {
    id: "min-dark",
    name: "Min Dark",
    note: "Neutro, derivado do Min Dark do VS Code, com o texto em ~9,6:1.",
    bg: "#1f1f1f",
    fg: "#c3c6c8",
    bar: "#1a1a1a",
    muted: "#5c5c5c",
    accent: "#a690cc",
    red: "#e07b85",
    green: "#5bbd8b",
    yellow: "#d9a278",
    blue: "#7fa8d4",
    cyan: "#6aa8bd",
    palette: ["#1a1a1a", "#e07b85", "#5bbd8b", "#d9a278", "#7fa8d4", "#a690cc", "#6aa8bd", "#b4b7b9"],
  },
] as const

export const install = {
  macos: [
    { cmd: `git clone ${repoUrl}.git`, out: "" },
    { cmd: "cd workdeck && ./install.sh", out: "brew instala tmux e git-delta se faltarem" },
    { cmd: "source ~/.zshrc", out: "" },
    { cmd: "work add ~/code/api", out: "um projeto por vez; Tab completa o caminho" },
    { cmd: "work", out: "" },
  ],
  linux: [
    { cmd: `git clone ${repoUrl}.git`, out: "" },
    { cmd: "cd workdeck && ./install.sh", out: "apt, dnf, pacman, zypper ou apk, o que houver" },
    { cmd: "source ~/.bashrc", out: "" },
    { cmd: "work add ~/code/api", out: "um projeto por vez; Tab completa o caminho" },
    { cmd: "work", out: "" },
  ],
  windows: [
    { cmd: "wsl --install", out: "no PowerShell, como administrador" },
    { cmd: "wsl", out: "entra no Linux" },
    { cmd: `git clone ${repoUrl}.git`, out: "" },
    { cmd: "cd workdeck && ./install.sh", out: "a partir daqui, igual ao Linux" },
  ],
}

export const uninstall = [
  { cmd: "./uninstall.sh", desc: "Tira os blocos e os scripts. Sua config fica." },
  { cmd: "./uninstall.sh --restore", desc: "Devolve os arquivos ao estado de antes da instalação." },
  { cmd: "./uninstall.sh --all", desc: "Remove tudo, inclusive ~/.config/workdeck." },
  { cmd: "./uninstall.sh --dry-run", desc: "Mostra o que faria, sem escrever nada." },
]

export const testimonials = [
  {
    name: "Thiago Ribeiro",
    role: "Desenvolvedor frontend · criador do workdeck",
    github: "https://github.com/thiagofeliperibeiro",
    photo: "",
    quote: "Abra, delegue e revise. Cada projeto na sua janela, o agente ao lado e o diff à vista antes de cada commit. Meu dia inteiro cabe num terminal.",
  },
]
