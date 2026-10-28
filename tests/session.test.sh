tmux_session() { tmux "$@"; }

test_first_work_opens_panel_with_terminal() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  wait_for sh -c "tmux list-panes -t work:painel -F '#{@role}' | grep -qx TERMINAL" || fail "the terminal below the panel did not appear"
  sleep 1
  roles="$(tmux list-panes -t work:painel -F '#{@role}:#{pane_dead}' | tr '\n' ' ')"
  assert_equal "$roles" "PANEL:0 TERMINAL:0 " "panes in the panel window"
}

test_work_add_creates_the_project_window() {
  install_workdeck >/dev/null || fail "install exited with an error"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  assert "the project is in projects.conf" grep -q "^api|" "$CONFIG/projects.conf"
  open_work_in_terminal work
  wait_for sh -c "tmux list-windows -t work -F '#W' | grep -qx api" || fail "the project window did not open"
  assert_equal "$(tmux list-windows -t work -F '#W' | tr '\n' ' ')" "painel api " "windows"
}

test_menu_says_how_to_close() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_work_in_terminal work
  wait_for sh -c "tmux list-clients -t work | grep -q ." || fail "no terminal attached to the session"
  client="$(tmux list-clients -t work -F '#{client_name}' | head -1)"
  WD_MENU_LOG="$BASE/menu" work _menu "$client" "$(tmux display -p -t work:painel '#{pane_id}')"
  assert_contains "$(cat "$BASE/menu")" "-q ou Esc fecha o menu"
  assert_contains "$(cat "$BASE/menu")" "painel"
}

test_work_without_code_explains_what_to_do() {
  install_workdeck >/dev/null || fail "install exited with an error"
  rm -rf "$CODE"
  if output="$(work 2>&1)"; then fail "work should fail without the code"; fi
  assert_contains "$output" "o código do workdeck não está em"
  assert_contains "$output" "get.sh"
}
