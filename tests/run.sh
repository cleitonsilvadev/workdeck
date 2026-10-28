#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$ROOT/tests/lib.sh"

command -v tmux >/dev/null || { echo "the tests need tmux"; exit 1; }
command -v git >/dev/null || { echo "the tests need git"; exit 1; }

filter="${1:-}"
setup_repo
trap 'rm -rf "$TEST_TMP"' EXIT

passed=0
failed=()
for file in "$ROOT"/tests/*.test.sh; do
  while IFS= read -r test_name; do
    if [ -n "$filter" ]; then
      case "$test_name" in *"$filter"*) ;; *) continue ;; esac
    fi
    log="$TEST_TMP/$test_name.log"
    if ( . "$file"; setup_home "$test_name"; trap cleanup_tmux EXIT; "$test_name" ) < /dev/null > "$log" 2>&1; then
      printf '  \033[32m✓\033[0m %s\n' "$test_name"
      passed=$((passed + 1))
    else
      printf '  \033[31m✗\033[0m %s\n' "$test_name"
      sed 's/^/      /' "$log" | tail -n 25
      failed+=("$test_name")
    fi
  done < <(grep -oE '^test_[a-z0-9_]+' "$file")
done

echo
if [ ${#failed[@]} -gt 0 ]; then
  echo "$passed passed, ${#failed[@]} failed: ${failed[*]}"
  exit 1
fi
echo "$passed passed"
