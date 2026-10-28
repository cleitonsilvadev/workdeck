test_kitty_from_another_account_does_not_count() {
  . "$REPO/install.sh"
  HOME=/Users/me
  assert "kitty from another account on macOS" kitty_from_other_account /Users/other/Applications/kitty.app/Contents/MacOS/kitty
  assert "kitty from another account on Linux" kitty_from_other_account /home/other/.local/kitty.app/bin/kitty
  if kitty_from_other_account /Users/me/Applications/kitty.app/Contents/MacOS/kitty; then fail "kitty from the same account"; fi
  if kitty_from_other_account /opt/homebrew/bin/kitty; then fail "system kitty"; fi
}
