#!/usr/bin/env bash
#
# lib.sh — shared helpers for the ops/ scripts.
#
# Source this from another script:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
#
# Cloud storage for this project is assumed to be Cloudflare R2, and the
# bucket is named after the repository. These helpers resolve that name so
# the individual scripts don't have to repeat the logic.

# Absolute path to the repository root (the parent of ops/).
ops_repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

# Load a .env file at the repo root if present. Values already exported in the
# environment take precedence over the file.
load_dotenv() {
  local root saved line
  root="$(ops_repo_root)"
  [[ -f "$root/.env" ]] || return 0
  saved="$(export -p)"
  set -a
  # shellcheck disable=SC1091
  source "$root/.env"
  set +a
  # Re-assert the snapshot so pre-existing environment values win over .env.
  # (export -p emits `declare -x`, which would create function locals here.)
  while IFS= read -r line; do
    eval "${line/#declare -x /export }" 2>/dev/null || true
  done <<< "$saved"
}

# Derive the repository name (used as the default R2 bucket name).
#
# Order of preference:
#   1. The basename of the `origin` remote URL (matches the GitHub repo name).
#   2. The repository root directory name.
#
# The result is lowercased so it satisfies R2 bucket naming rules
# (lowercase letters, numbers and hyphens).
repo_name() {
  local name=""
  local url
  if url="$(git remote get-url origin 2>/dev/null)" && [[ -n "$url" ]]; then
    name="$(basename -s .git "$url")"
  fi
  if [[ -z "$name" ]]; then
    name="$(basename "$(ops_repo_root)")"
  fi
  printf '%s\n' "$name" | tr '[:upper:]' '[:lower:]'
}

# Resolve the R2 bucket name: the R2_BUCKET override if set, otherwise the
# repository name.
r2_bucket_name() {
  printf '%s\n' "${R2_BUCKET:-$(repo_name)}"
}
