#!/bin/bash
# set -e DIHAPUS — biar script tidak mati karena warning/non-zero exit kecil

echo "============================================"
echo "  Claude Code Railway - Starting Up..."
echo "============================================"

# ── 1. Validasi environment variables ──────────────────────────────────────
MISSING=""

if [ -z "$ANTHROPIC_API_KEY" ]; then
    MISSING="$MISSING ANTHROPIC_API_KEY"
fi
if [ -z "$GH_TOKEN" ]; then
    MISSING="$MISSING GH_TOKEN"
fi
if [ -z "$WEB_PASSWORD" ]; then
    MISSING="$MISSING WEB_PASSWORD"
fi

if [ -n "$MISSING" ]; then
    echo "❌ ERROR: Variable berikut belum di-set:$MISSING"
    echo "   Set dulu di Railway → Variables tab"
    exit 1
fi

echo "✅ Semua required env vars tersedia"

# ── 2. Setup Git identity ───────────────────────────────────────────────────
if [ -n "$GITHUB_NAME" ]; then
    git config --global user.name "$GITHUB_NAME"
    echo "✅ Git name: $GITHUB_NAME"
fi

if [ -n "$GITHUB_EMAIL" ]; then
    git config --global user.email "$GITHUB_EMAIL"
    echo "✅ Git email: $GITHUB_EMAIL"
fi

git config --global --add safe.directory '*'

# ── 3. Auth GitHub CLI ──────────────────────────────────────────────────────
echo "→ Authenticating GitHub CLI..."
echo "$GH_TOKEN" | gh auth login --with-token
GH_EXIT=$?

if [ $GH_EXIT -eq 0 ]; then
    echo "✅ GitHub CLI authenticated"
else
    echo "⚠️  GitHub CLI auth exit code: $GH_EXIT (lanjut tetap...)"
fi

# ── 4. Export Anthropic API Key ─────────────────────────────────────────────
export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
echo "✅ Anthropic API Key loaded"

# ── 5. Setup persistent storage (jika Railway Volume di-mount) ──────────────
if [ -d "/data" ]; then
    echo "✅ Volume /data ditemukan — menggunakan persistent storage"

    mkdir -p /data/.claude
    if [ ! -L "$HOME/.claude" ]; then
        ln -sf /data/.claude "$HOME/.claude"
    fi

    mkdir -p /data/workspace
    if [ ! -L "/workspace" ]; then
        rm -rf /workspace
        ln -sf /data/workspace /workspace
    fi

    echo "✅ Persistent storage siap"
else
    echo "⚠️  Volume /data tidak ditemukan — data hilang saat redeploy"
fi

# ── 6. Info startup ─────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  🚀 Menjalankan Claude Code Web..."
echo "  📂 Workspace: /workspace"
echo "  🌐 Port: 32352"
echo "  🔑 Password protected: YES"
echo "============================================"
echo ""

# ── 7. Jalankan claude-code-web ─────────────────────────────────────────────
npx claude-code-web \
    --port 32352 \
    --auth "$WEB_PASSWORD" \
    --no-open

# Jika npx exit (crash), print error dan tunggu biar log kebaca
EXIT_CODE=$?
echo "❌ claude-code-web berhenti dengan exit code: $EXIT_CODE"
echo "   Cek log di atas untuk detail error"
sleep 30
exit $EXIT_CODE
