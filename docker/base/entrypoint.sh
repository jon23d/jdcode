#!/bin/bash
set -e

# Create log directory
mkdir -p /var/log

code-server --port "${PORT}" --auth none --bind-addr "0.0.0.0:${PORT}" /code > /var/log/code-server.log 2>&1 &

# Give code-server a moment to start
sleep 3

# Check if code-server started successfully
if ! ps aux | grep -v grep | grep code-server > /dev/null; then
    echo "ERROR: code-server process not found!"
    echo "Check logs:"
    cat /var/log/code-server.log
    exit 1
fi

# Additional check: verify the port is listening
sleep 1
if ! grep -q "HTTP server listening" /var/log/code-server.log; then
    echo "WARNING: code-server may not be listening yet"
    echo "Check logs:"
    cat /var/log/code-server.log
fi

# Clear screen and show welcome message
clear
echo "═══════════════════════════════════════════════════════"
echo "  Welcome to opencode Development Environment"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "  ✅ VS Code is running at: http://localhost:${PORT}"
echo ""
echo "  Run \`opencode\` to start an AI coding session"
echo ""
echo "═══════════════════════════════════════════════════════"
echo ""

# Drop to bash prompt
exec tmuxinator dev
