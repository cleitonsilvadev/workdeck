test_installs_from_scratch() {
  install_workdeck || fail "install exited with an error"
  assert "work is on the PATH" test -x "$HOME/.local/bin/work"
  assert "the code copy exists" test -f "$CODE/lib/common.sh"
  assert "the 00-workdeck panel was installed" test -x "$CONFIG/panels/00-workdeck"
  assert "the 20-projetos panel was installed" test -x "$CONFIG/panels/20-projetos"
  assert "the manifest was written" test -f "$CONFIG/.install-manifest"
  assert_equal "$(count_blocks "$HOME/.tmux.conf")" 1 "blocks in tmux.conf"
  assert_equal "$(count_blocks "$(shell_rc_file)")" 1 "blocks in the shell file"
}

test_reinstall_does_not_duplicate() {
  install_workdeck >/dev/null || fail "first install"
  install_workdeck >/dev/null || fail "second install"
  assert_equal "$(count_blocks "$HOME/.tmux.conf")" 1 "blocks in tmux.conf"
  assert_equal "$(count_blocks "$(shell_rc_file)")" 1 "blocks in the shell file"
  assert_equal "$(grep -c '^block|' "$CONFIG/.install-manifest")" 2 "blocks in the manifest"
}

test_keeps_existing_content() {
  printf 'set -g history-limit 5000\n' > "$HOME/.tmux.conf"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert "the user's line is kept" grep -qx 'set -g history-limit 5000' "$HOME/.tmux.conf"
  assert "a copy of the original was saved" sh -c "ls '$CONFIG/.backups/' | grep -q tmux.conf"
}

test_does_not_replace_someone_elses_work() {
  mkdir -p "$HOME/.local/bin"
  printf '#!/bin/sh\necho mine\n' > "$HOME/.local/bin/work"
  output="$(install_workdeck 2>&1)" || fail "install exited with an error"
  assert_equal "$(cat "$HOME/.local/bin/work")" "$(printf '#!/bin/sh\necho mine')" "the user's work"
  assert_contains "$output" "já existe um work que não é do workdeck"
}

test_dry_run_writes_nothing() {
  install_workdeck --dry-run >/dev/null || fail "dry run exited with an error"
  assert "did not create tmux.conf" test ! -e "$HOME/.tmux.conf"
  assert "did not save the theme" test ! -e "$CONFIG/theme"
  assert "did not install work" test ! -e "$HOME/.local/bin/work"
}

test_migrates_legacy_config() {
  echo nord > "$CONFIG/tema"
  echo nenhuma > "$CONFIG/integracoes"
  echo nao > "$CONFIG/zsh"
  echo AVISO=0 > "$CONFIG/atualizacao.conf"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_equal "$(cat "$CONFIG/theme")" nord "theme"
  assert_equal "$(cat "$CONFIG/integrations")" none "integrations"
  assert_equal "$(cat "$CONFIG/zsh")" no "zsh"
  assert_equal "$(cat "$CONFIG/update.conf")" NOTIFY=0 "update.conf"
  for old in tema integracoes atualizacao.conf; do
    assert "$old was removed" test ! -e "$CONFIG/$old"
  done
}
