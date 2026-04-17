# Igisubizo Muhinzi - Deployment Guide

## Project Structure

```
repo root/
├── backend/            ← FastAPI app
│   ├── app/
│   ├── Procfile
│   ├── Dockerfile
│   └── requirements.txt
├── models/             ← ML model files (~53MB, committed to git)
│   ├── crop_model_seasonal.pkl
│   └── encoders_seasonal.pkl
├── frontend/           ← Flutter app
├── render.yaml         ← Render Blueprint config
└── requirements.txt
```

> **Key point**: `models/` is at the repo root, not inside `backend/`. Any deployment platform must clone the full repo so the backend can access `../models/` at runtime.

---

## Backend + Models on Render

### Why Render?
- Free tier with automatic HTTPS
- Auto-deploy on every `git push`
- Frankfurt region (close to Rwanda)
- Simple env var management

### How the paths work

`backend/app/core/config.py` calculates `BASE_DIR` as the repo root (4 levels up from `config.py`). So on Render, the model paths resolve to:
```
/repo-root/models/crop_model_seasonal.pkl
/repo-root/models/encoders_seasonal.pkl
```

This is why **Root Directory must be empty** (repo root) in Render — not `backend/`.

### Deployment via Blueprint (Recommended)

The `render.yaml` at the repo root configures everything automatically:

1. Sign in at https://render.com/
2. **New +** → **Blueprint**
3. Connect your GitHub repository
4. Add the secret when prompted: `GROQ_API_KEY`
5. Click **Apply**

### Deployment via Manual Setup

1. **New +** → **Web Service** → Connect GitHub repo
2. Settings:

| Field | Value |
|-------|-------|
| Root Directory | *(empty — repo root)* |
| Runtime | Python 3 |
| Build Command | `pip install -r backend/requirements.txt` |
| Start Command | `cd backend && uvicorn app.main:app --host 0.0.0.0 --port $PORT` |
| Region | Frankfurt |
| Instance Type | Free |

3. Environment Variables:
```
ENVIRONMENT=production
PROJECT_NAME=Igisubizo Muhinzi API
VERSION=1.0.0
API_HOST=0.0.0.0
BACKEND_CORS_ORIGINS=*
LOG_LEVEL=INFO
LOG_FORMAT=json
MODEL_PATH=models/crop_model_seasonal.pkl
ENCODER_PATH=models/encoders_seasonal.pkl
CONFIDENCE_THRESHOLD=0.3
RATE_LIMIT_PER_MINUTE=100
GROQ_API_KEY=your-groq-api-key-here
REQUEST_TIMEOUT_SECONDS=30
MAX_REQUEST_SIZE_KB=10
```

4. Click **Create Web Service**

### Verify
```bash
curl https://igisubizo-muhinzi-api.onrender.com/api/v1/health

curl -X POST https://igisubizo-muhinzi-api.onrender.com/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "province": "Kigali City",
    "district": "Gasabo",
    "season": "Season A",
    "slope": "No",
    "seeds": "Improved seeds",
    "inorganic_fert": 1,
    "organic_fert": 1,
    "used_lime": 0
  }'
```

### Free Tier — Prevent Sleep

Free tier sleeps after 15 min of inactivity. Set up UptimeRobot:
- URL: `https://igisubizo-muhinzi-api.onrender.com/api/v1/health`
- Interval: 5 minutes
- This keeps the service awake at no cost

For production (no sleep): upgrade to Render Starter ($7/month).

---

## Alternative Backend — Railway

1. https://railway.app/ → **New Project** → **Deploy from GitHub**
2. Root directory: *(empty — repo root)*
3. Build: `pip install -r backend/requirements.txt`
4. Start: `cd backend && uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Add same environment variables

---

## Alternative Backend — Docker

Build from repo root (so Docker can access both `backend/` and `models/`):

```bash
# From repo root
docker build -f backend/Dockerfile -t igisubizo-api .
docker run -p 8000:8000 --env-file backend/.env igisubizo-api
```

---

## Frontend Deployment

### Update API URL

After backend is live, update `frontend/lib/core/network/api_client.dart`:
```dart
static const String baseUrl = kIsWeb
    ? 'https://igisubizo-muhinzi-api.onrender.com/api/v1'
    : 'https://igisubizo-muhinzi-api.onrender.com/api/v1';
```

### Build Android

```bash
cd frontend
flutter build apk --release          # APK for direct install
flutter build appbundle --release    # AAB for Play Store
```

### Build iOS

```bash
cd frontend
flutter build ios --release
# Then archive in Xcode: Product → Archive → Distribute
```

### Distribution Options

| Method | Cost | Steps |
|--------|------|-------|
| GitHub Releases | Free | `gh release create v1.0.0 app-release.apk` |
| Firebase App Distribution | Free | Upload via Firebase CLI |
| Google Play Store | $25 one-time | Upload AAB to Play Console |
| Apple App Store | $99/year | Archive in Xcode → App Store Connect |

---

## Security Checklist

- [ ] Set your own `GROQ_API_KEY` in Render (never commit it)
- [ ] Change `BACKEND_CORS_ORIGINS` to your app domain in production
- [ ] HTTPS is automatic on Render
- [ ] Enable `API_KEY_SECRET` for production API auth
- [ ] Flutter build with obfuscation: `flutter build apk --obfuscate --split-debug-info=build/debug`

---

## Deployment Checklist

- [ ] `models/*.pkl` files committed to git (`git ls-files models/`)
- [ ] `GROQ_API_KEY` obtained from https://console.groq.com/
- [ ] Backend deployed to Render (root = repo root, not `backend/`)
- [ ] Health endpoint returns 200
- [ ] Frontend API URL updated to Render URL
- [ ] Flutter app builds and connects to production backend
- [ ] UptimeRobot configured to prevent sleep

---

## Cost Summary

| Service | Free Tier | Paid |
|---------|-----------|------|
| Render Backend | $0 (sleeps) | $7/month (always on) |
| GitHub | $0 | — |
| Groq API | $0 | Pay per use |
| Google Play | — | $25 one-time |
| Apple App Store | — | $99/year |
