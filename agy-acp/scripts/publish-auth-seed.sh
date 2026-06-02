#!/usr/bin/env bash
# Packages agy auth data, uploads to S3, and generates a presigned URL.
# Usage: ./scripts/publish-auth-seed.sh [BUCKET] [EXPIRES_IN_SECONDS]
#
# Defaults:
#   BUCKET: openab-ci-seeds
#   EXPIRES_IN: 604800 (7 days)
#
# Output: presigned URL (set as GitHub secret AGY_AUTH_URL)

set -euo pipefail

BUCKET="${1:-openab-ci-seeds}"
EXPIRES_IN="${2:-604800}"
KEY="agy-acp/agy-auth.tar.gz"
TMP="/tmp/agy-auth.tar.gz"

AUTH_DIR="$HOME/.gemini/antigravity-cli"
if [ ! -d "$AUTH_DIR" ]; then
  echo "ERROR: $AUTH_DIR not found. Run 'agy' once to authenticate first." >&2
  exit 1
fi

echo "Packaging auth from $AUTH_DIR..."
tar -czf "$TMP" -C "$HOME" .gemini/antigravity-cli/

echo "Uploading to s3://$BUCKET/$KEY..."
aws s3 cp "$TMP" "s3://$BUCKET/$KEY" --quiet
rm -f "$TMP"

echo "Generating presigned URL (expires in ${EXPIRES_IN}s)..."
URL=$(aws s3 presign "s3://$BUCKET/$KEY" --expires-in "$EXPIRES_IN")

echo ""
echo "=== Presigned URL (valid for $((EXPIRES_IN / 86400)) days) ==="
echo "$URL"
echo ""
echo "Set as GitHub secret:"
echo "  gh secret set AGY_AUTH_URL --repo openabdev/openab --body '\$URL'"
