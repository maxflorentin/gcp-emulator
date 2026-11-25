#!/usr/bin/env bash
# Runs every stack under e2e/stacks against a locally running emulator:
# apply, then plan -detailed-exitcode (must be 0, i.e. no drift), then destroy.
# Usage: e2e/run.sh [stack ...]   (default: all stacks)
set -uo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
if [ "$#" -gt 0 ]; then stacks=("$@"); else stacks=($(cd "$root/stacks" && ls)); fi

failed=()
for stack in "${stacks[@]}"; do
  dir="$root/stacks/$stack"
  echo "=== $stack ==="
  work="$(mktemp -d)"
  cp "$dir"/*.tf "$work"/
  (
    cd "$work" || exit 1
    export TF_IN_AUTOMATION=1 TF_INPUT=0
    terraform init -no-color >/dev/null || exit 1
    terraform apply -auto-approve -no-color || exit 1
    terraform plan -detailed-exitcode -no-color
    rc=$?
    if [ "$rc" -ne 0 ]; then
      echo "FAIL: plan after apply is not empty (exit $rc): provider sees drift" >&2
      terraform destroy -auto-approve -no-color >/dev/null 2>&1
      exit 1
    fi
    terraform destroy -auto-approve -no-color || exit 1
  ) || failed+=("$stack")
  rm -rf "$work"
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "FAILED stacks: ${failed[*]}" >&2
  exit 1
fi
echo "All stacks passed"
