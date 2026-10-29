grid_session() {
  tmux new-session -d -s grid -x 121 -y 41 -c "$HOME"
  FIRST_PANE="$(tmux display -p -t grid '#{pane_id}')"
}

pane_ids() {
  tmux list-panes -t grid -F '#{pane_id}' | tr -d '%' | sort -n | sed 's/^/%/'
}

position_of() {
  tmux display -p -t "$1" '#{pane_left},#{pane_top}'
}

test_split_builds_a_two_by_two_grid() {
  install_workdeck >/dev/null || fail "install exited with an error"
  grid_session
  work _split "$FIRST_PANE"
  assert_equal "$(tmux list-panes -t grid | wc -l | tr -d ' ')" 2 "panes after the first split"
  second="$(pane_ids | sed -n 2p)"
  assert_equal "$(position_of "$second" | cut -d, -f2)" 0 "the second pane sits beside the first"
  work _split "$FIRST_PANE"
  third="$(pane_ids | sed -n 3p)"
  assert_equal "$(position_of "$third" | cut -d, -f1)" "$(position_of "$second" | cut -d, -f1)" "the third pane is in the second pane's column"
  work _split "$FIRST_PANE"
  fourth="$(pane_ids | sed -n 4p)"
  assert_equal "$(position_of "$fourth" | cut -d, -f1)" 0 "the fourth pane is in the first pane's column"
  assert_equal "$(position_of "$FIRST_PANE")" "0,0" "the first pane stays in place"
  assert_equal "$(position_of "$second" | cut -d, -f2)" 0 "the second pane stays in place"
  assert_equal "$(tmux list-panes -t grid -F '#{pane_width}x#{pane_height}' | sort -u | wc -l | tr -d ' ')" 1 "all four panes have the same size"
}

test_split_tiles_from_the_fifth_pane() {
  install_workdeck >/dev/null || fail "install exited with an error"
  grid_session
  for _ in 1 2 3 4; do work _split "$FIRST_PANE"; done
  assert_equal "$(tmux list-panes -t grid | wc -l | tr -d ' ')" 5 "panes"
  assert_equal "$(tmux list-panes -t grid -F '#{pane_top}' | sort -u | wc -l | tr -d ' ')" 3 "rows of the tiled layout"
}

test_split_keeps_the_panel_window_layout() {
  install_workdeck >/dev/null || fail "install exited with an error"
  grid_session
  tmux set -p -t "$FIRST_PANE" @role PANEL
  tmux split-window -v -l 8 -t "$FIRST_PANE"
  terminal="$(pane_ids | sed -n 2p)"
  work _split "$terminal"
  assert_equal "$(tmux display -p -t "$FIRST_PANE" '#{pane_width}')" "$(tmux display -p -t grid '#{window_width}')" "the panel keeps the full width"
}
