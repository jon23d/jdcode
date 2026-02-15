#!/usr/bin/env python3
"""
Welcome Message Display Script
Shows welcome message with dynamic version info using Rich formatting
"""

import os
import subprocess
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text

# Configuration
LOCAL_VERSION_FILE = "/usr/local/share/VERSION"
VERSION_CHECK_SCRIPT = "/usr/local/bin/check-version.sh"


def get_local_version():
    """Read the local version from file."""
    version_path = Path(LOCAL_VERSION_FILE)
    if version_path.exists():
        return version_path.read_text().strip()
    return "unknown"


def get_version_status():
    """Get version status from check script if available."""
    check_script = Path(VERSION_CHECK_SCRIPT)
    if (
        check_script.exists()
        and check_script.is_file()
        and os.access(check_script, os.X_OK)
    ):
        try:
            result = subprocess.run(
                [str(check_script)], capture_output=True, text=True, timeout=5
            )
            return result.stdout.strip()
        except (subprocess.SubprocessError, subprocess.TimeoutExpired):
            return ""
    return ""


def get_telegram_status():
    """Check if Telegram notifications are enabled."""
    telegram_enabled = os.environ.get("TELEGRAM_ENABLED", "").lower() == "true"
    if telegram_enabled:
        return "🔔", "ENABLED", "green"
    return "📵", "DISABLED", "dim"


def create_welcome_message():
    """Create and display the welcome message."""
    console = Console()

    # Get dynamic information
    local_version = get_local_version()
    version_status = get_version_status()
    telegram_icon, telegram_status, telegram_color = get_telegram_status()
    port = os.environ.get("PORT", "8080")

    # Build version text
    version_text = f"Version: {local_version}"
    if version_status:
        version_text += f" {version_status}"

    # Create the main content
    content = Text()

    # Version info
    content.append(f"{version_text}\n", style="cyan")

    # Telegram status
    content.append(f"{telegram_icon} Telegram notifications: ", style="white")
    content.append(f"{telegram_status}\n\n", style=telegram_color)

    # Mouse mode
    content.append("Mouse mode is ENABLED", style="bold green")
    content.append(" - click to switch panes & scroll\n\n", style="white")

    # Navigation section
    content.append("Navigation:\n", style="bold yellow")
    content.append("  • Switch panes: ", style="white")
    content.append("Ctrl+b + arrow keys", style="cyan")
    content.append(" OR click with mouse\n", style="white")
    content.append("  • Resize panes: ", style="white")
    content.append("Ctrl+b + hold Ctrl + arrow keys\n", style="cyan")
    content.append(
        "                  OR drag pane borders with mouse\n\n", style="white"
    )

    # OpenCode section
    content.append("OpenCode (top pane):\n", style="bold yellow")
    content.append("  • AI-powered coding assistant\n", style="white")
    content.append("  • Type commands or ask questions\n", style="white")
    content.append("  • ", style="white")
    content.append("Ctrl+p", style="cyan")
    content.append(" to list available actions\n", style="white")
    content.append("  • Copying to clipboard: ", style="white")
    content.append(
        "Option or fn + drag to select text, command-c to copy\n\n",
        style="yellow"
    )

    # Access section
    content.append("Access:\n", style="bold yellow")
    content.append("  • VS Code web UI: ", style="white")
    content.append(f"http://localhost:{port}\n\n", style="blue underline")

    # Resources section
    content.append("Resources:\n", style="bold yellow")
    content.append("  • Tmux cheat sheet: ", style="white")
    content.append("https://tmuxcheatsheet.com", style="blue underline")

    # Create and display the panel
    panel = Panel(
        content,
        title="[bold white]Welcome to JDCode[/bold white]",
        border_style="bright_blue",
        padding=(1, 2),
    )

    console.print(panel)


if __name__ == "__main__":
    create_welcome_message()
