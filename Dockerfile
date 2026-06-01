FROM node:20-slim

# Install system dependencies + build tools (dibutuhkan node-pty dari claude-code-web)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    ca-certificates \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI dan claude-code-web
RUN npm install -g \
    @anthropic-ai/claude-code \
    claude-code-web

# Buat workspace directory
RUN mkdir -p /workspace
WORKDIR /workspace

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 32352

CMD ["/start.sh"]
