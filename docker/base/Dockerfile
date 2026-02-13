# Base Dockerfile for all VSCode container variants

FROM codercom/code-server:latest

# Install common utils and set default environment variables
USER root
RUN apt-get update && apt-get install -y \
    curl \
    git \
    less \
    sudo \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add a non-root user
RUN adduser --gecos '' --disabled-password vscode-user \
    && echo 'vscode-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/nopasswd

USER coder

# Expose the VSCode Server default port
EXPOSE 8080

# Copy shared extensions file (optional, can be replaced by specific variants)
COPY settings.json /home/coder/.config/code-server/settings.json

# Set the entrypoint
ENTRYPOINT ["/usr/bin/dumb-init", "/usr/bin/code-server"]