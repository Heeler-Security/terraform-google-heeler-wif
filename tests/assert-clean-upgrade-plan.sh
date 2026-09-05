#!/usr/bin/env sh
set -eu

test_log="$(mktemp)"
trap 'rm -f "$test_log"' EXIT

if ! terraform test -verbose -filter=tests/upgrade_v1.tftest.hcl >"$test_log" 2>&1; then
  cat "$test_log"
  exit 1
fi

cat "$test_log"

if ! awk '
  /run "second_upgrade_plan_is_clean"/ { in_second_plan = 1 }
  in_second_plan && /No changes\./ { clean_plan = 1 }
  END { exit clean_plan ? 0 : 1 }
' "$test_log"; then
  echo "The second v1-to-v2 upgrade plan was not clean." >&2
  exit 1
fi
