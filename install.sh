#!/usr/bin/env bash
# workdeck — instalador. macOS e Linux.
#
#   ./install.sh                      instala com o tema padrão
#   ./install.sh --theme nord         escolhe um tema de themes/
#   ./install.sh --agent claude       define o seu agente de IA
#   ./install.sh --zsh                instala o oh-my-zsh e o zinit sem perguntar
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
QUER_ZSH=0
REINICIAR_SHELL=0
AGENT=""
WITH=""
YES=0
DEPS=1
RELOAD=1
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --theme) THEME="${2:?--theme precisa de um nome}"; shift 2 ;;
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
    --zsh) QUER_ZSH=1; shift ;;
    --no-reload) RELOAD=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

pode_perguntar_novidade() {
  [ -t 0 ] || return 1
  [ "$YES" = 0 ] || [ -n "${WORKDECK_ATUALIZANDO:-}" ]
}

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

no_kitty() { [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = xterm-kitty ]; }

kitty_instalado() {
  [ -d /Applications/kitty.app ] || [ -d "$HOME/Applications/kitty.app" ] \
    || command -v kitty >/dev/null || [ -x "$HOME/.local/kitty.app/bin/kitty" ]
}

instalar_kitty() {
  local app destino
  if kitty_instalado; then say "kitty já instalado"; return 0; fi
  if [ "$DEPS" = 0 ]; then aviso "kitty não instalado (--no-deps): https://sw.kovidgoyal.net/kitty/binary/"; return 1; fi
  [ "$DRY" = 1 ] && { say "[dry-run] instalaria o kitty pelo instalador oficial"; return 0; }
  if ! command -v curl >/dev/null; then aviso "sem curl; instale o kitty: https://sw.kovidgoyal.net/kitty/binary/"; return 1; fi
  if [ "$SO" = macOS ]; then destino="$HOME/Applications"; else destino="$HOME/.local"; fi
  mkdir -p "$destino"
  if ! curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest="$destino" launch=n >> "$LOG" 2>&1; then
    aviso "não consegui instalar o kitty; instale por https://sw.kovidgoyal.net/kitty/binary/ e rode a instalação de novo"
    return 1
  fi
  app="$destino/kitty.app"
  if [ "$SO" != macOS ]; then
    mkdir -p "$BIN_DIR" "$HOME/.local/share/applications"
    ln -sf "$app/bin/kitty" "$app/bin/kitten" "$BIN_DIR/"
    cp "$app/share/applications/kitty.desktop" "$app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"
    sed -i "s|Icon=kitty|Icon=$app/share/icons/hicolor/256x256/apps/kitty.png|g; s|Exec=kitty|Exec=$app/bin/kitty|g" \
      "$HOME/.local/share/applications"/kitty*.desktop
  fi
  anota kitty "$app"
  say "kitty instalado em $(curto "$app")"
}

