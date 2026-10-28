#!/usr/bin/env bash
# workdeck — desinstalador.
#
#   ./uninstall.sh            remove os blocos e os scripts; mantém sua config
#   ./uninstall.sh --restore  além disso, devolve os arquivos ao estado de antes
#                             da instalação, usando as cópias guardadas
#   ./uninstall.sh --all      remove tudo, inclusive ~/.config/workdeck, a fonte
#                             e o kitty que a instalação trouxe (é o work uninstall)
#   ./uninstall.sh --dry-run  mostra o que faria
#
# Em qualquer modo ele só mexe no que instalou: arquivo alterado por você
# depois da instalação é deixado em paz, e avisado.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/comum.sh"
CONFIG_DIR="$WORKDECK_CONFIG"
MANIFESTO="$CONFIG_DIR/.install-manifest"
RESTORE=0
ALL=0
DRY=0
APAGAR_CODIGO=""

for arg in "$@"; do
  case "$arg" in
    --restore) RESTORE=1 ;;
    --all) ALL=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $arg"; exit 1 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
run() { [ "$DRY" = 1 ] && { say "[dry-run] $*"; return 0; }; "$@"; }

tirar_bloco() {
  local file="$1" tmp
  [ -f "$file" ] || return 0
  tem_bloco "$file" || return 0
  if [ "$DRY" = 1 ]; then say "[dry-run] tiraria o bloco de ${file#"$HOME"/}"; return 0; fi
  tmp="$(mktemp)"
  sem_bloco "$file" > "$tmp"
  mv "$tmp" "$file"
  say "bloco removido de ${file#"$HOME"/}"
}

echo "workdeck → desinstalando"
echo

if [ -f "$MANIFESTO" ]; then
  # ---- caminho preciso: desfaz exatamente o que foi instalado --------------
  while IFS="|" read -r tipo alvo backup; do
    [ -z "${tipo:-}" ] && continue
    case "$tipo" in
      bloco)
        if [ "$RESTORE" = 1 ] && [ -n "${backup:-}" ] && [ -f "$backup" ]; then
          run cp "$backup" "$alvo"
          say "${alvo#"$HOME"/} restaurado como estava antes"
        else
          tirar_bloco "$alvo"
          # Criado pelo instalador e sem nada além do bloco: não sobra arquivo vazio.
          if [ "${backup:-}" = ":criado" ] && [ -f "$alvo" ] && ! grep -q '[^[:space:]]' "$alvo"; then
            run rm -f "$alvo"
            say "${alvo#"$HOME"/} apagado: foi criado pela instalação"
          fi
        fi
        ;;
      terminal-app)
        IFS=, read -r perfil fnome ftam b1 b2 b3 t1 t2 t3 <<< "$alvo"
        if [ "$DRY" = 1 ]; then
          say "[dry-run] devolveria a fonte e as cores do perfil $perfil do Terminal.app"
        elif command -v osascript >/dev/null && osascript >/dev/null 2>&1 <<FIM
tell application "Terminal"
  set s to settings set "$perfil"
  set background color of s to {$b1, $b2, $b3}
  set normal text color of s to {$t1, $t2, $t3}
  set font name of s to "$fnome"
  set font size of s to $ftam
