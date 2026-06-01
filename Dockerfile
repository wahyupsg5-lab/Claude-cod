FROM node:20-slim

# Install system dependencies + build tools
RUN apt-get update && apt-get install -y \
    git curl wget unzip ca-certificates \
    python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install code-server (VS Code di browser) + Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code \
    && curl -fsSL https://code-server.dev/install.sh | sh

RUN mkdir -p /workspace /root/.claude/projects

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
