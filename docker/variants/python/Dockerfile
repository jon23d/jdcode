# Python-specific Dockerfile

# ─────────────────────────────────────────────
# Base: code-server
# ─────────────────────────────────────────────
FROM codercom/code-server:latest

# Switch to root for system-level operations
USER root

# ─────────────────────────────────────────────
# Base system dependencies
# ─────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash-completion \
        curl \
        git \
        less \
        software-properties-common \
        tmux \
        tmuxinator \
        tzdata \
        podman \
        podman-compose \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────
# Python-specific dependencies
# ─────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
    && pip3 install --break-system-packages --upgrade pip flake8 autopep8 mypy uv rich \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────
# Install Node.js for opencode plugin runtime
# ─────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────
# Configure for existing user (base image already has a user)
# ─────────────────────────────────────────────
RUN mkdir -p /run/user/1000 && \
    chown 1000:1000 /run/user/1000

# Set timezone to match host system
RUN ln -sf /etc/localtime /usr/local/etc/localtime

# ─────────────────────────────────────────────
# Configure paths for user (using UID 1000 from base image)
# ─────────────────────────────────────────────
RUN mkdir -p /home/coder/.config/opencode /home/coder/.local/share/code-server/User /home/coder/.vscode

# ─────────────────────────────────────────────
# opencode global config
#   opencode resolves config from
#   ~/.config/opencode/opencode.json
# ─────────────────────────────────────────────
COPY base/opencode.json /home/coder/.config/opencode/opencode.json

# Copy opencode plugins to correct location
# Plugins must be in ~/.config/opencode/plugins/ (not .opencode subdirectory)
COPY base/.opencode/plugins /home/coder/.config/opencode/plugins/
COPY base/.opencode/package.json /home/coder/.config/opencode/package.json

# ─────────────────────────────────────────────
# Configuration and extensions
# ─────────────────────────────────────────────

# Tmux / Tmuxinator config
COPY base/.tmux.conf /home/coder/.tmux.conf
RUN mkdir -p /home/coder/.config/tmuxinator
COPY base/tmuxinator/dev.yml /home/coder/.config/tmuxinator/dev.yml

# Copy VERSION file and version check scripts
COPY VERSION /usr/local/share/VERSION
COPY base/check-version.sh /usr/local/bin/check-version.sh
RUN chmod +x /usr/local/bin/check-version.sh
COPY base/show-welcome.py /usr/local/bin/show-welcome.py
RUN chmod +x /usr/local/bin/show-welcome.py

# Copy shared settings
COPY base/settings.json /home/coder/.local/share/code-server/User/settings.json
COPY base/keybindings.json /home/coder/.local/share/code-server/User/keybindings.json

# Copy git prompt configuration
COPY base/git-prompt.sh /etc/profile.d/git-prompt.sh
RUN chmod +x /etc/profile.d/git-prompt.sh

# Copy Python-specific VSCode extensions
COPY variants/python/extensions.json /home/coder/.vscode/extensions.json

# Set ownership of all user files
RUN chown -R 1000:1000 /home/coder

# Install Python-related extensions
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension njpwerner.autodocstring && \
    code-server --install-extension kevinrose.vsc-python-indent

# Copy entrypoint script
COPY base/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

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
# Switch to dev user for runtime
# ─────────────────────────────────────────────
USER coder

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
# Working directory – bind-mount your project
# here at runtime:
#   podman run -v "$PWD":/code -p 8080:8080 ...
# ─────────────────────────────────────────────
WORKDIR /code

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