end tell
FIM
        then
          say "Terminal.app: perfil $perfil voltou à fonte e às cores de antes"
        fi
        rm -f "$CONFIG_DIR/terminal-app" "$CONFIG_DIR/visual"
        ;;
      gnome)
        base="/org/gnome/terminal/legacy/profiles:/"; id="5e1f9a2c-7d3b-4c6a-9b8e-0a1d2c3b4e5f"
        if [ "$DRY" = 1 ]; then
          say "[dry-run] tiraria o perfil workdeck do GNOME Terminal"
        elif command -v dconf >/dev/null; then
          if [ "$alvo" = vazio ]; then dconf reset "${base}default"; else dconf write "${base}default" "$alvo"; fi
          lista="$(dconf read "${base}list" 2>/dev/null || true)"
          lista="$(printf '%s' "$lista" | sed "s/, '$id'//; s/'$id', //; s/'$id'//")"
          [ -n "$lista" ] && dconf write "${base}list" "$lista"
          dconf reset -f "${base}:$id/"
          say "GNOME Terminal: perfil workdeck removido e o padrão de antes de volta"
        fi
        rm -f "$CONFIG_DIR/visual"
        ;;
      kitty)
        if [ "$ALL" = 1 ]; then
          run rm -rf "$alvo"
          say "removido ${alvo#"$HOME"/}"
        else
          say "o kitty continua em ${alvo#"$HOME"/}; para remover também: rm -rf $alvo"
        fi
        ;;
      zsh)
        run rm -rf "$alvo"
        rm -f "$CONFIG_DIR/zsh"
        ;;
      omz|zinit)
        run rm -rf "$alvo"
        rm -f "$CONFIG_DIR/zsh"
        say "removido ${alvo#"$HOME"/}"
        ;;
      fonte)
        if [ "$ALL" = 1 ]; then
          run rm -f "$alvo"/JetBrainsMono*.ttf
          say "fonte JetBrains Mono removida de ${alvo#"$HOME"/}"
        fi
        ;;
      codigo)
        if [ -d "$alvo" ] && [ "$alvo" != "$ROOT" ]; then
          run rm -rf "$alvo"
          say "removido ${alvo#"$HOME"/}"
        elif [ -d "$alvo" ]; then
          APAGAR_CODIGO="$alvo"
        fi
        run rm -rf "$WORKDECK_CACHE"
        ;;
      script)
        nome="$(basename "$alvo")"
        origem="$ROOT/bin/$nome"
        if [ ! -f "$alvo" ]; then
          :
        elif [ -f "$origem" ] && iguais "$origem" "$alvo"; then
          run rm -f "$alvo"
          say "removido ${alvo#"$HOME"/}"
        else
          say "deixei ${alvo#"$HOME"/}: foi alterado depois da instalação"
        fi
        ;;
    esac
  done < "$MANIFESTO"
else
  # ---- sem manifesto: tenta o básico --------------------------------------
  say "sem manifesto de instalação; removendo o que der"
  for f in "$HOME/.tmux.conf" "$HOME/.config/kitty/kitty.conf" \
           "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    tirar_bloco "$f"
  done
  for script in "$ROOT"/bin/*; do
    alvo="$WORKDECK_BIN/$(basename "$script")"
    if [ -f "$alvo" ] && iguais "$script" "$alvo"; then
      run rm -f "$alvo"; say "removido ${alvo#"$HOME"/}"
    elif [ -f "$alvo" ]; then
      say "deixei ${alvo#"$HOME"/}: foi alterado depois da instalação"
    fi
  done
  # Sem manifesto não dá para saber o resto, mas o código instalado é sempre este.
  if [ "$ALL" = 1 ] && [ "$ROOT" = "$WORKDECK_CODIGO" ]; then
    APAGAR_CODIGO="$ROOT"
    run rm -rf "$WORKDECK_CACHE"
  fi
fi

echo
if [ "$ALL" = 1 ]; then
  run rm -rf "$CONFIG_DIR"
  run rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
  say "removido $CONFIG_DIR, com projetos, painéis e cópias"
else
  say "sua config em ${CONFIG_DIR#"$HOME"/} continua lá (projetos, painéis e as cópias dos originais)"
  say "para apagar também:  ./uninstall.sh --all"
fi

echo
echo "Reabra o terminal, ou:  tmux source-file ~/.tmux.conf"

if [ -n "$APAGAR_CODIGO" ]; then
  run rm -rf "$APAGAR_CODIGO"
  say "removido ${APAGAR_CODIGO#"$HOME"/}"
fi
