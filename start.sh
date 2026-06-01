#!/bin/bash

echo "============================================"
echo "  Claude Code Railway - Starting Up..."
echo "============================================"

# ── 1. Validasi environment variables ──────────────────────────────────────
MISSING=""
[ -z "$ANTHROPIC_API_KEY" ] && MISSING="$MISSING ANTHROPIC_API_KEY"
[ -z "$GH_TOKEN" ]          && MISSING="$MISSING GH_TOKEN"
[ -z "$WEB_PASSWORD" ]      && MISSING="$MISSING WEB_PASSWORD"

if [ -n "$MISSING" ]; then
    echo "❌ ERROR: Variable belum di-set:$MISSING"
    exit 1
fi

echo "✅ Env vars OK"

# ── 2. Gunakan PORT dari Railway ────────────────────────────────────────────
APP_PORT="${PORT:-3000}"
echo "✅ Port: $APP_PORT"

# ── 3. Setup Git identity ──────────────────────────────────────────────────
[ -n "$GITHUB_NAME" ]  && git config --global user.name  "$GITHUB_NAME"
[ -n "$GITHUB_EMAIL" ] && git config --global user.email "$GITHUB_EMAIL"
git config --global --add safe.directory '*'
echo "✅ Git config OK"

# ── 4. Pre-create .claude dirs (biar usage reader tidak spam ENOENT error) ──
mkdir -p /root/.claude/projects
echo "✅ Claude dirs OK"

# ── 5. Auth GitHub CLI ─────────────────────────────────────────────────────
echo "$GH_TOKEN" | gh auth login --with-token
echo "✅ GitHub auth done"

# ── 6. Persistent storage ──────────────────────────────────────────────────
if [ -d "/data" ]; then
    mkdir -p /data/.claude/projects /data/workspace
    if [ ! -L "/root/.claude" ]; then
        rm -rf /root/.claude
        ln -sf /data/.claude /root/.claude
    fi
    if [ ! -L "/workspace" ]; then
        rm -rf /workspace
        ln -sf /data/workspace /workspace
    fi
    echo "✅ Persistent storage OK"
else
    echo "⚠️  Tidak ada volume /data — data hilang saat redeploy"
fi

# ── 7. Launch ──────────────────────────────────────────────────────────────
echo ""
echo "🚀 Starting claude-code-web on port $APP_PORT..."
echo ""

npx claude-code-web \
    --port "$APP_PORT" \
    --auth "$WEB_PASSWORD" \
    --no-open

EXIT_CODE=$?
echo "❌ claude-code-web exit: $EXIT_CODE"
sleep 30
exit $EXIT_CODE
