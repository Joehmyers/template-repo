#!/usr/bin/env bash
#
# push-assets.sh — upload created assets to Cloudflare R2 so they are
# accessible from anywhere.
#
# Usage:
#   ops/push-assets.sh [--auto] [prefix]
#
#   --auto   Hook mode: exit 0 silently when R2 is unconfigured, the AWS CLI
#            is missing, or there is nothing to push. Used by the Stop hook
#            in .claude/settings.json so a fresh clone never errors.
#   prefix   Optional path within the bucket to upload to
#            (overrides R2_ASSETS_PREFIX; default: assets).
#
# Configuration (env vars, or a .env file at the repo root):
#   R2_ACCOUNT_ID          Cloudflare account ID (the hex ID in your R2 endpoint URL)
#   R2_ACCESS_KEY_ID       R2 API token access key ID
#   R2_SECRET_ACCESS_KEY   R2 API token secret
#   R2_BUCKET              Bucket name
#   R2_ASSETS_PREFIX       Optional path within the bucket to upload to (default: assets)
#   ASSETS_DIR             Local directory of created assets (default: ./assets;
#                          relative paths resolve against the repo root)
#
# Uploads new and changed files only; never deletes remote objects. Symlinks
# and secret-looking files (.env*, *.pem, *.key) are never uploaded.
# Retrieve assets elsewhere with: ops/fetch-data.sh assets (lands in ./data/assets)
#
# Requires the AWS CLI (R2 is S3-compatible): https://developers.cloudflare.com/r2/api/s3/
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

auto=0
prefix_set=0
prefix=""
for arg in "$@"; do
  case "$arg" in
    --auto)
      auto=1
      ;;
    *)
      if (( prefix_set )); then
        echo "error: unexpected argument: $arg" >&2
        echo "usage: ops/push-assets.sh [--auto] [prefix]" >&2
        exit 1
      fi
      prefix="$arg"
      prefix_set=1
      ;;
  esac
done

# Load the keys we need from .env if present. Parsed, not sourced: this script
# runs automatically via a Stop hook, and sourcing would execute arbitrary
# shell from a gitignored file (and export unrelated secrets to the aws
# process). Values already in the environment take precedence.
if [[ -f "$repo_root/.env" ]]; then
  while IFS= read -r line; do
    key="${line%%=*}"
    value="${line#*=}"
    case "$value" in
      \"*\") value="${value%\"}"; value="${value#\"}" ;;
      \'*\') value="${value%\'}"; value="${value#\'}" ;;
    esac
    [[ -n "${!key:-}" ]] || printf -v "$key" '%s' "$value"
  done < <(grep -E '^(export[[:space:]]+)?(R2_ACCOUNT_ID|R2_ACCESS_KEY_ID|R2_SECRET_ACCESS_KEY|R2_BUCKET|R2_ASSETS_PREFIX|ASSETS_DIR)=' "$repo_root/.env" 2>/dev/null | sed -E 's/^export[[:space:]]+//' || true)
fi

missing=()
for var in R2_ACCOUNT_ID R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY R2_BUCKET; do
  [[ -n "${!var:-}" ]] || missing+=("$var")
done
if (( ${#missing[@]} )); then
  (( auto )) && exit 0
  echo "error: missing required configuration: ${missing[*]}" >&2
  echo "Set them in the environment or in $repo_root/.env (see .env.example)." >&2
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  (( auto )) && exit 0
  echo "error: the AWS CLI is required but not installed." >&2
  echo "Install it: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" >&2
  exit 1
fi

assets_dir="${ASSETS_DIR:-$repo_root/assets}"
[[ "$assets_dir" == /* ]] || assets_dir="$repo_root/${assets_dir#./}"

if [[ ! -d "$assets_dir" ]] || [[ -z "$(find "$assets_dir/." -type f -print -quit)" ]]; then
  (( auto )) && exit 0
  echo "error: nothing to push — $assets_dir is missing or empty." >&2
  exit 1
fi

(( prefix_set )) || prefix="${R2_ASSETS_PREFIX:-assets}"
while [[ "$prefix" == /* ]]; do prefix="${prefix#/}"; done
while [[ "$prefix" == */ ]]; do prefix="${prefix%/}"; done

dest_url="s3://${R2_BUCKET}"
if [[ -n "$prefix" ]]; then
  dest_url+="/${prefix}"
fi

export AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="auto"
# R2 does not support the newer AWS CLI default integrity checksums.
# https://developers.cloudflare.com/r2/examples/aws/aws-cli/
export AWS_REQUEST_CHECKSUM_CALCULATION="when_required"
export AWS_RESPONSE_CHECKSUM_VALIDATION="when_required"

sync_cmd=(aws s3 sync "$assets_dir" "$dest_url"
  --endpoint-url "https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
  --no-follow-symlinks
  --exclude ".env*" --exclude "*/.env*"
  --exclude "*.pem" --exclude "*.key")

if (( auto )); then
  # Hook mode: fail fast on a bad network/endpoint instead of stalling the
  # turn, and never exit 2 — a Stop hook exiting 2 blocks the session from
  # stopping (aws s3 sync exits 2 when files were skipped).
  export AWS_MAX_ATTEMPTS=2
  sync_cmd+=(--cli-connect-timeout 5)
  if ! "${sync_cmd[@]}" >/dev/null; then
    echo "push-assets: upload to R2 failed; run ops/push-assets.sh to see details." >&2
    exit 1
  fi
  exit 0
fi

echo "Syncing ${assets_dir} -> ${dest_url}"
if ! "${sync_cmd[@]}"; then
  echo "error: aws s3 sync failed." >&2
  exit 1
fi

echo "Done."