aplicar_kitty() {
  local bloco
  bloco="$(sed '$d' "$ROOT/terminals/kitty.conf" | sed '/^# O tema entra aqui/d')"
  [ "$SO" = macOS ] || bloco="$(printf '%s\n' "$bloco" | grep -v '^map cmd\|^macos_')"
  write_block "$HOME/.config/kitty/kitty.conf" "$(printf '%s\n' "$bloco"; cat "$ROOT/themes/$THEME.conf"; echo '# <<< workdeck <<<')"
  say "kitty.conf — tema, fonte e atalhos"
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
if [ -f "$MANIFESTO" ] && [ "$DRY" = 0 ]; then
  while IFS='|' read -r tipo alvo _; do
    [ "$tipo" = script ] || continue
    [ -e "$ROOT/bin/$(basename "$alvo")" ] && continue
    rm -f "$alvo"
    grep -vxF "script|$alvo|" "$MANIFESTO" > "$MANIFESTO.tmp" && mv "$MANIFESTO.tmp" "$MANIFESTO"
    say "$(basename "$alvo") removido: não faz mais parte do workdeck"
  done < <(grep '^script|' "$MANIFESTO" || true)
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

# ---- 4. tmux e kitty -------------------------------------------------------
etapa 4 "tmux e kitty"
write_block "$HOME/.tmux.conf" \
  "$(sed '$d' "$ROOT/config/tmux.conf" | sed '/^# O tema entra aqui/d'; cat "$ROOT/themes/$THEME.tmux"; echo '# <<< workdeck <<<')"
say "tmux.conf — Ctrl+b, mouse e atalhos em Alt"
resumo "Ctrl+b, mouse e atalhos em Alt"

if instalar_kitty; then
  aplicar_kitty
  resumo "Ctrl+b, mouse e atalhos em Alt · kitty com tema e fonte"
else
  resumo "Ctrl+b, mouse e atalhos em Alt · sem o kitty"
fi
concluir

# ---- 5. shell --------------------------------------------------------------
etapa 5 "shell"
ZSH_ESCOLHA="$CONFIG_DIR/zsh"
ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck-zsh"

ja_tem_zsh_turbinado() {
  [ -d "$HOME/.oh-my-zsh" ] || [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zinit" ] || [ -d "$HOME/.zinit" ] && return 0
  [ -f "$HOME/.zshrc" ] && awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$HOME/.zshrc" \
    | grep -qE 'zsh-autosuggestions|fast-syntax-highlighting|zsh-syntax-highlighting|zinit|oh-my-zsh|starship|powerlevel10k|p10k|spaceship|pure' && return 0
  return 1
}

ZINIT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

instalar_omz_zinit() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone -q --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" >> "$LOG" 2>&1 || return 1
    anota omz "$HOME/.oh-my-zsh"
  fi
  if [ ! -f "$ZINIT_DIR/zinit.zsh" ]; then
    mkdir -p "$(dirname "$ZINIT_DIR")"
    git clone -q --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_DIR" >> "$LOG" 2>&1 || return 1
    anota zinit "$(dirname "$ZINIT_DIR")"
  fi
  [ -d "$ZSH_PLUGINS" ] && rm -rf "$ZSH_PLUGINS"
  return 0
}

opcao_zsh() {
  local escolha r zsh_bin
  escolha="$(cat "$ZSH_ESCOLHA" 2>/dev/null || true)"
  printf '%s' "$escolha" > "$ZSH_ESCOLHA.anterior" 2>/dev/null || true
  [ "$escolha" = nao ] && [ "$QUER_ZSH" = 0 ] && return 0
  if [ "$escolha" != sim ]; then
    if ja_tem_zsh_turbinado; then
      say "zsh: você já tem plugins (oh-my-zsh, zinit ou outros); não mexi"
      return 0
    fi
    if [ "$QUER_ZSH" = 0 ] && pode_perguntar_novidade; then
      parar
      printf '  Quer o zsh do workdeck? Sugestões enquanto digita, cores nos comandos
'
      printf '  e mais completar com Tab. [s/N] '
      read -r r || r=n
      girar
      case "$r" in s|S|y|Y) ;; *) [ "$DRY" = 1 ] || { mkdir -p "$CONFIG_DIR"; echo nao > "$ZSH_ESCOLHA"; }; return 0 ;; esac
    fi
  fi
  [ "$DRY" = 1 ] && { say "[dry-run] instalaria o zsh do workdeck"; return 0; }
  if ! command -v zsh >/dev/null; then
    if [ "$SO" != macOS ] && [ "$DEPS" = 1 ] && [ -n "${GERENCIADOR:-}" ]; then
      parar
      case "$GERENCIADOR" in
        apt-get) $sudo apt-get install -y zsh ;;
        dnf) $sudo dnf install -y zsh ;;
        pacman) $sudo pacman -S --needed --noconfirm zsh ;;
        zypper) $sudo zypper install -y zsh ;;
        apk) $sudo apk add zsh ;;
      esac >> "$LOG" 2>&1 || true
      girar
    fi
    command -v zsh >/dev/null || { aviso "não consegui instalar o zsh; instale pelo gerenciador e rode a instalação de novo com --zsh"; return 0; }
  fi
  zsh_bin="$(command -v zsh)"
  if [ "$(basename "${SHELL:-}")" != zsh ]; then
    parar
    printf '  Usar o zsh como o seu shell padrão? Pede a sua senha. [S/n] '
    read -r r </dev/tty 2>/dev/null || r=n
    girar
    case "${r:-s}" in
      s|S|y|Y)
        parar
        grep -qx "$zsh_bin" /etc/shells 2>/dev/null || echo "$zsh_bin" | $sudo tee -a /etc/shells >/dev/null
        if chsh -s "$zsh_bin" </dev/tty; then SHELL="$zsh_bin"; REINICIAR_SHELL=1; else aviso "não troquei o shell padrão; dá para fazer depois com: chsh -s $zsh_bin"; fi
        girar ;;
    esac
  fi
  if instalar_omz_zinit; then
    mkdir -p "$CONFIG_DIR"; echo sim > "$ZSH_ESCOLHA"
    ZSH_RESUMO="oh-my-zsh (robbyrussell) e zinit"
    [ "$(cat "$ZSH_ESCOLHA.anterior" 2>/dev/null)" = sim ] || REINICIAR_SHELL=1
  else
    aviso "não consegui baixar o oh-my-zsh ou o zinit; rode a instalação de novo com --zsh mais tarde"
  fi
}
ZSH_RESUMO=""
sudo=""; [ "$(id -u)" != 0 ] && sudo="sudo"
opcao_zsh

rc=""
case "$(basename "${SHELL:-/bin/bash}")" in
  zsh)  rc="$HOME/.zshrc" ;;
  bash) [ "$SO" = "macOS" ] && rc="$HOME/.bash_profile" || rc="$HOME/.bashrc" ;;
  *)    rc="" ;;
