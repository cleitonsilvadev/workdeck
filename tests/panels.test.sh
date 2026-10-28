render_panel() {
  "$CODE/bin/work-panel" --once | sed 's/\x1b\[[0-9;]*m//g'
}

test_panel_shows_blocks_with_titles() {
  install_workdeck >/dev/null || fail "install exited with an error"
  printf '#!/usr/bin/env bash\necho tudo certo\n' > "$CONFIG/panels/30-commits-de-hoje"
  chmod +x "$CONFIG/panels/30-commits-de-hoje"
  output="$(render_panel)"
  assert_contains "$output" "Commits de hoje"
  assert_contains "$output" "  tudo certo"
  assert_contains "$output" "Projetos"
}

test_disabled_panel_is_hidden_and_update_respects_it() {
  install_workdeck >/dev/null || fail "install exited with an error"
  chmod -x "$CONFIG/panels/20-projetos"
  assert_not_contains "$(render_panel)" "Projetos" "the disabled panel"
  output="$(install_workdeck 2>&1)" || fail "reinstall exited with an error"
  assert_contains "$output" "painel 20-projetos desligado por você"
  assert "the panel stays disabled" test ! -x "$CONFIG/panels/20-projetos"
}

test_edited_panel_is_not_overwritten() {
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'echo minha versão' >> "$CONFIG/panels/20-projetos"
  output="$(install_workdeck 2>&1)" || fail "reinstall exited with an error"
  assert_contains "$output" "painel 20-projetos foi editado por você"
  assert "the edit is kept" grep -q 'minha versão' "$CONFIG/panels/20-projetos"
}

test_custom_panel_hint() {
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_contains "$(render_panel)" "Para pôr o seu no painel"
  printf '#!/usr/bin/env bash\necho oi\n' > "$CONFIG/panels/30-meu"
  chmod +x "$CONFIG/panels/30-meu"
  assert_not_contains "$(render_panel)" "Para pôr o seu no painel"
}
