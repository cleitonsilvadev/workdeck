test_update_follows_a_republished_tag() {
  git -C "$REPO" tag v1.0.0
  install_workdeck >/dev/null || fail "the install exited with an error"
  git -C "$CODE" fetch -q --tags origin
  git -C "$REPO" -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m next
  git -C "$REPO" tag -f v1.0.0 >/dev/null
  output="$("$HOME/.local/bin/work" update 2>&1 </dev/null)"
  assert_not_contains "$output" "não consegui falar com o repositório"
  assert_equal "$(git -C "$CODE" rev-parse 'v1.0.0^{commit}')" "$(git -C "$REPO" rev-parse HEAD)" "v1.0.0 in the installed copy"
}
