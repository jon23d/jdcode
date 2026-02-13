# syntax=docker/dockerfile:1

# ─────────────────────────────────────────────
# Base: Python (slim Debian – small footprint)
# ─────────────────────────────────────────────
FROM python:3.12-slim

# ─────────────────────────────────────────────
# System dependencies
#   curl    – download the opencode install script
#   git     – opencode uses git for project context
#   unzip   – required by the install script
#   procps  – provides pgrep for process checking
# ─────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        unzip \
        ca-certificates \
        procps && \
    rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────
# Install opencode
#   The official install script places the binary
#   in $HOME/.opencode/bin by default.
#   We override OPENCODE_INSTALL_DIR so the binary
#   lands in /usr/local/bin and is on PATH for all
#   users without any extra configuration.
# ─────────────────────────────────────────────
RUN OPENCODE_INSTALL_DIR=/usr/local/bin \
    curl -fsSL https://opencode.ai/install | bash

# ─────────────────────────────────────────────
# opencode global config
#   opencode resolves config from
#   ~/.config/opencode/opencode.json
# ─────────────────────────────────────────────
RUN mkdir -p /root/.config/opencode
COPY docker/base/opencode.json /root/.config/opencode/opencode.json

# ─────────────────────────────────────────────
# Copy entrypoint script
# ─────────────────────────────────────────────
COPY docker/base/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ─────────────────────────────────────────────
# Copy diagnostic script
# ─────────────────────────────────────────────
COPY diagnose.sh /usr/local/bin/diagnose
RUN chmod +x /usr/local/bin/diagnose

# ─────────────────────────────────────────────
# Install code-server (VS Code in the browser)
# ─────────────────────────────────────────────
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ─────────────────────────────────────────────
# Environment for code-server
#   PASSWORD – optional password for authentication
#   PORT     – port to serve VS Code (default: 8080)
# ─────────────────────────────────────────────
ENV PORT=8080
ENV PASSWORD=

# ─────────────────────────────────────────────
# Expose VS Code port
# ─────────────────────────────────────────────
EXPOSE 8080

# ─────────────────────────────────────────────
# Working directory – bind-mount your project
# here at runtime:
#   docker run -v "$PWD":/code -p 8080:8080 ...
# ─────────────────────────────────────────────
WORKDIR /code

# ─────────────────────────────────────────────
# Run entrypoint script that:
#   - Starts code-server in background
#   - Shows welcome message
#   - Drops to bash prompt
# ─────────────────────────────────────────────
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
