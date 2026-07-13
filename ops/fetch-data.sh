#!/usr/bin/env bash
#
# fetch-data.sh — pull project data down from Cloudflare R2.
#
# Usage:
#   ops/fetch-data.sh [prefix]
#
#   prefix   Optional path within the bucket to sync (overrides R2_PREFIX).
#
# Configuration (env vars, or a .env file at the repo root):
#   R2_ACCOUNT_ID          Cloudflare account ID (the hex ID in your R2 endpoint URL)
#   R2_ACCESS_KEY_ID       R2 API token access key ID
#   R2_SECRET_ACCESS_KEY   R2 API token secret
#   R2_BUCKET              Bucket name
#   R2_PREFIX              Optional path within the bucket (default: entire bucket)
#   DATA_DIR               Local destination directory (default: ./data)
#
# Requires the AWS CLI (R2 is S3-compatible): https://developers.cloudflare.com/r2/api/s3/
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load .env if present (values already in the environment take precedence).
if [[ -f "$repo_root/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$repo_root/.env"
  set +a
fi

missing=()
for var in R2_ACCOUNT_ID R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY R2_BUCKET; do
  [[ -n "${!var:-}" ]] || missing+=("$var")
done
if (( ${#missing[@]} )); then
  echo "error: missing required configuration: ${missing[*]}" >&2
  echo "Set them in the environment or in $repo_root/.env (see .env.example)." >&2
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "error: the AWS CLI is required but not installed." >&2
  echo "Install it: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" >&2
  exit 1
fi

prefix="${1:-${R2_PREFIX:-}}"
prefix="${prefix#/}"
data_dir="${DATA_DIR:-$repo_root/data}"

source_url="s3://${R2_BUCKET}"
dest_dir="$data_dir"
if [[ -n "$prefix" ]]; then
  source_url+="/${prefix%/}"
  dest_dir+="/${prefix%/}"
fi

export AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="auto"
# R2 does not support the newer AWS CLI default integrity checksums.
# https://developers.cloudflare.com/r2/examples/aws/aws-cli/
export AWS_REQUEST_CHECKSUM_CALCULATION="when_required"
export AWS_RESPONSE_CHECKSUM_VALIDATION="when_required"

mkdir -p "$dest_dir"

echo "Syncing ${source_url} -> ${dest_dir}"
aws s3 sync "$source_url" "$dest_dir" \
  --endpoint-url "https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"

echo "Done."
