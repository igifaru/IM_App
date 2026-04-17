# Quick Deployment Guide - Igisubizo Muhinzi

## Deployment Stack

| Layer | Platform | URL |
|-------|----------|-----|
| Backend + Models | Render | `https://igisubizo-muhinzi-api.onrender.com` |
| Frontend (Web) | Vercel | `https://igisubizo-muhinzi.vercel.app` |
| Mobile (Android) | GitHub Releases / Play Store | APK / AAB |

## Prerequisites
- GitHub account with this repo pushed
- Render account (free): https://render.com/
- Vercel account (free): https://vercel.com/
- Groq API key (free): https://console.groq.com/

---

## Project Structure

```
repo root/
├── backend/        ← FastAPI app (deployed to Render)
├── models/         ← ML model files (deployed with backend on Render)
├── frontend/       ← Flutter app (web → Vercel, mobile → APK)
│   └── vercel.json ← Vercel build config
└── render.yaml     ← Render build config
```

---

## Step 1: Deploy Backend + Models to Render

### Option A — Blueprint (uses render.yaml automatically)

1. Go to https://render.com/ → **New +** → **Blueprint**
2. Connect your GitHub repository
3. Add the secret: `GROQ_API_KEY` → your key
4. Click **Apply**

### Option B — Manual

1. **New +** → **Web Service** → Connect GitHub repo
2. Settings:

| Field | Value |
|-------|-------|
| Root Directory | *(leave empty — repo root)* |
| Runtime | Python 3 |
| Build Command | `pip install -r backend/requirements.txt` |
| Start Command | `cd backend && uvicorn app.main:app --host 0.0.0.0 --port $PORT` |
| Region | Frankfurt |
| Instance Type | Free |

3. Environment Variables:
```
ENVIRONMENT=production
BACKEND_CORS_ORIGINS=*
LOG_LEVEL=INFO
MODEL_PATH=models/crop_model_seasonal.pkl
ENCODER_PATH=models/encoders_seasonal.pkl
CONFIDENCE_THRESHOLD=0.3
RATE_LIMIT_PER_MINUTE=100
GROQ_API_KEY=your-groq-api-key-here
REQUEST_TIMEOUT_SECONDS=30
MAX_REQUEST_SIZE_KB=10
```

4. Click **Create Web Service**

**Test:**
```bash
curl https://igisubizo-muhinzi-api.onrender.com/api/v1/health
```

> Free tier sleeps after 15 min. Use UptimeRobot to ping every 5 min.

---

## Step 2: Deploy Frontend to Vercel

The `frontend/vercel.json` already configures the build. It:
- Installs Flutter
- Builds the web app pointing to your Render backend
- Serves as a single-page app

### Deploy

1. Go to https://vercel.com/ → **Add New Project**
2. Import your GitHub repository
3. Set **Root Directory** to `frontend`
4. Vercel auto-reads `vercel.json` — no other config needed
5. Click **Deploy**

Your web app will be live at:
```
https://igisubizo-muhinzi.vercel.app
```

### Update CORS for Vercel domain

In Render, update the `BACKEND_CORS_ORIGINS` env var:
```
BACKEND_CORS_ORIGINS=https://igisubizo-muhinzi.vercel.app
```

---

## Step 3: Build Android APK (Mobile)

```bash
cd frontend
flutter build apk --release \
  --dart-define=API_URL=https://igisubizo-muhinzi-api.onrender.com/api/v1
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Distribute via GitHub Releases:
```bash
gh release create v1.0.0 \
  frontend/build/app/outputs/flutter-apk/app-release.apk \
  --title "Igisubizo Muhinzi v1.0.0"
```

---

## Troubleshooting

**Model not found on Render**
- Root Directory must be **empty** (repo root), not `backend`
- Verify models are committed: `git ls-files models/`

**Vercel build fails (Flutter not found)**
- Vercel installs Flutter during build via `vercel.json` — no manual setup needed
- Check build logs in Vercel dashboard

**CORS errors on Vercel**
- Update `BACKEND_CORS_ORIGINS` in Render to include your Vercel domain

**API not reachable from app**
- Render free tier may be sleeping — first request takes ~30s
- Set up UptimeRobot to keep it awake

---

## Cost Summary

| Service | Cost |
|---------|------|
| Render (free) | $0/month (sleeps after inactivity) |
| Render (Starter) | $7/month (always on) |
| Vercel (free) | $0/month |
| Groq API | $0/month |
| **Total** | **$0/month** |
