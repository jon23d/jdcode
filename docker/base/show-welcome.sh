#!/bin/bash
set -e

# ─────────────────────────────────────────────
# Welcome Message Display Script
# Shows welcome message with dynamic version info
# ─────────────────────────────────────────────

LOCAL_VERSION_FILE="/usr/local/share/VERSION"
VERSION_CHECK_SCRIPT="/usr/local/bin/check-version.sh"

# Read local version
if [ -f "$LOCAL_VERSION_FILE" ]; then
  LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '[:space:]')
else
  LOCAL_VERSION="unknown"
fi

# Get version status (if check script exists)
VERSION_STATUS=""
if [ -x "$VERSION_CHECK_SCRIPT" ]; then
  VERSION_STATUS=$("$VERSION_CHECK_SCRIPT") || true
fi

# Build version line with proper padding (Unicode-aware)
if [ -n "$VERSION_STATUS" ]; then
  VERSION_TEXT="Version: $LOCAL_VERSION $VERSION_STATUS"
else
  VERSION_TEXT="Version: $LOCAL_VERSION"
fi

# Use Python for Unicode-aware padding
VERSION_LINE=$(python3 -c "print(f'║  {\"$VERSION_TEXT\":<60}║')")

# Display welcome message with dynamic version
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    Welcome to JDCode                         ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
EOF

echo "$VERSION_LINE"

# Check Telegram status and display in welcome
if [ "${TELEGRAM_ENABLED}" = "true" ]; then
    TELEGRAM_STATUS="ENABLED"
    TELEGRAM_ICON="🔔"
else
    TELEGRAM_STATUS="DISABLED"
    TELEGRAM_ICON="📵"
fi

# Add Telegram status to welcome message
TELEGRAM_LINE=$(python3 -c "print(f'║  ${TELEGRAM_ICON} Telegram notifications: ${TELEGRAM_STATUS:<8}                         ║')")
echo "$TELEGRAM_LINE"

cat << 'EOF'
║                                                              ║
║  Mouse mode is ENABLED - click to switch panes & scroll      ║
║                                                              ║
║  Navigation:                                                 ║
║    • Switch panes: Ctrl+b + arrow keys OR click with mouse   ║
║    • Resize panes: Ctrl+b + hold Ctrl + arrow keys           ║
║                    OR drag pane borders with mouse           ║
║                                                              ║
║  OpenCode (top pane):                                        ║
║    • AI-powered coding assistant                             ║
║    • Type commands or ask questions                          ║
║    • Ctrl+p to list available actions                        ║
║                                                              ║
║  Access:                                                     ║
║    • VS Code web UI: http://localhost:8080                   ║
║                                                              ║
║  Resources:                                                  ║
║    • Tmux cheat sheet: https://tmuxcheatsheet.com            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
