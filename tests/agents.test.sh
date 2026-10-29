agent_session() {
  local agent="${1:-aider}" program="${2:-cat}"
  ln -s "$(command -v "$program")" "$BASE/bin/$agent"
  tmux new-session -d -s work -x 120 -y 30 -c "$HOME"
  AGENT_WIN="$(tmux new-window -d -P -F '#{window_id}' -t work: -n api "$BASE/bin/$agent")"
  AGENT_PANE="$(tmux display -p -t "$AGENT_WIN" '#{pane_id}')"
  wait_for sh -c "ps -o comm= -t \"\$(tmux display -p -t '$AGENT_PANE' '#{pane_tty}' | sed 's#/dev/##')\" | grep -q '$agent'" || fail "the fake $agent did not start"
}

claude_session() {
  agent_session claude bash
  wait_for sh -c "[ \"\$(tmux display -p -t '$AGENT_PANE' '#{cursor_x}')\" -gt 0 ]" || fail "the fake claude shell did not show a prompt"
}

claude_screen() {
  tmux send-keys -t "$AGENT_PANE" "clear; printf '%s\\n' '$1'" Enter
  sleep 0.4
}

check() {
  WORKDECK_AGENT_IDLE=1 work _check-agents
}

agent_writes() {
  tmux send-keys -t "$AGENT_PANE" -l "$1"
  sleep 0.3
}

agent_done_flag() {
  case "$(tmux show -wqv -t "$AGENT_WIN" @agent_stars)" in "") echo "" ;; *) echo 1 ;; esac
}

finish_a_task() {
  check
  agent_writes "trabalhando"
  check
  sleep 1.2
  check
}

fake_notifier() {
  printf '#!/bin/sh\nprintf "%%s\\n" "$@" >> "%s"\n' "$BASE/notified" > "$BASE/bin/osascript"
  chmod +x "$BASE/bin/osascript"
}

test_star_marks_an_agent_that_finished() {
  install_workdeck >/dev/null || fail "install exited with an error"
  agent_session
  finish_a_task
  assert_equal "$(agent_done_flag)" 1 "the finished agent's window"
  assert_contains "$(tmux show -gv window-status-format)" "@agent_stars" "the status bar format"
}

test_no_star_for_an_agent_that_never_worked() {
  install_workdeck >/dev/null || fail "install exited with an error"
  agent_session
  check
  sleep 1.2
  check
  assert_equal "$(agent_done_flag)" "" "a quiet agent's window"
}

test_star_clears_when_the_agent_works_again() {
  install_workdeck >/dev/null || fail "install exited with an error"
  agent_session
  finish_a_task
  agent_writes " de novo"
  check
  assert_equal "$(agent_done_flag)" "" "the window once the agent works again"
}

test_notification_only_when_enabled() {
  install_workdeck >/dev/null || fail "install exited with an error"
  fake_notifier
  agent_session
  finish_a_task
  assert "no notification by default" test ! -e "$BASE/notified"
  echo 'NOTIFY_AGENTS="yes"' >> "$CONFIG/settings.conf"
  agent_writes " outra tarefa"
  check
  sleep 1.2
  check
  assert_contains "$(cat "$BASE/notified" 2>/dev/null)" "o aider terminou em api" "the notification"
}

test_claude_is_done_when_esc_to_interrupt_goes_away() {
  install_workdeck >/dev/null || fail "install exited with an error"
  claude_session
  check
  claude_screen "✽ Working… (esc to interrupt)"
  check
  assert_equal "$(agent_done_flag)" "" "the window while claude works"
  claude_screen "pronto"
  sleep 1.2
  check
  assert_equal "$(agent_done_flag)" 1 "the window after claude finishes"
}

test_esc_to_interrupt_in_the_conversation_is_not_work() {
  install_workdeck >/dev/null || fail "install exited with an error"
  claude_session
  check
  claude_screen "✽ Working… (esc to interrupt)"
  check
  tmux send-keys -t "$AGENT_PANE" "clear; printf '%s\\n' 'fala de esc to interrupt' 2 3 4 5 6 7 8 '❯ '" Enter
  sleep 1.6
  check
  assert_equal "$(agent_done_flag)" 1 "the window of a claude whose conversation mentions the phrase"
}

