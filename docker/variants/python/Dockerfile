# Python-specific Dockerfile

# ─────────────────────────────────────────────
# Base: code-server
# ─────────────────────────────────────────────
FROM codercom/code-server:latest

# ─────────────────────────────────────────────
# Base system dependencies
# ─────────────────────────────────────────────
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        less \
        sudo \
        software-properties-common \
        tmux \
        tmuxinator \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add entrypoint script
COPY base/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ─────────────────────────────────────────────
# Python-specific dependencies
# ─────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
    && pip3 install --break-system-packages --upgrade pip flake8 autopep8 mypy uv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
COPY base/opencode.json /root/.config/opencode/opencode.json


# ─────────────────────────────────────────────
# Configuration and extensions
# ─────────────────────────────────────────────

# Tmux / Tmuxinator config
COPY base/.tmux.conf /root/.tmux.conf
RUN mkdir -p /root/.config/tmuxinator
COPY base/tmuxinator/dev.yml /root/.config/tmuxinator/dev.yml
COPY base/welcome.txt /usr/local/share/welcome.txt

# Copy shared settings
RUN mkdir -p /root/.local/share/code-server/User
COPY base/settings.json /root/.local/share/code-server/User/settings.json
COPY base/keybindings.json /root/.local/share/code-server/User/keybindings.json

# Copy Python-specific VSCode extensions
COPY variants/python/extensions.json /root/.vscode/extensions.json

# Install Python-related extensions
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension njpwerner.autodocstring && \
    code-server --install-extension kevinrose.vsc-python-indent

# ─────────────────────────────────────────────
# Environment for code-server
#   PASSWORD – optional password for authentication
#   PORT     – port to serve VS Code (default: 8080)
# ─────────────────────────────────────────────
ENV PORT=8080

# ─────────────────────────────────────────────
# Expose and configure
# ─────────────────────────────────────────────
EXPOSE 8080

# ─────────────────────────────────────────────
# Working directory – bind-mount your project
# here at runtime:
#   docker run -v "$PWD":/code -p 8080:8080 ...
# ─────────────────────────────────────────────
WORKDIR /code

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
