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

project_with_server_command() {
  mkdir -p "$HOME/api/.workdeck"
  echo 'SERVER_COMMAND="echo servidor-no-ar"' > "$HOME/api/.workdeck/project.conf"
}

test_project_layout_opens_three_panes_with_typed_commands() {
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'PROJECT_LAYOUT="agent-server-shell"' >> "$CONFIG/settings.conf"
  echo 'AGENT_CMD="echo agente-no-ar"' >> "$CONFIG/settings.conf"
  project_with_server_command
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  open_work_in_terminal work
  wait_for sh -c "[ \"\$(tmux list-panes -t work:api 2>/dev/null | wc -l | tr -d ' ')\" = 3 ]" || fail "the project window did not get three panes: $(tmux list-panes -t work:api 2>&1)"
  panes="$(tmux list-panes -t work:api -F '#{pane_left},#{pane_top} #{pane_id}' | sort -n)"
  agent="$(printf '%s\n' "$panes" | awk '$1 == "0,0" {print $2}')"
  server="$(printf '%s\n' "$panes" | awk -F'[ ,]' '$1 > 0 && $2 == 0 {print $3}')"
  shell_pane="$(printf '%s\n' "$panes" | awk -F'[ ,]' '$1 > 0 && $2 > 0 {print $3}')"
  assert "the agent pane is on the left" test -n "$agent"
  assert "the server pane is on the top right" test -n "$server"
  assert "the free shell is on the bottom right" test -n "$shell_pane"
  wait_for sh -c "tmux capture-pane -p -t '$agent' | grep -q 'echo agente-no-ar'" || fail "the agent command was not typed: $(tmux capture-pane -p -t "$agent")"
  wait_for sh -c "tmux capture-pane -p -t '$server' | grep -q 'echo servidor-no-ar'" || fail "the server command was not typed: $(tmux capture-pane -p -t "$server")"
  sleep 1.5
  assert_equal "$(tmux capture-pane -p -t "$agent" | grep -cx 'agente-no-ar' || true)" 0 "the agent command ran"
  assert_equal "$(tmux capture-pane -p -t "$server" | grep -cx 'servidor-no-ar' || true)" 0 "the server command ran"
}

open_layout_with_project_conf() {
  echo 'PROJECT_LAYOUT="agent-server-shell"' >> "$CONFIG/settings.conf"
  mkdir -p "$HOME/api/.workdeck"
  printf '%b' "$1" > "$HOME/api/.workdeck/project.conf"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  work add "$HOME/api" >/dev/null 2>&1
  wait_for sh -c "[ \"\$(tmux list-panes -t work:api 2>/dev/null | wc -l | tr -d ' ')\" = 3 ]" || fail "the project window did not get three panes"
  SERVER_PANE="$(tmux list-panes -t work:api -F '#{pane_left},#{pane_top} #{pane_id}' | awk -F'[ ,]' '$1 > 0 && $2 == 0 {print $3}')"
}

test_project_layout_never_runs_a_hidden_enter() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_layout_with_project_conf 'SERVER_COMMAND="echo um\recho dois"\r\n'
  wait_for sh -c "tmux capture-pane -p -t '$SERVER_PANE' | grep -q 'echo um'" || fail "the server command was not typed: $(tmux capture-pane -p -t "$SERVER_PANE")"
  sleep 1.5
  assert_equal "$(tmux capture-pane -p -t "$SERVER_PANE" | grep -cxE 'um|dois|umecho dois' || true)" 0 "lines printed by a command that ran"
}

test_project_layout_ignores_a_value_with_a_trailing_comment() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_layout_with_project_conf 'SERVER_COMMAND="npm run dev" # api\n'
  sleep 1.5
  assert_not_contains "$(tmux capture-pane -p -t "$SERVER_PANE")" "npm run dev" "the server pane"
}

test_project_layout_warns_about_an_unknown_value() {
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'PROJECT_LAYOUT="agent-server-terminal"' >> "$CONFIG/settings.conf"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  mkdir -p "$HOME/api"
  assert_contains "$(work add "$HOME/api" 2>&1)" "PROJECT_LAYOUT=\"agent-server-terminal\" não existe"
}

test_project_layout_is_off_by_default() {
  install_workdeck >/dev/null || fail "install exited with an error"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  open_work_in_terminal work
  wait_for sh -c "tmux list-windows -t work -F '#W' | grep -qx api" || fail "the project window did not open"
  sleep 0.5
  assert_equal "$(tmux list-panes -t work:api | wc -l | tr -d ' ')" 1 "panes in the project window"
}

test_project_layout_applies_to_work_add_in_an_open_session() {
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'PROJECT_LAYOUT="agent-server-shell"' >> "$CONFIG/settings.conf"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  wait_for sh -c "[ \"\$(tmux list-panes -t work:api 2>/dev/null | wc -l | tr -d ' ')\" = 3 ]" || fail "the new window did not get three panes"
}