test_claude_with_a_todo_list_is_still_working() {
  install_workdeck >/dev/null || fail "install exited with an error"
  claude_session
  check
  claude_screen "✽ Working… (esc to interrupt)"
  check
  tmux send-keys -t "$AGENT_PANE" "clear; printf '%s\\n' '✽ Working… (esc to interrupt)' '  ⎿  ☐ um' '     ☐ dois' '     ☐ tres' '     ☐ quatro' '     ☐ cinco' '     ☐ seis' '' '────' '❯ ' '────' '  ? for shortcuts'" Enter
  sleep 0.4
  check
  sleep 1.2
  check
  assert_equal "$(agent_done_flag)" "" "the window of a claude working through a todo list"
}

test_codex_status_line_counts_as_working() {
  install_workdeck >/dev/null || fail "install exited with an error"
  agent_session codex bash
  wait_for sh -c "[ \"\$(tmux display -p -t '$AGENT_PANE' '#{cursor_x}')\" -gt 0 ]" || fail "the fake codex shell did not show a prompt"
  check
  claude_screen "• Working (1s • esc to interrupt)"
  check
  tmux send-keys -t "$AGENT_PANE" "clear; printf '%s\\n' '• Working (5s • esc to interrupt)' '' '› rascunho' 'linha 2' 'linha 3' 'linha 4' 'linha 5' 'linha 6' 'linha 7' 'linha 8' '' '  ⏎ send'" Enter
  sleep 0.4
  check
  sleep 1.2
  check
  assert_equal "$(agent_done_flag)" "" "the window of a codex with a long draft"
}

test_claude_footer_notices_do_not_mark_it_done() {
  install_workdeck >/dev/null || fail "install exited with an error"
  claude_session
  check
  claude_screen "◐ medium · /effort"
  check
  claude_screen "tmux focus-events off"
  sleep 1.2
  check
  assert_equal "$(agent_done_flag)" "" "the window of an idle claude whose footer changed"
}

test_one_star_for_a_window_with_several_finished_chats() {
  install_workdeck >/dev/null || fail "install exited with an error"
  agent_session
  second="$(tmux split-window -d -P -F '#{pane_id}' -t "$AGENT_WIN" "$BASE/bin/aider")"
  wait_for sh -c "ps -o comm= -t \"\$(tmux display -p -t '$second' '#{pane_tty}' | sed 's#/dev/##')\" | grep -q aider" || fail "the second fake agent did not start"
  check
  agent_writes "um"
  tmux send-keys -t "$second" -l "dois"
  sleep 0.3
  check
  sleep 1.2
  check
  assert_equal "$(tmux show -wqv -t "$AGENT_WIN" @agent_stars)" "✦" "a single star for two finished chats"
}

test_check_succeeds_when_the_last_pane_has_no_agent() {
  install_workdeck >/dev/null || fail "install exited with an error"
  agent_session
  tmux new-window -d -t work: -n server
  WORKDECK_AGENT_IDLE=1 work _check-agents || fail "a check with a plain pane last exited with an error"
  finish_a_task
  assert_equal "$(agent_done_flag)" 1 "the finished agent's window"
}

test_opening_the_window_clears_its_stars_at_once() {
  install_workdeck >/dev/null || fail "install exited with an error"
  agent_session
  finish_a_task
  assert_equal "$(agent_done_flag)" 1 "the finished agent's window"
  work _seen "$AGENT_WIN"
  assert_equal "$(agent_done_flag)" "" "the window right after it is opened"
  assert_contains "$(tmux show-hooks -g session-window-changed)" "work _seen" "the window change hook"
}

test_settings_clear_stars_when_the_terminal_gets_focus_back() {
  install_workdeck >/dev/null || fail "install exited with an error"
  tmux new-session -d -s work -x 120 -y 30
  tmux source-file "$HOME/.tmux.conf"
  work _settings >/dev/null 2>&1
  assert_contains "$(tmux show-hooks -g client-focus-in)" "work _seen" "the focus hook"
}

test_check_without_agents_does_not_fail() {
  install_workdeck >/dev/null || fail "install exited with an error"
  tmux new-session -d -s work -x 120 -y 30
  work _check-agents || fail "a check without agents exited with an error"
}
