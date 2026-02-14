#!/bin/bash
set -e

# Create log directory
mkdir -p /var/log

code-server --port 8080 --auth none --bind-addr "0.0.0.0:8080" /code > /var/log/code-server.log 2>&1 &

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

# Detect and display timezone
if [ -n "${TZ}" ]; then
    echo "🕐 Timezone: ${TZ} (from TZ env var)"
elif [ -f /etc/timezone ] && [ "$(cat /etc/timezone)" != "Etc/UTC" ]; then
    echo "🕐 Timezone: $(cat /etc/timezone) (from /etc/localtime mount)"
else
    echo "🕐 Timezone: UTC (default — mount /etc/localtime to match host)"
fi

# Validate Telegram notification configuration
if [ "${TELEGRAM_ENABLED}" = "true" ]; then
    echo "🔔 Telegram notifications: ENABLED"
    
    # Check for required environment variables
    missing_vars=()
    [ -z "${TELEGRAM_BOT_TOKEN}" ] && missing_vars+=("TELEGRAM_BOT_TOKEN")
    [ -z "${TELEGRAM_CHAT_ID}" ] && missing_vars+=("TELEGRAM_CHAT_ID")
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "⚠️  WARNING: Telegram enabled but missing required environment variables:"
        printf '   - %s\n' "${missing_vars[@]}"
        echo "   Telegram notifications will not work until all variables are set."
    else
        # Mask bot token for security (show first 6 and last 4 chars)
        token_masked=$(echo "${TELEGRAM_BOT_TOKEN}" | sed 's/\(.\{6\}\).*\(.\{4\}\)/\1***\2/')
        echo "   🤖 Bot token: ${token_masked}"
        echo "   💬 Chat ID: ${TELEGRAM_CHAT_ID}"
        echo "   ✓ All required variables configured"
    fi
elif [ -n "${TELEGRAM_BOT_TOKEN}" ] || [ -n "${TELEGRAM_CHAT_ID}" ]; then
    echo "📵 Telegram notifications: DISABLED (set TELEGRAM_ENABLED=true to enable)"
else
    echo "📵 Telegram notifications: Not configured"
fi

# Clear screen and show welcome message
echo "loading session..."

# Open tmuxinator
exec tmuxinator dev
