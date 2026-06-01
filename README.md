# Claude Code Railway

Jalankan **Claude Code** di Railway dan akses lewat browser dengan password protection.

---

## 🚀 Deploy ke Railway

### Langkah 1 — Push ke GitHub

```bash
git init
git add .
git commit -m "Claude Code Railway setup"
git remote add origin https://github.com/USERNAME/claude-code-railway.git
git push -u origin main
```

### Langkah 2 — Buat Project di Railway

1. Buka [railway.app](https://railway.app) → **New Project**
2. Pilih **Deploy from GitHub repo**
3. Pilih repo ini

### Langkah 3 — Set Environment Variables

Di Railway → tab **Variables**, tambahkan:

| Variable | Keterangan | Contoh |
|---|---|---|
| `ANTHROPIC_API_KEY` | API key dari [console.anthropic.com](https://console.anthropic.com) | `sk-ant-...` |
| `GH_TOKEN` | GitHub Personal Access Token (scope: repo, read:org) | `ghp_...` |
| `WEB_PASSWORD` | Password untuk akses web UI | `rahasia123` |
| `GITHUB_NAME` | Nama untuk git commit | `Wahyu` |
| `GITHUB_EMAIL` | Email untuk git commit | `wahyu@email.com` |

### Langkah 4 — Generate GitHub Token

1. GitHub → **Settings** → **Developer settings**
2. **Personal access tokens** → **Tokens (classic)**
3. Generate token dengan scope: `repo`, `read:org`, `workflow`

### Langkah 5 — Set Domain & Akses

1. Railway → tab **Settings** → **Networking**
2. Klik **Generate Domain** → dapat URL seperti `xxx.railway.app`
3. Buka URL tersebut di browser
4. Masukkan password (dari `WEB_PASSWORD`)
5. ✅ Claude Code siap dipakai!

---

## 💾 Persistent Storage (Recommended)

Biar data tidak hilang saat redeploy:

1. Railway → **New** → **Volume**
2. Mount path: `/data`
3. Start script otomatis mendeteksi dan menggunakan volume ini

---

## 📁 Struktur Project

```
/workspace/        ← Tempat clone repo & kerja
/data/             ← Persistent volume (opsional)
  ├── .claude/     ← Claude Code auth & config
  └── workspace/   ← Project files (persisted)
```

---

## ⚠️ Catatan

- Data **hilang** saat redeploy jika tidak pasang Volume
- Gunakan password yang kuat untuk `WEB_PASSWORD`
- Jangan commit `.env` atau API key ke GitHub
