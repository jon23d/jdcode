#!/bin/bash
set -e

# ─────────────────────────────────────────────
# Version Check Script
# Compares local version against latest from GitHub
# Returns version status message or empty string on failure
# ─────────────────────────────────────────────

LOCAL_VERSION_FILE="/usr/local/share/VERSION"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/jon23d/jdcode/main/docker/VERSION"
TIMEOUT=3

# Read local version
if [ ! -f "$LOCAL_VERSION_FILE" ]; then
  exit 0
fi

LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '[:space:]')

# Fetch remote version with timeout (silent on failure)
HTTP_STATUS=$(curl -sS -o /tmp/remote_version.txt --max-time "$TIMEOUT" -w "%{http_code}" "$REMOTE_VERSION_URL" 2>/dev/null) || true

if [ "$HTTP_STATUS" != "200" ]; then
  exit 0
fi

REMOTE_VERSION=$(cat /tmp/remote_version.txt | tr -d '[:space:]')
rm -f /tmp/remote_version.txt

# If fetch failed, exit silently
if [ -z "$REMOTE_VERSION" ]; then
  exit 0
fi

# Compare versions
# Split versions into components
IFS='.' read -ra LOCAL_PARTS <<< "$LOCAL_VERSION"
IFS='.' read -ra REMOTE_PARTS <<< "$REMOTE_VERSION"

# Compare major.minor.patch
for i in 0 1 2; do
  LOCAL_NUM="${LOCAL_PARTS[$i]:-0}"
  REMOTE_NUM="${REMOTE_PARTS[$i]:-0}"
  
  if [ "$REMOTE_NUM" -gt "$LOCAL_NUM" ]; then
    echo "(new version $REMOTE_VERSION available)"
    exit 0
  elif [ "$REMOTE_NUM" -lt "$LOCAL_NUM" ]; then
    echo "✓ (latest)"
    exit 0
  fi
done

# Versions are equal
echo "✓ (latest)"
exit 0
