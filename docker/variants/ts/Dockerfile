# TypeScript-specific Dockerfile

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
        bash-completion \
        curl \
        git \
        less \
        sudo \
        software-properties-common \
        tmux \
        tmuxinator \
        tzdata \
        vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add entrypoint script
COPY base/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set timezone to match host system
RUN ln -sf /etc/localtime /usr/local/etc/localtime

# ─────────────────────────────────────────────
# TypeScript-specific dependencies
# ─────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs python3 python3-pip && \
    npm install -g typescript && \
    pip3 install --break-system-packages rich && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────
# opencode global config
#   opencode resolves config from
#   ~/.config/opencode/opencode.json
# ─────────────────────────────────────────────
RUN mkdir -p /root/.config/opencode
COPY base/opencode.json /root/.config/opencode/opencode.json

# Copy opencode plugins to correct location
# Plugins must be in ~/.config/opencode/plugins/ (not .opencode subdirectory)
COPY base/.opencode/plugins /root/.config/opencode/plugins
COPY base/.opencode/package.json /root/.config/opencode/package.json



# ─────────────────────────────────────────────
# Configuration and extensions
# ─────────────────────────────────────────────

# Tmux / Tmuxinator config
COPY base/.tmux.conf /root/.tmux.conf
RUN mkdir -p /root/.config/tmuxinator
COPY base/tmuxinator/dev.yml /root/.config/tmuxinator/dev.yml

# Copy VERSION file and version check scripts
COPY VERSION /usr/local/share/VERSION
COPY base/check-version.sh /usr/local/bin/check-version.sh
RUN chmod +x /usr/local/bin/check-version.sh
COPY base/show-welcome.py /usr/local/bin/show-welcome.py
RUN chmod +x /usr/local/bin/show-welcome.py

# Copy shared settings
RUN mkdir -p /root/.local/share/code-server/User
COPY base/settings.json /root/.local/share/code-server/User/settings.json
COPY base/keybindings.json /root/.local/share/code-server/User/keybindings.json

# Copy git prompt configuration
COPY base/git-prompt.sh /etc/profile.d/git-prompt.sh
RUN chmod +x /etc/profile.d/git-prompt.sh

# Copy .bashrc so non-login shells (tmux panes, code-server terminals) source the git prompt
COPY base/.bashrc /root/.bashrc

# Copy TypeScript-specific VSCode extensions
COPY variants/ts/extensions.json /root/.vscode/extensions.json

# Install TypeScript-related extensions
RUN code-server --install-extension esbenp.prettier-vscode && \
    code-server --install-extension dbaeumer.vscode-eslint && \
    code-server --install-extension ms-vscode.vscode-typescript-tslint-plugin

# ─────────────────────────────────────────────
# Install opencode
# ─────────────────────────────────────────────
RUN curl -fsSL https://opencode.ai/install | bash

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

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

