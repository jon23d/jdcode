/**
 * Telegram Notification Plugin for OpenCode
 * 
 * Sends Telegram messages via the Bot API when OpenCode session events occur.
 * Only activates when all required Telegram environment variables are set.
 * Uses the built-in fetch() API (Node 18+) — no npm dependencies required.
 * 
 * Required Environment Variables:
 * - TELEGRAM_ENABLED=true (to activate the plugin)
 * - TELEGRAM_BOT_TOKEN (your bot token from @BotFather)
 * - TELEGRAM_CHAT_ID (the chat ID to send messages to)
 */

export const TelegramNotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  // Load Telegram credentials from environment
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_CHAT_ID;
  const enabled = process.env.TELEGRAM_ENABLED === 'true';

  // Skip if not configured or not enabled
  if (!enabled) {
    await client.app.log({
      body: {
        service: "telegram-notifications",
        level: "debug",
        message: "Telegram notifications disabled (TELEGRAM_ENABLED not set to true)"
      }
    });
    return {};
  }

  // Validate required environment variables
  const missingVars = [];
  if (!botToken) missingVars.push('TELEGRAM_BOT_TOKEN');
  if (!chatId) missingVars.push('TELEGRAM_CHAT_ID');

  if (missingVars.length > 0) {
    await client.app.log({
      body: {
        service: "telegram-notifications",
        level: "warn",
        message: "Telegram notifications enabled but missing required environment variables",
        extra: { missingVars }
      }
    });
    return {};
  }

  await client.app.log({
    body: {
      service: "telegram-notifications",
      level: "info",
      message: "Telegram notifications initialized",
      extra: {
        chatId,
        botTokenPrefix: botToken.slice(0, 6) + '***'
      }
    }
  });

  // Helper function to send a Telegram message
  const sendTelegram = async (message, eventType = null) => {
    const url = `https://api.telegram.org/bot${botToken}/sendMessage`;

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          chat_id: chatId,
          text: message
        })
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.description || `HTTP ${response.status}`);
      }

      await client.app.log({
        body: {
          service: "telegram-notifications",
          level: "info",
          message: "Telegram message sent successfully",
          extra: {
            messageId: result.result?.message_id,
            eventType,
            messageLength: message.length
          }
        }
      });
    } catch (error) {
      await client.app.log({
        body: {
          service: "telegram-notifications",
          level: "error",
          message: "Failed to send Telegram message",
          extra: {
            error: error.message,
            eventType
          }
        }
      });
    }
  };

  // Get project name for context in messages
  const projectName = project?.name || 'OpenCode';
  const containerName = process.env.HOSTNAME || 'container';

  return {
    // Hook into OpenCode session events
    event: async ({ event }) => {
      const timestamp = new Date().toLocaleTimeString();

      switch (event.type) {
        case 'session.idle':
          await sendTelegram(
            `🤖 ${projectName} session has been idle since ${timestamp}`,
            'session.idle'
          );
          break;

        case 'session.error':
          await sendTelegram(
            `❌ ${projectName} session encountered an error at ${timestamp}`,
            'session.error'
          );
          break;

        case 'session.created':
          await sendTelegram(
            `🚀 ${projectName} session started at ${timestamp}`,
            'session.created'
          );
          break;

        case 'session.deleted':
          await sendTelegram(
            `🗑️ ${projectName} session ended at ${timestamp}`,
            'session.deleted'
          );
          break;

        default:
          await client.app.log({
            body: {
              service: "telegram-notifications",
              level: "debug",
              message: "Received unhandled event",
              extra: { eventType: event.type }
            }
          });
          break;
      }
    }
  };
};
