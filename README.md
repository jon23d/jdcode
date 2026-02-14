# JDCode

This repository provides docker containers configured to run VSCode and Opencode.

## Variants

There are custom configurations for specific development environments, such as TypeScript and Python. Each variant has predefined extensions, settings, and tools tailored to the respective programming environment.

### 1️⃣ **jdcode-python**
- Includes:
  - `ms-python.python` extension for Python development (test running/play button enabled).
  - Python development tools, such as `flake8`, `autopep8`, and `mypy`.
  - `eamodio.gitlens` for Git blame and enhanced Git capabilities.
  - Configured keyboard shortcuts:
    - **Command/Control + U**: Expand selection.
    - **Shift + Command/Control + U**: Contract selection.

### 2️⃣ **jdcode-ts**
- Includes:
  - TypeScript-related extensions: `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, and `ms-vscode.vscode-typescript-tslint-plugin`.
  - `ms-vscode.vscode-jest`, configured to work with Vitest (requires setup, see below).
  - `eamodio.gitlens` for Git blame and enhanced Git capabilities.
  - Configured keyboard shortcuts:
    - **Command/Control + U**: Expand selection.
    - **Shift + Command/Control + U**: Contract selection.

---

## 🛠️ How to Build the Containers

To build the Docker images for each variant, use the `build.sh` script.

1. Navigate to the `docker` directory:
   ```bash
   cd docker
   ```

2. Build a specific variant. For example:
   ```bash
   ./build.sh python
   ./build.sh ts
   ```

This will create Docker images tagged as `jdcode-python` and `jdcode-ts`.

## 🌍 How to Use the Docker Containers

### Quick Start with Simplified Interface

We've created a simplified CLI tool to make running containers much easier:

1. Install jdcode CLI (run once):
   ```bash
   ./install-jdcode.sh
   ```

2. Run containers with minimal commands:
   ```bash
   jdcode python     # Run Python variant
   jdcode ts         # Run TypeScript variant
   ```

### Manual Docker Commands (Legacy)

If you prefer to run docker commands directly:

> Note: Binding ports in docker uses the -p flag in the form HOST_PORT:CONTAINER_PORT

#### Basic Usage

1. **Run the containers**:
   Start each environment by binding the appropriate port:
   - For Python:
     ```bash
     docker run -it --rm -v "$PWD":/code -v /etc/localtime:/etc/localtime:ro -p 8080:8080 jdcode-python
     ```
   - For TypeScript:
     ```bash
     docker run -it --rm -v "$PWD":/code -v /etc/localtime:/etc/localtime:ro -p 8080:8080 jdcode-ts
     ```

   > The `-v /etc/localtime:/etc/localtime:ro` mount syncs the container clock with your host timezone. Without it, the container defaults to UTC.

2. **Access the VSCode instance**:
   - Open your browser to `http://localhost:8080`

3. **Access OpenCode**
   - In your container, execute `opencode`

#### With Telegram Notifications

Both variants include a Telegram notification plugin that sends messages via a Telegram bot when OpenCode session events occur (idle, errors, completion).

**Prerequisites:**
- A Telegram bot created via [@BotFather](https://t.me/BotFather)
- Your bot token and chat ID (see `TELEGRAM_SETUP.md` for details)

**Run with Telegram notifications enabled:**

- For Python:
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

- For TypeScript:
  ```bash
  docker run -it --rm \
    -v "$PWD":/code \
    -v /etc/localtime:/etc/localtime:ro \
    -p 8080:8080 \
    -e TELEGRAM_ENABLED=true \
    -e TELEGRAM_BOT_TOKEN=your_bot_token \
    -e TELEGRAM_CHAT_ID=your_chat_id \
    jdcode-ts
  ```

**Using environment file:**
Create a `.env` file with your credentials:
```bash
TELEGRAM_ENABLED=true
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
```

Then run with:
```bash
docker run -it --rm -v "$PWD":/code -v /etc/localtime:/etc/localtime:ro -p 8080:8080 --env-file .env jdcode-ts
```

**Notification Events:**
- 🤖 Session idle notifications
- ❌ Session error alerts
- 🗑️ Session completion messages

See `.env.example` for a template configuration file.

---

## 🔗 Creating Aliases for Convenience

To avoid typing long docker commands, you can create shell aliases:

### Bash/Zsh

Add these lines to your `~/.bashrc` or `~/.zshrc`:

```bash
# Basic aliases
alias jdcode-python='docker run -it --rm -v "$PWD":/code -v /etc/localtime:/etc/localtime:ro -p 8080:8080 jdcode-python'
alias jdcode-ts='docker run -it --rm -v "$PWD":/code -v /etc/localtime:/etc/localtime:ro -p 8080:8080 jdcode-ts'

# With Telegram notifications (requires environment variables to be set)
alias jdcode-python-notify='docker run -it --rm -v "$PWD":/code -v /etc/localtime:/etc/localtime:ro -p 8080:8080 -e TELEGRAM_ENABLED=true -e TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN" -e TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID" jdcode-python'
alias jdcode-ts-notify='docker run -it --rm -v "$PWD":/code -v /etc/localtime:/etc/localtime:ro -p 8080:8080 -e TELEGRAM_ENABLED=true -e TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN" -e TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID" jdcode-ts'
```

Then reload your shell configuration:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Usage

After setting up the aliases, you can simply run:
```bash
# Basic usage
jdcode-python   # Start Python development environment
jdcode-ts       # Start TypeScript development environment

# With Telegram notifications (requires Telegram env vars)
jdcode-python-notify   # Python with Telegram notifications
jdcode-ts-notify       # TypeScript with Telegram notifications
```

### Advanced Usage with CLI Tool

If you've installed the jdcode CLI tool, you can also run:

```bash
# Basic usage
jdcode python      # Run Python variant
jdcode ts          # Run TypeScript variant

# With custom port
jdcode python --port 9000

# With Telegram notifications
jdcode python --telegram

# Using environment file
jdcode ts --env-file .env
```

---

## ⚙️ Notes for Testing Play Buttons with Vitest (for the TypeScript Variant)

The `ms-vscode.vscode-jest` extension can be made to work with Vitest:

1. Update your `package.json` to alias Jest commands to Vitest:
   ```json
   {
     "scripts": {
       "test": "vitest",
       "test:watch": "vitest --watch",
       "test:coverage": "vitest --coverage",
       "jest": "vitest",
       "jest:watch": "vitest --watch"
     }
   }
   ```

2. Configure VSCode to use the `npm test --` command for the play button (already in the `settings.json`):
   ```json
   {
     "jest.jestCommandLine": "npm test --"
   }
   ```

For more details, refer to the official [Vitest Documentation](https://vitest.dev/).
