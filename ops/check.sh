#!/usr/bin/env bash
#
# check.sh: the one command that says whether this repo is green.
#
# Agents, humans and CI all run this same script, so the answer to "is this
# change safe to push?" cannot drift between them. AGENTS.md points agents
# here; .github/workflows/ci.yml runs it on every pull request.
#
# Usage:
#   ops/check.sh            Run every configured step; skip the unconfigured ones.
#   ops/check.sh --strict   Also fail when a project step (lint, test, build)
#                           is still unconfigured. A missing optional tool
#                           (shellcheck) is reported but never fails the run.
#
# Configure the three commands in the block below, one line each. An empty
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
      # Print the header comment above (line 3 down to the `set` line).
      sed -n '3,/^set -/p' "${BASH_SOURCE[0]}" | sed '$d' | sed 's/^# \{0,1\}//'
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
missing_tools=()

# Run one named step whose command is a string (the user-configured project
# steps above). Prints its output, records the outcome, never exits early, so
# a full run tells you everything that is broken, not just the first thing.
run_step() {
  local name="$1" command="$2"

  if [[ -z "$command" ]]; then
    echo "SKIP  ${name}: not configured (set CHECK_${name^^} in ops/check.sh)"
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

# Run one named step whose command is an argv list, so a filename with a space
# or a shell metacharacter stays one argument and is never re-parsed as shell
# (a file named `a;rm x;.sh` must not run `rm`).
run_step_argv() {
  local name="$1" display="$2"
  shift 2

  echo "RUN   ${name}: ${display}"
  if "$@"; then
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

# `bash -n` only checks its first argument (the rest become positional
# parameters), so check each script separately.
check_shell_syntax() {
  local script status=0
  for script in "${shell_scripts[@]}"; do
    bash -n "$script" || status=1
  done
  return "$status"
}

if (( ${#shell_scripts[@]} )); then
  run_step_argv "shell-syntax" "bash -n, each of ${#shell_scripts[@]} scripts" \
    check_shell_syntax
  if command -v shellcheck >/dev/null 2>&1; then
    run_step_argv "shellcheck" "shellcheck, ${#shell_scripts[@]} scripts" \
      shellcheck "${shell_scripts[@]}"
  else
    echo "SKIP  shellcheck: not installed (https://www.shellcheck.net/)"
    missing_tools+=("shellcheck")
  fi
fi

# The ops/ scripts derive the R2 bucket name from the repository name
# (ops/lib.sh; docs/decisions/D-0001-*.md), while wrangler.jsonc hardcodes the
# same name for the Worker binding. After a repository rename the two drift
# apart silently, so fail when the name the scripts would use no longer
# appears in wrangler.jsonc.
check_r2_config() {
  local expected="$1" names
  names="$(sed -nE 's/.*"bucket_name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' wrangler.jsonc)"
  if ! grep -qxF "$expected" <<< "$names"; then
    echo "wrangler.jsonc binds bucket '${names//$'\n'/, }'; the ops/ scripts use '${expected}'." >&2
    echo "Update bucket_name (and name) in wrangler.jsonc, or set R2_BUCKET to match it." >&2
    return 1
  fi
}

if [[ -f wrangler.jsonc ]] && grep -q '"bucket_name"' wrangler.jsonc; then
  load_dotenv   # R2_BUCKET in .env overrides the repository-name default
  expected_bucket="$(r2_bucket_name)"
  run_step_argv "r2-config" "wrangler.jsonc bucket_name = ${expected_bucket}" \
    check_r2_config "$expected_bucket"
fi

# --- Project checks --------------------------------------------------------

run_step "lint" "$CHECK_LINT"
run_step "test" "$CHECK_TEST"
run_step "build" "$CHECK_BUILD"

# --- Verdict ---------------------------------------------------------------

echo
if [[ -z "$CHECK_LINT" && -z "$CHECK_TEST" && -z "$CHECK_BUILD" ]]; then
  echo "WARNING: no lint, test, or build command is configured, so only the"
  echo "         shell scripts were checked. Fill in the block at the top of"
  echo "         ops/check.sh; until then a green run proves very little."
fi

if (( ${#failed[@]} )); then
  echo "FAILED: ${failed[*]}" >&2
  exit 1
fi

if (( strict )) && (( ${#skipped[@]} )); then
  echo "FAILED: --strict, and these steps are not configured: ${skipped[*]}" >&2
  exit 1
fi

verdict="OK"
if (( ${#skipped[@]} )); then
  verdict+=" (skipped: ${skipped[*]})"
fi
if (( ${#missing_tools[@]} )); then
  verdict+=" (missing tools: ${missing_tools[*]})"
fi
echo "$verdict"
