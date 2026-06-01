#!/bin/bash
set -e

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

# ── 2. Setup Git identity ───────────────────────────────────────────────────
if [ -n "$GITHUB_NAME" ]; then
    git config --global user.name "$GITHUB_NAME"
    echo "✅ Git name: $GITHUB_NAME"
fi

if [ -n "$GITHUB_EMAIL" ]; then
    git config --global user.email "$GITHUB_EMAIL"
    echo "✅ Git email: $GITHUB_EMAIL"
fi

# Safe directory biar git gak complain
git config --global --add safe.directory '*'

# ── 3. Auth GitHub CLI ──────────────────────────────────────────────────────
echo "$GH_TOKEN" | gh auth login --with-token 2>&1
if [ $? -eq 0 ]; then
    echo "✅ GitHub CLI authenticated"
    gh auth status
else
    echo "⚠️  GitHub CLI auth gagal — cek GH_TOKEN kamu"
fi

# ── 4. Export Anthropic API Key ─────────────────────────────────────────────
export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
echo "✅ Anthropic API Key loaded"

# ── 5. Setup persistent storage (jika Railway Volume di-mount) ──────────────
if [ -d "/data" ]; then
    echo "✅ Volume /data ditemukan — menggunakan persistent storage"
    
    # Symlink .claude config ke volume biar auth tetap ada
    if [ ! -d "/data/.claude" ]; then
        mkdir -p /data/.claude
    fi
    if [ ! -L "$HOME/.claude" ]; then
        ln -sf /data/.claude "$HOME/.claude"
    fi

    # Symlink workspace ke volume
    if [ ! -d "/data/workspace" ]; then
        mkdir -p /data/workspace
    fi
    if [ ! -L "/workspace" ]; then
        rm -rf /workspace
        ln -sf /data/workspace /workspace
    fi

    echo "✅ Persistent storage siap di /data"
else
    echo "⚠️  Volume /data tidak ditemukan — data HILANG saat redeploy"
    echo "   Tambahkan Railway Volume di: Settings → Volumes → Mount path: /data"
fi

# ── 6. Info startup ─────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  🚀 Menjalankan Claude Code Web..."
echo "  📂 Workspace: /workspace"
echo "  🌐 Port: 32352"
echo "  🔑 Password: [dari WEB_PASSWORD env var]"
echo "============================================"
echo ""

# ── 7. Jalankan claude-code-web ─────────────────────────────────────────────
exec npx claude-code-web \
    --port 32352 \
    --auth "$WEB_PASSWORD" \
    --no-open
