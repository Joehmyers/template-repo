#!/usr/bin/env bash
#
# check.sh — the one command that says whether this repo is green.
#
# Agents, humans and CI all run this same script, so the answer to "is this
# change safe to push?" cannot drift between them. AGENTS.md points agents
# here; .github/workflows/ci.yml runs it on every pull request.
#
# Usage:
#   ops/check.sh            Run every configured step; skip the unconfigured ones.
#   ops/check.sh --strict   Also fail when a step is still unconfigured.
#
# Configure the three commands in the block below — one line each. An empty
# value means "not configured yet", and the step is skipped with a note.
# Environment variables of the same name override the values here, so CI or a
# teammate can run a different command without editing this file.
#
# The shell checks below always run: this repo ships shell scripts, so the
# verification loop works on day one, before you have filled anything in.
set -uo pipefail

# shellcheck source=ops/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

repo_root="$(ops_repo_root)"
cd "$repo_root" || exit 1

# --- Configure your project here -------------------------------------------
: "${CHECK_LINT:=}"    # e.g. npm run lint       / ruff check .      / cargo clippy
: "${CHECK_TEST:=}"    # e.g. npm test           / pytest            / cargo test
: "${CHECK_BUILD:=}"   # e.g. npm run build      / python -m build   / cargo build
# ---------------------------------------------------------------------------

strict=0
for arg in "$@"; do
  case "$arg" in
    --strict) strict=1 ;;
    -h|--help)
      sed -n '3,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "error: unknown argument: $arg" >&2
      echo "usage: ops/check.sh [--strict]" >&2
      exit 1
      ;;
  esac
done

failed=()
skipped=()

# Run one named step. Prints its output, records the outcome, never exits early
# — a full run tells you everything that is broken, not just the first thing.
run_step() {
  local name="$1" command="$2"

  if [[ -z "$command" ]]; then
    echo "SKIP  ${name} — not configured (set CHECK_${name^^} in ops/check.sh)"
    skipped+=("$name")
    return 0
  fi

  echo "RUN   ${name}: ${command}"
  if bash -c "$command"; then
    echo "PASS  ${name}"
  else
    echo "FAIL  ${name} (exit $?)" >&2
    failed+=("$name")
  fi
}

# --- Always-on checks ------------------------------------------------------

# Every shell script must parse. `bash -n` is available wherever this runs.
shell_scripts=()
while IFS= read -r script; do
  shell_scripts+=("$script")
  # --others --exclude-standard catches scripts that are written but not yet
  # committed, so a new script is checked on the run that introduces it.
done < <(git ls-files --cached --others --exclude-standard '*.sh' 2>/dev/null \
  || find . -name '*.sh' -not -path './.git/*')

if (( ${#shell_scripts[@]} )); then
  run_step "shell-syntax" "bash -n ${shell_scripts[*]}"
  if command -v shellcheck >/dev/null 2>&1; then
    run_step "shellcheck" "shellcheck ${shell_scripts[*]}"
  else
    echo "SKIP  shellcheck — not installed (https://www.shellcheck.net/)"
    skipped+=("shellcheck")
  fi
fi

# --- Project checks --------------------------------------------------------

run_step "lint" "$CHECK_LINT"
run_step "test" "$CHECK_TEST"
run_step "build" "$CHECK_BUILD"

# --- Verdict ---------------------------------------------------------------

echo
if (( ${#failed[@]} )); then
  echo "FAILED: ${failed[*]}" >&2
  exit 1
fi

if (( strict )) && (( ${#skipped[@]} )); then
  echo "FAILED: --strict, and these steps are not configured: ${skipped[*]}" >&2
  exit 1
fi

if (( ${#skipped[@]} )); then
  echo "OK (skipped: ${skipped[*]})"
else
  echo "OK"
fi
