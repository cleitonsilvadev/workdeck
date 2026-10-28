export const released = false

export const version = "v1.0.3"

export const comingSoonPhrases = [
  "repositório público, licença mit",
  "polindo o readme antes de abrir",
  "feat: abrir o código para todos",
  "git push origin main",
  "private → public",
] as const

export const repoUrl = "https://github.com/thiagofeliperibeiro/workdeck"

export const installCommand = "curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/instalar.sh | bash"

export const commands = [
  { cmd: "work", desc: "Abre a sessão, uma janela por projeto. Ou volta para ela." },
  { cmd: "work add ~/projeto", desc: "Acrescenta um projeto. Sem caminho, usa a pasta atual; Tab completa o caminho." },
  { cmd: "work review", desc: "A IA faz um self code review da mudança num painel embaixo do chat. Com staged ou branch, muda o recorte." },
  { cmd: "work update", desc: "Mostra o que mudou na versão nova e atualiza. O work e o painel avisam quando há uma." },
  { cmd: "work kill", desc: "Fecha a sessão inteira. O próximo work abre com a lista de projetos atual." },
  { cmd: "work uninstall", desc: "Desinstala tudo o que o workdeck instalou. Mostra o que vai sair e pergunta antes." },
]

export const features = [
  {
    icon: "bot",
    title: "Qualquer agente de CLI",
    desc: "Claude Code, Codex, Copilot CLI, Aider, Gemini. O workdeck não traz nem abre nenhum: você abre o seu num painel, e o work review usa ele.",
  },
  {
    icon: "terminal",
    title: "Feito para o kitty",
    desc: "O kitty é o terminal do workdeck, e a instalação já traz ele com tema, fonte e atalhos cmd no Mac. Por SSH ou no terminal do editor o work abre, mas fica fora do suporte.",
  },
  {
    icon: "history",
    title: "A sessão sobrevive",
    desc: "Fechar o terminal ou cair a conexão. Você volta com work e tudo está onde estava, agente incluso. Depois de reiniciar a máquina, o work abre os projetos de novo.",
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
    { prefix: true, keys: ["d"], desc: "Sai e deixa a sessão rodando" },
  ],
  agir: [
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
    { cmd: installCommand, out: "instala o tmux pelo brew e o kitty, já com tema e fonte" },
    { cmd: "work", out: "abre o painel, que mostra como adicionar os seus projetos" },
  ],
  linux: [
    { cmd: installCommand, out: "tmux por apt, dnf, pacman, zypper ou apk, e o kitty" },
    { cmd: "work", out: "abre o painel, que mostra como adicionar os seus projetos" },
  ],
}

export const uninstall = [
  { cmd: "work uninstall", desc: "Desinstala tudo: blocos, código, zsh, fonte, kitty e config. O que você já tinha fica." },
  { cmd: "work uninstall --dry-run", desc: "Mostra o que faria, sem apagar nada." },
  { cmd: "uninstall.sh", desc: "Tira só os blocos e os scripts. Sua config fica." },
  { cmd: "uninstall.sh --restore", desc: "Devolve os arquivos ao estado de antes da instalação." },
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
