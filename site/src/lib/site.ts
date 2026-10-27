export const repoUrl = "https://github.com/thiagofeliperibeiro/workdeck"

export const installCommand = `git clone ${repoUrl}.git && cd workdeck && ./install.sh`

export const commands = [
  { cmd: "work", desc: "Abre a sessão, uma janela por projeto. Ou volta para ela." },
  { cmd: "ai", desc: "Abre o seu agente de IA num pane ao lado, já na pasta do projeto." },
  { cmd: "git review", desc: "Mostra o que o agente escreveu, com cor de sintaxe e número de linha." },
  { cmd: "painel", desc: "Abre o painel de contexto: branches, mudanças soltas, o que você quiser." },
  { cmd: "workdeck-doctor", desc: "Diz o que funciona no seu ambiente e o que não vai funcionar." },
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
    { keys: ["Alt", "1…9"], desc: "Vai direto para a janela N" },
    { keys: ["Alt", "←↑↓→"], desc: "Pula entre os painéis" },
    { keys: ["Alt", "Shift", "← →"], desc: "Janela anterior / próxima" },
  ],
  agir: [
    { keys: ["Alt", "Shift", "A"], desc: "Abre o agente ao lado" },
    { keys: ["Alt", "Shift", "T"], desc: "Nova janela, na pasta atual" },
    { keys: ["Alt", "Shift", "D"], desc: "Divide lado a lado" },
    { keys: ["Alt", "Shift", "S"], desc: "Divide em cima/embaixo" },
    { keys: ["Alt", "Shift", "Z"], desc: "Zoom: o painel ocupa a janela" },
    { keys: ["Alt", "Shift", "X"], desc: "Fecha o painel" },
    { keys: ["Alt", "Shift", "R"], desc: "Renomeia a janela" },
    { keys: ["Alt", "Shift", "E"], desc: "Solta a sessão, que continua viva" },
  ],
}

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
    { cmd: "$EDITOR ~/.config/workdeck/projects.conf", out: "seus projetos, uma linha por janela" },
    { cmd: "source ~/.zshrc && work", out: "" },
  ],
  linux: [
    { cmd: `git clone ${repoUrl}.git`, out: "" },
    { cmd: "cd workdeck && ./install.sh", out: "apt, dnf, pacman, zypper ou apk, o que houver" },
    { cmd: "$EDITOR ~/.config/workdeck/projects.conf", out: "seus projetos, uma linha por janela" },
    { cmd: "source ~/.bashrc && work", out: "" },
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
