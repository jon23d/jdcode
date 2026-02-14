# Telegram Notifications for OpenCode

This feature sends Telegram messages via the Bot API when OpenCode session events occur, such as when a session becomes idle or encounters an error.

## Setup

### 1. Create a Telegram Bot

1. Open Telegram and search for [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow the prompts to create a bot
3. BotFather will give you a **Bot Token** (e.g., `123456789:ABCdefGhIjKlMnOpQrStUvWxYz`)

### 2. Get Your Chat ID

1. Start a conversation with your new bot (search for it by username and press **Start**)
2. Send any message to the bot
3. Open this URL in your browser (replace `YOUR_BOT_TOKEN`):
   ```
   https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
   ```
4. Look for `"chat":{"id":123456789}` in the response — that number is your **Chat ID**


> **Tip:** For group chats, add the bot to the group, send a message, and check `getUpdates`. Group chat IDs are typically negative numbers.

### 3. Configure Environment Variables

Set the following environment variables:

```bash
# Required - Enable the feature
export TELEGRAM_ENABLED=true

# Required - Your bot token from @BotFather
export TELEGRAM_BOT_TOKEN=123456789:ABCdefGhIjKlMnOpQrStUvWxYz

# Required - The chat ID to send messages to
export TELEGRAM_CHAT_ID=987654321
```

### 4. Run OpenCode Container

#### Basic Usage
```bash
docker run -it --rm \
  -v "$PWD":/code \
  -v /etc/localtime:/etc/localtime:ro \
  -p 8080:8080 \
  -e TELEGRAM_ENABLED=true \
  -e TELEGRAM_BOT_TOKEN=your_bot_token \
  -e TELEGRAM_CHAT_ID=your_chat_id \
  jdcode-python
```

#### Using Environment File
Create a `.env` file with your Telegram credentials:

```bash
# .env
TELEGRAM_ENABLED=true
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
```

Then run with:
```bash
docker run -it --rm \
  -v "$PWD":/code \
  -v /etc/localtime:/etc/localtime:ro \
  -p 8080:8080 \
  --env-file .env \
  jdcode-python
```

## Events That Trigger Notifications

The plugin sends Telegram messages for these OpenCode session events:

| Event | Message | When It Occurs |
|-------|---------|---------------|
| `session.created` | 🚀 ProjectName session started at [time] | When a new session is created |
| `session.idle` | 🤖 ProjectName session has been idle since [time] | When OpenCode session becomes inactive |
| `session.error` | ❌ ProjectName session encountered an error at [time] | When an error occurs in the session |
| `session.deleted` | 🗑️ ProjectName session ended at [time] | When the session is terminated |

## Validation and Feedback

When the container starts, you'll see status messages:

### Properly Configured
```
🔔 Telegram notifications: ENABLED
   🤖 Bot token: 123456***xYz
   💬 Chat ID: 987654321
   ✓ All required variables configured
```

### Missing Variables
```
🔔 Telegram notifications: ENABLED
⚠️  WARNING: Telegram enabled but missing required environment variables:
   - TELEGRAM_BOT_TOKEN
   Telegram notifications will not work until all variables are set.
```

### Disabled
```
📵 Telegram notifications: DISABLED (set TELEGRAM_ENABLED=true to enable)
```

## Security Notes

- **Bot tokens are masked** in logs and startup messages
- **Credentials are only loaded from environment variables** (not stored in files)
- The plugin only activates when `TELEGRAM_ENABLED=true` is explicitly set

## Troubleshooting

### No Messages Received
1. Check that all environment variables are set correctly
2. Verify you started a conversation with the bot (press Start in Telegram)
3. Verify your chat ID is correct by checking `getUpdates`
4. Check OpenCode logs for error messages:
   ```bash
   docker logs <container-id>
   ```

### Plugin Not Loading
- The plugin is automatically loaded from `docker/base/.opencode/plugins/`
- No npm dependencies are required (uses built-in `fetch()`)
- Check OpenCode startup logs for plugin initialization messages

### Testing
To test the notification functionality, you can trigger a session idle event by leaving OpenCode inactive for a period of time.

## Example Build and Run Script

Create a `run-with-telegram.sh` script:

```bash
#!/bin/bash
set -e

# Build the OpenCode image
./build.sh

# Run with Telegram notifications
docker run -it --rm \
  -v "$PWD":/code \
  -v /etc/localtime:/etc/localtime:ro \
  -p 8080:8080 \
  -e TELEGRAM_ENABLED=true \
  -e TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}" \
  -e TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}" \
  jdcode-python
```

Make it executable and run:
```bash
chmod +x run-with-telegram.sh
./run-with-telegram.sh
```
