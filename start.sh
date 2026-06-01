#!/bin/bash

echo "============================================"
echo "  Claude Code Railway (VS Code / code-server)"
echo "============================================"

# ── 1. Validasi env vars ───────────────────────────────────────────────────
MISSING=""
[ -z "$ANTHROPIC_API_KEY" ] && MISSING="$MISSING ANTHROPIC_API_KEY"
[ -z "$GH_TOKEN" ]          && MISSING="$MISSING GH_TOKEN"
[ -z "$WEB_PASSWORD" ]      && MISSING="$MISSING WEB_PASSWORD"

if [ -n "$MISSING" ]; then
    echo "❌ ERROR: Variable belum di-set:$MISSING"
    exit 1
fi

APP_PORT="${PORT:-8080}"
echo "✅ Port: $APP_PORT"

# ── 2. Git identity ────────────────────────────────────────────────────────
[ -n "$GITHUB_NAME" ]  && git config --global user.name  "$GITHUB_NAME"
[ -n "$GITHUB_EMAIL" ] && git config --global user.email "$GITHUB_EMAIL"
git config --global --add safe.directory '*'
echo "✅ Git OK"

# ── 3. GitHub CLI auth ─────────────────────────────────────────────────────
echo "$GH_TOKEN" | gh auth login --with-token
echo "✅ GitHub auth done"

# ── 4. Persistent storage ──────────────────────────────────────────────────
if [ -d "/data" ]; then
    mkdir -p /data/.claude/projects /data/workspace /data/.config
    [ ! -L "/root/.claude" ] && rm -rf /root/.claude && ln -sf /data/.claude /root/.claude
    [ ! -L "/workspace" ]    && rm -rf /workspace    && ln -sf /data/workspace /workspace
    [ ! -L "/root/.config" ] && rm -rf /root/.config && ln -sf /data/.config /root/.config
    echo "✅ Persistent storage OK"
else
    mkdir -p /root/.claude/projects
    echo "⚠️  Tidak ada /data volume"
fi

# ── 5. Set env vars untuk sesi terminal di VS Code ─────────────────────────
export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
export PASSWORD="$WEB_PASSWORD"   # code-server baca dari sini
echo "export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"" >> /root/.bashrc

# ── 6. Jalankan code-server (VS Code di browser) ───────────────────────────
echo ""
echo "🚀 VS Code berjalan di port $APP_PORT"
echo "   Buka domain Railway → masukkan password"
echo "   Lalu buka Terminal → ketik: claude"
echo ""

exec code-server \
    --bind-addr "0.0.0.0:$APP_PORT" \
    --auth password \
    --disable-telemetry \
    /workspace