esac
if [ -n "$rc" ]; then
  write_block "$rc" "$(cat "$ROOT/config/shell-snippet.sh")"
  if [ "$(cat "$ZSH_ESCOLHA" 2>/dev/null)" = sim ] && [ "$DRY" = 0 ] && command -v zsh >/dev/null; then
    zsh -i -c exit </dev/null >> "$LOG" 2>&1 || true
  fi
  say "$(basename "$rc")"
  resumo "$(curto "$rc")${ZSH_RESUMO:+ · $ZSH_RESUMO}"
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
    say "o work review usa a IA que estiver aberta na janela"
    resumo "nenhum no PATH; o review usa a IA aberta na janela"
  elif [ "$YES" = 1 ] || [ ! -t 0 ]; then
    say "achei no PATH: ${achados[*]}"
    say "o work review usa a IA que estiver aberta na janela"
    resumo "achei ${achados[*]}; o review usa a IA aberta na janela"
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
      say "nenhum padrão; o work review usa a IA aberta na janela"
      resumo "nenhum padrão; o review usa a IA aberta na janela"
    fi
    echo
  fi
fi
concluir

# ---- 7. integrações opcionais ----------------------------------------------
etapa 7 "integrações"
INTEGRACOES_ESCOLHA="$CONFIG_DIR/integracoes"
ESCOLHIDAS=0
if [ -z "$WITH" ] && [ ! -f "$INTEGRACOES_ESCOLHA" ] && pode_perguntar_novidade; then
  disponiveis=()
  for f in "$ROOT"/integrations/*.sh; do
    [ "$(basename "$f")" = exemplo.sh ] || disponiveis+=("$(basename "$f" .sh)")
  done
  if [ ${#disponiveis[@]} -gt 0 ]; then
    parar
    echo
    echo "  Você usa algum destes com a IA? O workdeck mostra como ligar cada um."
    i=1
    for n in "${disponiveis[@]}"; do
      printf '    %s) %-10s %s%s%s\n' "$i" "$n" "$dim" "$(. "$ROOT/integrations/$n.sh"; descrever | sed -n 2p)" "$reset"
      i=$((i+1))
    done
    echo
    printf '  Quais? Números separados por espaço, Enter para nenhum: '
    read -r escolha || escolha=""
    for e in ${escolha//,/ }; do
      if [ "$e" -ge 1 ] 2>/dev/null && [ "$e" -le "${#disponiveis[@]}" ]; then
        case ",$WITH," in *",${disponiveis[$((e-1))]},"*) ;; *) WITH="${WITH:+$WITH,}${disponiveis[$((e-1))]}" ;; esac
      fi
    done
    [ "$DRY" = 1 ] || { mkdir -p "$CONFIG_DIR"; echo "${WITH:-nenhuma}" > "$INTEGRACOES_ESCOLHA"; }
    ESCOLHIDAS=1
    girar
  fi
fi
if [ -z "$WITH" ]; then
  if [ -f "$INTEGRACOES_ESCOLHA" ] && [ "$(cat "$INTEGRACOES_ESCOLHA")" != nenhuma ]; then
    say "escolhidas antes: $(cat "$INTEGRACOES_ESCOLHA"); para ver de novo: rode a instalação de novo com --with <nome>"
    resumo "$(cat "$INTEGRACOES_ESCOLHA")"
  else
    say "nenhuma; para ligar depois: rode a instalação de novo com --with <nome>"
    resumo "nenhuma (--with <nome>)"
  fi
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
      if [ "$YES" = 0 ] && [ "$ESCOLHIDAS" = 0 ] && [ -t 0 ]; then
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

rm -f "$ZSH_ESCOLHA.anterior"
if [ -n "${WORKDECK_ATUALIZANDO:-}" ]; then
  if [ "$REINICIAR_SHELL" = 1 ]; then
    printf '\n  %s●%s Feche e abra o kitty para carregar o zsh e o visual novos.\n' "$amarelo" "$reset"
  fi
  exit 0
fi

if [ "$BONITO" = 1 ]; then
  printf '\n  %s✓ pronto em %ss%s\n' "$verde" "$SECONDS" "$reset"
else
  echo "Pronto."
fi

if no_kitty; then
  abrir="${bold}feche e abra o kitty${reset}     ${dim}carrega o zsh, o visual e os comandos do workdeck${reset}"
else
  abrir="${bold}abra o kitty${reset}              ${dim}o workdeck foi feito para ele: tema, fonte e atalhos cmd${reset}"
fi

cat <<FIM

  Agora:
       $abrir
       work                      ${dim}abre o painel, que mostra como adicionar os projetos${reset}

  Para navegar: Shift+← / Shift+→ troca de janela, Shift+↑ / Shift+↓ troca de
  painel, e Ctrl+b e depois 1…9 vai direto para uma janela. Clicar na barra
  também funciona.
  Ajuda a qualquer hora: Ctrl+b e h dentro do work.
FIM
