#!/usr/bin/env bash

set -e

for TEST in transitions/*.json; do
  BOARD="$(cat "$TEST" | jq -cSr .board)"
  ACTIONS="$(cat "$TEST" | jq -cSr .actions)"
  EXPECTED="$(cat "$TEST" | jq -cSr .expected)"

  diff <($* "$BOARD" "$ACTIONS" | jq -cSr .) <(echo "$EXPECTED")
done

echo "tests passed"
