project_with_change() {
  mkdir -p "$HOME/api"
  git -C "$HOME/api" init -q
  echo 'export const a = 1' > "$HOME/api/index.ts"
  git -C "$HOME/api" add -A
  git -C "$HOME/api" -c user.name=t -c user.email=t@t commit -qm initial
  echo 'export const a = 2' > "$HOME/api/index.ts"
}

test_review_asks_for_colored_findings() {
  install_workdeck >/dev/null || fail "install exited with an error"
  project_with_change
  (cd "$HOME/api" && work review >/dev/null 2>&1)
  request="$HOME/.cache/workdeck/review-request.md"
  assert "the request was written" test -s "$request"
  text="$(cat "$request")"
  assert_contains "$text" "🔴 arquivo:linha"
  assert_contains "$text" "🟠 arquivo:linha"
  assert_contains "$text" "🟢 pode commitar"
  assert_contains "$text" "🔴 corrija os vermelhos antes do commit"
  assert_contains "$text" "sem explicação longa"
}

test_review_includes_project_instructions() {
  install_workdeck >/dev/null || fail "install exited with an error"
  project_with_change
  mkdir -p "$HOME/api/.workdeck"
  echo 'Use a branch develop como base.' > "$HOME/api/.workdeck/review.md"
  (cd "$HOME/api" && work review >/dev/null 2>&1)
  assert_contains "$(cat "$HOME/.cache/workdeck/review-request.md")" "Use a branch develop como base."
}

test_review_without_changes_says_so() {
  install_workdeck >/dev/null || fail "install exited with an error"
  project_with_change
  git -C "$HOME/api" checkout -q -- index.ts
  assert_contains "$(cd "$HOME/api" && work review 2>&1)" "nada mudou desde o último commit"
}
