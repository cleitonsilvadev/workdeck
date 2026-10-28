#!/usr/bin/env bash
# workdeck — instalador. macOS e Linux.
#
#   ./install.sh                      instala com o tema padrão
#   ./install.sh --theme nord         escolhe um tema de themes/
#   ./install.sh --terminal kitty     instala também os atalhos cmd do kitty
#   ./install.sh --agent claude       define o seu agente de IA
#   ./install.sh --with ai-memory     ativa integrações opcionais (vírgula separa)
#   ./install.sh --list-integrations  mostra as integrações disponíveis e sai
#   ./install.sh --yes                não pergunta nada; usa os padrões
#   ./install.sh --no-deps            não instala nada pelo gerenciador de pacotes
#   ./install.sh --no-reload          não recarrega o tmux no fim
#   ./install.sh --dry-run            só mostra o que faria
#
# É idempotente: rodar de novo atualiza em vez de duplicar. O que ele escreve
# nos seus arquivos fica entre marcadores >>> workdeck >>>, e o uninstall.sh
# remove exatamente esse trecho.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck"
BIN_DIR="$HOME/.local/bin"
CODIGO="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck"
THEME="catppuccin-mocha"
TERMINAL=""
AVISO_OPTION=""
AGENT=""
WITH=""
YES=0
DEPS=1
RELOAD=1
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --theme) THEME="${2:?--theme precisa de um nome}"; shift 2 ;;
    --terminal) TERMINAL="${2:?--terminal precisa de um nome}"; shift 2 ;;
    --agent) AGENT="${2:?--agent precisa de um comando}"; shift 2 ;;
    --with) WITH="${2:?--with precisa de um nome}"; shift 2 ;;
    --yes|-y) YES=1; shift ;;
    --list-integrations)
      for f in "$ROOT"/integrations/*.sh; do
        [ "$(basename "$f")" = "exemplo.sh" ] && continue
        ( . "$f"; printf '  %s\n' "$(descrever | head -1)"
          descrever | tail -n +2 | sed 's/^/      /' )
        echo
      done
      exit 0 ;;
    --no-deps) DEPS=0; shift ;;
    --no-reload) RELOAD=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $1"; exit 1 ;;
  esac
done

BACKUPS="$CONFIG_DIR/.backups"
MANIFESTO="$CONFIG_DIR/.install-manifest"

anota() { # tipo, caminho, backup
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$MANIFESTO")"
  grep -qxF "$1|$2|${3:-}" "$MANIFESTO" 2>/dev/null || echo "$1|$2|${3:-}" >> "$MANIFESTO"
}

# Guarda uma cópia do arquivo como ele estava antes de o workdeck existir nele.
# Só na primeira vez: reinstalar não sobrescreve o backup original.
faz_backup() { # arquivo → imprime o caminho do backup, ou vazio
  local file="$1" nome destino
  [ -f "$file" ] || return 0
  grep -q "^# >>> workdeck >>>$" "$file" 2>/dev/null && return 0   # já instalado antes
  nome="$(echo "${file#$HOME/}" | tr '/' '-' | sed 's/^\.//')"
  destino="$BACKUPS/$nome.$(date +%Y%m%d-%H%M%S)"
  [ "$DRY" = 1 ] && { echo ""; return 0; }
  mkdir -p "$BACKUPS"
  cp "$file" "$destino"
  echo "$destino"
}

# Troca o bloco entre os marcadores, ou acrescenta se ainda não existir.
write_block() { # arquivo, conteúdo
  local file="$1" body="$2" tmp backup
  if [ -e "$file" ] && [ ! -f "$file" ]; then
    aviso "$(curto "$file") não é um arquivo comum; não mexi nele"
    return 0
  fi
  backup="$(faz_backup "$file")"
  [ -n "$backup" ] && say "cópia do original em ${backup#$HOME/}"
  # Arquivo que não existia: o uninstall apaga em vez de deixá-lo vazio.
  [ -e "$file" ] || backup=":criado"
  # Só a primeira instalação diz como o arquivo era antes; reinstalar não reescreve isso.
  grep -qF "bloco|$file|" "$MANIFESTO" 2>/dev/null || anota bloco "$file" "$backup"
  [ "$DRY" = 1 ] && { say "[dry-run] atualizaria o bloco em $file"; return 0; }
  mkdir -p "$(dirname "$file")"
  touch "$file"
  tmp="$(mktemp)"
  awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$file" > "$tmp"
  awk 'BEGIN{n=0} {l[n++]=$0} END{while(n>0 && l[n-1]~/^[[:space:]]*$/) n--; for(i=0;i<n;i++) print l[i]}' "$tmp" > "$tmp.2"
  { cat "$tmp.2"; [ -s "$tmp.2" ] && echo; echo "$body"; } > "$file"
  rm -f "$tmp" "$tmp.2"
}


# Compara conteúdo sem depender do cmp, que não vem em toda distribuição mínima.
iguais() { [ "$(cksum < "$1")" = "$(cksum < "$2")" ]; }
BONITO=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != dumb ] && [ "$DRY" = 0 ]; then BONITO=1; fi
verde=""; amarelo=""; vermelho=""; roxo=""; dim=""; bold=""; reset=""
if [ "$BONITO" = 1 ]; then
  verde=$'\033[32m'; amarelo=$'\033[33m'; vermelho=$'\033[31m'; roxo=$'\033[35m'
  dim=$'\033[2m'; bold=$'\033[1m'; reset=$'\033[0m'
fi
LOG="$(mktemp)"
ETAPA=""; RESUMO=""; AVISOS=(); GIRO=""

say() {
  if [ "$BONITO" = 1 ]; then printf '%s\n' "$*" >> "$LOG"; else printf '  %s\n' "$*"; fi
}
aviso() {
  [ "$BONITO" = 1 ] && AVISOS+=("$*")
  say "$*"
}
resumo() { RESUMO="$*"; }
curto() { case "$1" in "$HOME"/*) echo "~/${1#"$HOME"/}" ;; *) echo "$1" ;; esac; }
run() {
  [ "$DRY" = 1 ] && { say "[dry-run] $*"; return 0; }
  if [ "$BONITO" = 1 ]; then "$@" >> "$LOG" 2>&1; else "$@"; fi
}

girar() {
  [ "$BONITO" = 1 ] || return 0
  (
    quadros=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏); i=0
    while :; do
      printf '\r  %s%s%s %s' "$roxo" "${quadros[$((i % 10))]}" "$reset" "$ETAPA"
      i=$((i + 1)); sleep 0.08
    done
  ) &
  GIRO=$!
}
parar() {
  if [ -n "$GIRO" ]; then
    kill "$GIRO" 2>/dev/null || true
    wait "$GIRO" 2>/dev/null || true
    GIRO=""
    printf '\r\033[K'
  fi
  return 0
}
etapa() {
  ETAPA="$2"; RESUMO=""; AVISOS=()
  if [ "$BONITO" = 1 ]; then girar; else echo "[$1/7] $2"; fi
}
concluir() {
  local a marca largura
  if [ "$BONITO" = 1 ]; then
    parar
    marca="${verde}✓${reset}"
    [ ${#AVISOS[@]} -gt 0 ] && marca="${amarelo}!${reset}"
    largura=$(printf '%s' "$ETAPA" | LC_ALL=C tr -d '\200-\277' | wc -c)
    printf '  %s %s%*s %s%s%s\n' "$marca" "$ETAPA" $((14 - largura)) "" "$dim" "$RESUMO" "$reset"
    for a in ${AVISOS[@]+"${AVISOS[@]}"}; do printf '      %s%s%s\n' "$amarelo" "$a" "$reset"; done
  else
    echo
  fi
  ETAPA=""
}
ao_sair() {
  local status=$?
  parar
  if [ "$status" != 0 ] && [ "$BONITO" = 1 ] && [ -n "$ETAPA" ]; then
    printf '  %s✗%s %s\n' "$vermelho" "$reset" "$ETAPA"
    tail -n 15 "$LOG" | sed 's/^/      /'
  fi
  [ "$BONITO" = 1 ] && printf '\033[?25h'
  rm -f "$LOG"
}
trap ao_sair EXIT
[ "$BONITO" = 1 ] && exec 2>>"$LOG"

terminal_atual() {
  if [ -n "${KITTY_WINDOW_ID:-}" ]; then echo kitty
  elif [ -n "${WEZTERM_PANE:-}" ]; then echo WezTerm
  elif [ -n "${ALACRITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = alacritty ]; then echo Alacritty
  elif [ -n "${GHOSTTY_RESOURCES_DIR:-}" ]; then echo Ghostty
  else echo "${TERM_PROGRAM:-}"; fi
}

option_ligado_no_terminal_app() {
  local perfil tmp v
  perfil="$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || echo Basic)"
  tmp="$(mktemp)"
  defaults export com.apple.Terminal "$tmp" 2>/dev/null
  v="$(/usr/libexec/PlistBuddy -c "Print ':Window Settings:$perfil:useOptionAsMetaKey'" "$tmp" 2>/dev/null)"
  rm -f "$tmp"
  [ "$v" = true ]
}

VISUAL_ESCOLHA="$CONFIG_DIR/visual"
GNOME_BASE="/org/gnome/terminal/legacy/profiles:/"
GNOME_ID="5e1f9a2c-7d3b-4c6a-9b8e-0a1d2c3b4e5f"

cor() { awk -v k="$1" '$1 == k {print $2}' "$ROOT/themes/$THEME.conf"; }
cor_16bits() { local h="${1#\#}"; printf '%d, %d, %d' $((16#${h:0:2} * 257)) $((16#${h:2:2} * 257)) $((16#${h:4:2} * 257)); }

kitty_instalado() {
  [ -d /Applications/kitty.app ] || command -v kitty >/dev/null || [ -x "$HOME/.local/kitty.app/bin/kitty" ]
}

terminais_com_visual() {
  if [ "$SO" = macOS ]; then
    command -v osascript >/dev/null && echo "Terminal.app"
  elif command -v gnome-terminal >/dev/null && command -v dconf >/dev/null; then
    echo "GNOME Terminal"
  fi
  kitty_instalado && echo "kitty"
  return 0
}

aplicar_kitty() {
  local bloco
  bloco="$(sed '$d' "$ROOT/terminals/kitty.conf" | sed '/^# O tema entra aqui/d')"
  [ "$SO" = macOS ] || bloco="$(printf '%s\n' "$bloco" | grep -v '^map cmd\|^macos_')"
  write_block "$HOME/.config/kitty/kitty.conf" "$(printf '%s\n' "$bloco"; cat "$ROOT/themes/$THEME.conf"; echo '# <<< workdeck <<<')"
  say "kitty.conf — tema, fonte e atalhos"
}

aplicar_terminal_app() {
  local antes
  if ! pgrep -x Terminal >/dev/null; then
    say "Terminal.app fechado; abra ele e rode work install para aplicar o visual nele"
    return 1
  fi
  [ "$DRY" = 1 ] && { say "[dry-run] aplicaria a fonte e as cores no Terminal.app"; return 0; }
  antes="$(osascript -e 'tell application "Terminal" to get {name, font name, font size, background color, normal text color} of default settings' 2>/dev/null | tr -d ' ')" || {
    aviso "não consegui falar com o Terminal.app; escolha a fonte em Settings → Profiles → Text"
    return 1
  }
  grep -qF "terminal-app|" "$MANIFESTO" 2>/dev/null || anota terminal-app "$antes"
  if osascript >> "$LOG" 2>&1 <<FIM
tell application "Terminal"
  set s to default settings
  set background color of s to {$(cor_16bits "$(cor background)")}
  set normal text color of s to {$(cor_16bits "$(cor foreground)")}
  try
    set font name of s to "JetBrainsMono-Regular"
    set font size of s to 12
  end try
end tell
FIM
  then
    say "Terminal.app: fonte e cores do workdeck no perfil ${antes%%,*}"
  else
    aviso "não consegui mudar o perfil do Terminal.app; escolha a fonte em Settings → Profiles → Text"
    return 1
  fi
}

aplicar_gnome() {
  local lista padrao paleta i k
  [ "$DRY" = 1 ] && { say "[dry-run] criaria o perfil workdeck no GNOME Terminal"; return 0; }
  lista="$(dconf read "${GNOME_BASE}list" 2>/dev/null || true)"
  padrao="$(dconf read "${GNOME_BASE}default" 2>/dev/null || true)"
  grep -qF "gnome|" "$MANIFESTO" 2>/dev/null || anota gnome "${padrao:-vazio}"
  paleta="["
  for i in $(seq 0 15); do paleta="$paleta'$(cor "color$i")'"; [ "$i" -lt 15 ] && paleta="$paleta, "; done
  paleta="$paleta]"
  k="${GNOME_BASE}:$GNOME_ID/"
  dconf write "${k}visible-name" "'workdeck'"
  dconf write "${k}use-theme-colors" "false"
  dconf write "${k}background-color" "'$(cor background)'"
  dconf write "${k}foreground-color" "'$(cor foreground)'"
  dconf write "${k}palette" "$paleta"
  dconf write "${k}use-system-font" "false"
  dconf write "${k}font" "'JetBrains Mono 12'"
  dconf write "${k}cell-height-scale" "1.1"
  case "$lista" in
    *"$GNOME_ID"*) ;;
    ""|"@as []") dconf write "${GNOME_BASE}list" "['b1dcc9dd-5262-4d8d-a863-c897e6d979b9', '$GNOME_ID']" ;;
    *) dconf write "${GNOME_BASE}list" "${lista%]}, '$GNOME_ID']" ;;
  esac
  dconf write "${GNOME_BASE}default" "'$GNOME_ID'"
  say "GNOME Terminal: perfil workdeck criado e marcado como padrão"
}

visual_dos_terminais() {
  local achados escolha r aplicados="" t
  achados="$(terminais_com_visual)"
  [ -n "$achados" ] || return 0
  escolha="$(cat "$VISUAL_ESCOLHA" 2>/dev/null || cat "$CONFIG_DIR/terminal-app" 2>/dev/null || true)"
  [ "$escolha" = nao ] && return 0
  if [ "$escolha" != sim ]; then
    if [ "$YES" = 1 ] || [ ! -t 0 ]; then
      say "visual do workdeck nos terminais: rode work install e responda sim"
      return 0
    fi
    parar
    printf '  Aplicar o visual do workdeck (tema, fonte e cores) nos seus terminais?\n'
    printf '  Achei: %s   [S/n] ' "$(printf '%s\n' "$achados" | paste -sd, - | sed 's/,/, /g')"
    read -r r || r=n
    girar
    case "${r:-s}" in s|S|y|Y) escolha=sim ;; *) escolha=nao ;; esac
    [ "$DRY" = 1 ] || { mkdir -p "$CONFIG_DIR"; echo "$escolha" > "$VISUAL_ESCOLHA"; rm -f "$CONFIG_DIR/terminal-app"; }
    [ "$escolha" = sim ] || { say "terminais sem mudanças"; return 0; }
  fi
  while IFS= read -r t; do
    case "$t" in
      "Terminal.app") aplicar_terminal_app && aplicados="$aplicados, Terminal.app" ;;
      kitty) aplicar_kitty && aplicados="$aplicados, kitty" ;;
      "GNOME Terminal") aplicar_gnome && aplicados="$aplicados, GNOME Terminal" ;;
    esac
  done <<< "$achados"
  [ -n "$aplicados" ] && resumo "Ctrl+b, mouse e Alt · visual em ${aplicados#, }"
  return 0
}

como_ligar_option() {
  case "$1" in
    Apple_Terminal) echo 'Terminal → Ajustes → Perfis → Teclado → marque "Usar Option como tecla Meta"' ;;
    iTerm.app) echo 'iTerm2 → Settings → Profiles → Keys → General → "Left Option key": Esc+' ;;
    kitty) echo 'no kitty.conf, acrescente: macos_option_as_alt left' ;;
    Ghostty) echo 'na config do Ghostty, acrescente: macos-option-as-alt = left' ;;
    Alacritty) echo 'no alacritty.toml, em [window]: option_as_alt = "OnlyLeft"' ;;
    WezTerm) ;;
    *) echo 'nas preferências do seu terminal, faça a tecla Option funcionar como Alt (Meta)' ;;
  esac
}

[ -f "$ROOT/themes/$THEME.conf" ] || {
  echo "tema '$THEME' não existe. Disponíveis:"
  ls "$ROOT/themes"/*.conf | xargs -n1 basename | sed 's/\.conf$//; s/^/  /'
  exit 1
}

# ---- qual sistema ----------------------------------------------------------
case "$(uname -s)" in
  Darwin) SO="macOS"; GERENCIADOR="brew" ;;
  Linux)
    SO="Linux"
    if grep -qi microsoft /proc/version 2>/dev/null; then SO="Linux (WSL)"; fi
    for g in apt-get dnf pacman zypper apk; do
      command -v "$g" >/dev/null && { GERENCIADOR="$g"; break; }
    done
    GERENCIADOR="${GERENCIADOR:-}"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "O workdeck roda em macOS e Linux."
    exit 1
    ;;
  *) SO="$(uname -s)"; GERENCIADOR="" ;;
esac

if [ "$BONITO" = 1 ]; then
  if [ -n "${WORKDECK_ATUALIZANDO:-}" ]; then
    printf '\033[?25l'
  else
    printf '\033[?25l\n  %sworkdeck%s %s· %s · %s%s\n\n' "$bold" "$reset" "$dim" "$SO" "$THEME" "$reset"
  fi
else
  echo "workdeck → $SO, tema $THEME"
  echo
fi

# ---- 1. dependências -------------------------------------------------------
etapa 1 "dependências"
falta=()
command -v tmux >/dev/null || falta+=(tmux)
command -v delta >/dev/null || falta+=(git-delta)

if [ ${#falta[@]} -eq 0 ]; then
  say "tmux e git-delta já instalados"
elif [ "$DEPS" = 0 ]; then
  aviso "faltando: ${falta[*]} — instale por conta (--no-deps)"
else
  # Como root (num container, por exemplo) não há sudo, nem precisa.
  sudo=""; [ "$(id -u)" != 0 ] && sudo="sudo"
  if [ -n "$sudo" ] && [ "$GERENCIADOR" != brew ] && [ "$BONITO" = 1 ]; then
    parar; sudo -v; girar
  fi
  [ "$GERENCIADOR" = apt-get ] && { run $sudo apt-get update -qq || true; }
  for pacote in "${falta[@]}"; do
    [ "$GERENCIADOR" = apk ] && [ "$pacote" = git-delta ] && pacote=delta
    case "$GERENCIADOR" in
      brew)    instalar=(brew install "$pacote") ;;
      apt-get) instalar=($sudo apt-get install -y "$pacote") ;;
      dnf)     instalar=($sudo dnf install -y "$pacote") ;;
      pacman)  instalar=($sudo pacman -S --needed --noconfirm "$pacote") ;;
      zypper)  instalar=($sudo zypper install -y "$pacote") ;;
      apk)     instalar=($sudo apk add "$pacote") ;;
      *)       aviso "não reconheci o gerenciador de pacotes; instale: ${falta[*]}"; break ;;
    esac
    # O delta não existe em todo repositório (Debian 12, por exemplo). Sem ele
    # só o git review deixa de funcionar, então a instalação segue.
    run "${instalar[@]}" || aviso "não consegui instalar $pacote pelo $GERENCIADOR; veja https://github.com/dandavison/delta"
  done
fi
if [ "$SO" = macOS ]; then PASTA_FONTES="$HOME/Library/Fonts"; else PASTA_FONTES="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"; fi
tem_fonte() {
  ls "$PASTA_FONTES" /Library/Fonts 2>/dev/null | grep -qi jetbrainsmono && return 0
  command -v fc-list >/dev/null && fc-list 2>/dev/null | grep -qi 'JetBrains Mono' && return 0
  return 1
}
fonte=""
if tem_fonte; then
  fonte="JetBrains Mono"
elif [ "$DEPS" = 0 ]; then
  say "fonte JetBrains Mono não instalada (--no-deps)"
elif [ "$DRY" = 1 ]; then
  say "[dry-run] baixaria a fonte JetBrains Mono para $PASTA_FONTES"
elif ! command -v curl >/dev/null || ! command -v unzip >/dev/null; then
  aviso "sem curl ou unzip; a fonte JetBrains Mono fica para depois"
else
  zip="$(mktemp)"
  if curl -fsSL -o "$zip" https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip >> "$LOG" 2>&1 \
     && mkdir -p "$PASTA_FONTES" && unzip -qo -j "$zip" 'fonts/ttf/*.ttf' -d "$PASTA_FONTES" >> "$LOG" 2>&1; then
    command -v fc-cache >/dev/null && fc-cache -f "$PASTA_FONTES" >> "$LOG" 2>&1
    anota fonte "$PASTA_FONTES"
    fonte="JetBrains Mono instalada"
  else
    aviso "não consegui baixar a fonte JetBrains Mono; o resto segue normal"
  fi
  rm -f "$zip"
fi

versoes=""
command -v tmux >/dev/null && versoes="tmux $(tmux -V | awk '{print $2}')"
command -v delta >/dev/null && versoes="${versoes:+$versoes · }delta $(delta --version | awk '{print $2}')"
resumo "${versoes}${fonte:+ · $fonte}"
concluir

# ---- 2. scripts ------------------------------------------------------------
etapa 2 "scripts"
run mkdir -p "$BIN_DIR"
instalados=0
for script in "$ROOT"/bin/*; do
  nome="$(basename "$script")"
  alvo="$BIN_DIR/$nome"
  if [ -f "$alvo" ] && ! iguais "$script" "$alvo" && ! grep -qxF "script|$alvo|" "$MANIFESTO" 2>/dev/null; then
    aviso "$nome — já existe um $nome que não é do workdeck; não substituí"
    continue
  fi
  say "$nome"
  run install -m 755 "$script" "$alvo"
  anota script "$alvo"
  instalados=$((instalados + 1))
done
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) say "atenção: $BIN_DIR não está no PATH — o bloco do shell resolve isso" ;;
esac
if [ "$ROOT" = "$CODIGO" ]; then
  anota codigo "$CODIGO"
elif git -C "$ROOT" rev-parse >/dev/null 2>&1; then
  origem="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  run rm -rf "$CODIGO"
  run mkdir -p "$(dirname "$CODIGO")"
  run git clone -q "$ROOT" "$CODIGO"
  [ -n "$origem" ] && run git -C "$CODIGO" remote set-url origin "$origem"
  run git -C "$CODIGO" checkout -q "$(git -C "$ROOT" rev-parse HEAD)"
  anota codigo "$CODIGO"
  say "cópia do código em $(curto "$CODIGO"), para o work update"
else
  aviso "$ROOT não é um clone do git; o work update não vai funcionar"
fi
resumo "$instalados comandos em $(curto "$BIN_DIR")"
concluir

# ---- 3. config do usuário --------------------------------------------------
etapa 3 "config"
run mkdir -p "$CONFIG_DIR/panels"
if [ -f "$CONFIG_DIR/projects.conf" ]; then
  say "projects.conf já existe — não toquei nele"
else
  say "projetos: adicione com work add <caminho>"
fi
versao_distribuida() {
  local alvo="$1" caminho="$2" atual c
  atual="$(cksum < "$alvo")"
  git -C "$ROOT" rev-parse >/dev/null 2>&1 || return 1
  for c in $(git -C "$ROOT" log --format=%h -- "$caminho" 2>/dev/null); do
    [ "$(git -C "$ROOT" show "$c:$caminho" 2>/dev/null | cksum)" = "$atual" ] && return 0
  done
  return 1
}
for velho in 10-maquina 00-comece-aqui 20-git; do
  f="$CONFIG_DIR/panels/$velho"
  if [ -f "$f" ] && versao_distribuida "$f" "config/panels/$velho"; then
    run rm -f "$f"
    say "painel antigo $velho removido"
  fi
done
for painel in "$ROOT"/config/panels/*; do
  nome="$(basename "$painel")"
  alvo="$CONFIG_DIR/panels/$nome"
  if [ ! -f "$alvo" ]; then
    run install -m 755 "$painel" "$alvo"
    say "painel $nome"
  elif iguais "$painel" "$alvo"; then
    say "painel $nome"
  elif versao_distribuida "$alvo" "config/panels/$nome"; then
    run install -m 755 "$painel" "$alvo"
    say "painel $nome atualizado"
  else
    say "painel $nome foi editado por você — não toquei nele"
  fi
done
run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
run cp "$ROOT/config/git-review-lesskey" "${XDG_CONFIG_HOME:-$HOME/.config}/git-review/lesskey"
say "lesskey do git-review"
resumo "$(curto "$CONFIG_DIR")"
concluir

# ---- 4. tmux e terminal ----------------------------------------------------
etapa 4 "tmux"
write_block "$HOME/.tmux.conf" \
  "$(sed '$d' "$ROOT/config/tmux.conf" | sed '/^# O tema entra aqui/d'; cat "$ROOT/themes/$THEME.tmux"; echo '# <<< workdeck <<<')"
say "tmux.conf — Ctrl+b, mouse e atalhos em Alt"
resumo "Ctrl+b, mouse e atalhos em Alt"

case "$TERMINAL" in
  "")
    visual_dos_terminais
    if [ "$SO" = macOS ]; then
      term="$(terminal_atual)"
      if [ "$term" = Apple_Terminal ] && option_ligado_no_terminal_app; then
        say "Terminal.app: Option já funciona como Alt"
      else
        AVISO_OPTION="$(como_ligar_option "$term")"
        if [ -n "$AVISO_OPTION" ]; then
          say "dica: para os atalhos de uma tecla (Alt+2), veja o fim"
        fi
      fi
    else
      say "os atalhos em Alt já funcionam neste terminal"
    fi
    ;;
  kitty)
    aplicar_kitty
    resumo "Ctrl+b, mouse e Alt · kitty com tema e cmd (reabra o kitty)"
    ;;
  wezterm|alacritty|ghostty)
    say "o adaptador do $TERMINAL é um trecho para colar, não instalo automático:"
    say "  $ROOT/terminals/$TERMINAL.*"
    say "o instalador não edita Lua nem TOML de terceiros — veja terminals/README.md"
    resumo "Ctrl+b, mouse e Alt · cole terminals/$TERMINAL.* para tema e cmd"
    ;;
  *)
    aviso "não tenho adaptador para '$TERMINAL'. Disponíveis: kitty, ghostty, wezterm, alacritty"
    ;;
esac
concluir

# ---- 5. shell --------------------------------------------------------------
etapa 5 "shell"
rc=""
case "$(basename "${SHELL:-/bin/bash}")" in
  zsh)  rc="$HOME/.zshrc" ;;
  bash) [ "$SO" = "macOS" ] && rc="$HOME/.bash_profile" || rc="$HOME/.bashrc" ;;
  *)    rc="" ;;
esac
if [ -n "$rc" ]; then
  write_block "$rc" "$(cat "$ROOT/config/shell-snippet.sh")"
  say "$(basename "$rc")"
  resumo "$(curto "$rc")"
else
  aviso "shell '$SHELL' não reconhecido — adicione à mão: source $ROOT/config/shell-snippet.sh"
fi
concluir

# ---- 6. agente de IA -------------------------------------------------------
etapa 6 "agente de IA"
agente_atual=""
[ -f "$CONFIG_DIR/agent.conf" ] && agente_atual="$(. "$CONFIG_DIR/agent.conf"; echo "${AGENT_CMD:-}")"

if [ -n "$AGENT" ]; then
  run "$BIN_DIR/workdeck-agent" --set "$AGENT" && say "agente: $AGENT"
  resumo "$AGENT"
elif [ -n "$agente_atual" ]; then
  say "agente já configurado: $agente_atual"
  resumo "$agente_atual"
else
  achados=()
  for c in claude codex copilot aider gemini opencode cursor-agent crush goose q; do
    command -v "$c" >/dev/null && achados+=("$c")
  done
  if [ ${#achados[@]} -eq 0 ]; then
    say "nenhum agente de IA encontrado no PATH"
    say "quando tiver um: work agent <comando>"
    resumo "nenhum no PATH; depois: work agent <comando>"
  elif [ "$YES" = 1 ] || [ ! -t 0 ]; then
    say "achei no PATH: ${achados[*]}"
    say "para escolher: work agent <comando>"
    resumo "achei ${achados[*]}; escolha com work agent <comando>"
  else
    parar
    echo
    echo "  Achei estes agentes de IA no seu PATH:"
    i=1; for a in "${achados[@]}"; do echo "    $i) $a"; i=$((i+1)); done
    echo "    0) nenhum por enquanto"
    echo
    printf '  Qual você usa? [0-%s] ' "${#achados[@]}"
    read -r escolha || escolha=0
    if [ "${escolha:-0}" -ge 1 ] 2>/dev/null && [ "$escolha" -le "${#achados[@]}" ]; then
      run "$BIN_DIR/workdeck-agent" --set "${achados[$((escolha-1))]}" >/dev/null \
        && say "agente: ${achados[$((escolha-1))]}"
      resumo "${achados[$((escolha-1))]}"
    else
      say "nenhum agente definido; depois use work agent <comando>"
      resumo "nenhum; depois: work agent <comando>"
    fi
    echo
  fi
fi
concluir

# ---- 7. integrações opcionais ----------------------------------------------
etapa 7 "integrações"
if [ -z "$WITH" ]; then
  say "nenhuma pedida (--with <nome>); veja --list-integrations"
  resumo "nenhuma (--with <nome>)"
else
  parar
  resumo "$WITH"
  IFS=',' read -r -a pedidas <<< "$WITH"
  for nome in "${pedidas[@]}"; do
    arquivo="$ROOT/integrations/$nome.sh"
    if [ ! -f "$arquivo" ]; then
      aviso "não conheço a integração '$nome'"
      continue
    fi
    (
      . "$arquivo"
      titulo="$(descrever | head -1)"
      if verificar 2>/dev/null; then
        say "$titulo já está instalada"
        exit 0
      fi
      echo
      descrever | sed 's/^/    /'
      echo
      if [ "$YES" = 0 ] && [ -t 0 ]; then
        printf '  Instalar %s? [s/N] ' "$titulo"
        read -r r || r=n
        case "$r" in s|S|y|Y) ;; *) say "pulada"; exit 0 ;; esac
      fi
      [ "$DRY" = 1 ] && { say "[dry-run] instalaria $titulo"; exit 0; }
      instalar | sed 's/^/    /'
    )
  done
fi
concluir

if [ "$RELOAD" = 1 ] && command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
  run tmux source-file "$HOME/.tmux.conf" && say "tmux recarregado"
fi

[ -n "${WORKDECK_ATUALIZANDO:-}" ] && exit 0

if [ "$BONITO" = 1 ]; then
  printf '\n  %s✓ pronto em %ss%s\n' "$verde" "$SECONDS" "$reset"
else
  echo "Pronto."
fi

if [ -n "${WORKDECK_SHELL_NOVO:-}" ]; then
  passo_shell=""
else
  passo_shell="       source ${rc:-seu arquivo de shell}     ${dim}ou abra um terminal novo${reset}
"
fi
cat <<FIM

  Agora:
${passo_shell}       work                ${dim}abre o painel, que mostra como adicionar os projetos${reset}

  Para navegar: Shift+← / Shift+→ troca de janela, Shift+↑ / Shift+↓ troca de
  painel, e Ctrl+b e depois 1…9 vai direto para uma janela. Clicar na barra
  também funciona.
  Ajuda a qualquer hora: work help, ou Ctrl+b e h dentro do work.
FIM

if [ "$SO" = macOS ] && [ "$(terminal_atual)" = Apple_Terminal ] && [ "$(cat "$VISUAL_ESCOLHA" 2>/dev/null)" = nao ]; then
  cat <<FIM

  ${dim}Dica: para os terminais ficarem com a fonte e as cores do workdeck, rode
  work install e responda sim.${reset}
FIM
fi

if [ -n "$AVISO_OPTION" ]; then
  cat <<FIM

  ${dim}Dica, opcional: para atalhos de uma tecla só (Alt+2 em vez de Ctrl+b 2),
  a tecla Option do Mac precisa funcionar como Alt:${reset}
       $AVISO_OPTION
FIM
fi
