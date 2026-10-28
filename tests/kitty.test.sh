teste_kitty_de_outra_conta_nao_conta() {
  . "$REPO/install.sh"
  HOME=/Users/eu
  afirmar "kitty de outra conta no Mac" kitty_de_outra_conta /Users/outra/Applications/kitty.app/Contents/MacOS/kitty
  afirmar "kitty de outra conta no Linux" kitty_de_outra_conta /home/outra/.local/kitty.app/bin/kitty
  if kitty_de_outra_conta /Users/eu/Applications/kitty.app/Contents/MacOS/kitty; then falhar "o kitty da própria conta"; fi
  if kitty_de_outra_conta /opt/homebrew/bin/kitty; then falhar "o kitty do sistema"; fi
}
