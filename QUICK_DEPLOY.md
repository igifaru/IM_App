# 🚀 Quick Deployment Guide - Igisubizo Muhinzi

## ⚡ 15-Minute Deployment

### Prerequisites
- GitHub account
- Koyeb account (free): https://app.koyeb.com/
- Groq API key (free): https://console.groq.com/
- Flutter SDK installed (for mobile app)

---

## Step 1: Deploy Backend to Koyeb (5 minutes)

### 1.1 Push Code to GitHub
```bash
# If not already done
git remote add origin https://github.com/YOUR_USERNAME/igisubizo-muhinzi.git
git push -u origin main
```

### 1.2 Deploy on Koyeb

1. **Go to Koyeb**: https://app.koyeb.com/
2. **Click "Create Service"**
3. **Select "GitHub"** as deployment method
4. **Connect your repository**
5. **Configure Service**:
   - **Name**: `igisubizo-muhinzi-api`
   - **Branch**: `main`
   - **Build path**: `backend`
   - **Builder**: Buildpack
   - **Build command**: (leave empty, auto-detected)
   - **Run command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

6. **Add Environment Variables** (click "Advanced" → "Environment variables"):
   ```
   ENVIRONMENT=production
   PROJECT_NAME=Igisubizo Muhinzi API
   VERSION=1.0.0
   BACKEND_CORS_ORIGINS=*
   LOG_LEVEL=INFO
   MODEL_PATH=models/crop_model_seasonal.pkl
   ENCODER_PATH=models/encoders_seasonal.pkl
   CONFIDENCE_THRESHOLD=0.3
   RATE_LIMIT_PER_MINUTE=100
   GROQ_API_KEY=your-groq-api-key-here
   ```

7. **Select Instance**:
   - **Type**: Nano (512MB) - Free tier
   - **Region**: Frankfurt or Singapore (closest to Rwanda)

8. **Click "Deploy"**

### 1.3 Get Your API URL
After deployment (2-3 minutes), you'll get a URL like:
```
https://igisubizo-muhinzi-api-YOUR-ID.koyeb.app
```

### 1.4 Test Your API
```bash
# Test health endpoint
curl https://your-app.koyeb.app/api/v1/health

# Should return: {"status": "healthy", ...}
```

---

## Step 2: Build Mobile App (5 minutes)

### 2.1 Update API URL

Edit `frontend/lib/core/utils/app_constants.dart`:
```dart
// Change this line:
static const String apiBaseUrl = 'https://your-app.koyeb.app/api/v1';
```

### 2.2 Build Android APK
```bash
cd frontend
flutter build apk --release
```

**Output**: `frontend/build/app/outputs/flutter-apk/app-release.apk`

### 2.3 Test the APK
- Transfer APK to Android device
- Install and test
- Verify it connects to your Koyeb backend

---

## Step 3: Distribute App (5 minutes)

### Option A: GitHub Releases (Easiest)

```bash
# Create release with APK
gh release create v1.0.0 \
  frontend/build/app/outputs/flutter-apk/app-release.apk \
  --title "Igisubizo Muhinzi v1.0.0" \
  --notes "Initial release with Smart Consultant feature"
```

**Share link**: `https://github.com/YOUR_USERNAME/igisubizo-muhinzi/releases`

### Option B: Firebase App Distribution (Recommended for Beta)

1. **Create Firebase Project**: https://console.firebase.google.com/
2. **Add Android App**
3. **Install Firebase CLI**:
```bash
npm install -g firebase-tools
firebase login
```

4. **Distribute**:
```bash
firebase appdistribution:distribute \
  frontend/build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups testers \
  --release-notes "Initial beta release"
```

### Option C: Google Play Store (For Production)

1. **Create Play Console Account**: https://play.google.com/console ($25 one-time fee)
2. **Build App Bundle**:
```bash
flutter build appbundle --release
```
3. **Upload** `frontend/build/app/outputs/bundle/release/app-release.aab`

---

## 🔧 Troubleshooting

### Backend Issues

**Problem**: Model file too large for Git
**Solution**: Use Git LFS
```bash
git lfs install
git lfs track "models/*.pkl"
git add .gitattributes
git commit -m "Track models with Git LFS"
git push
```

**Problem**: Backend crashes on startup
**Solution**: Check logs in Koyeb dashboard
- Verify all environment variables are set
- Check MODEL_PATH is correct
- Ensure GROQ_API_KEY is valid

**Problem**: CORS errors
**Solution**: Update CORS origins
```
BACKEND_CORS_ORIGINS=https://your-frontend-domain.com,*
```

### Frontend Issues

**Problem**: Cannot connect to backend
**Solution**: 
1. Verify API URL in `app_constants.dart`
2. Check backend is running: `curl https://your-app.koyeb.app/api/v1/health`
3. Check CORS is enabled on backend

**Problem**: APK won't install
**Solution**:
1. Enable "Install from Unknown Sources" on Android
2. Rebuild with: `flutter clean && flutter build apk --release`

---

## 📊 Monitoring

### Backend Monitoring
- **Koyeb Dashboard**: https://app.koyeb.com/
  - View logs
  - Monitor CPU/Memory
  - Check request metrics

### Uptime Monitoring (Free)
- **UptimeRobot**: https://uptimerobot.com/
  - Add your API URL
  - Get alerts if backend goes down

---

## 🔐 Security Checklist

- [ ] Change GROQ_API_KEY to your own key
- [ ] Set BACKEND_CORS_ORIGINS to specific domains (not `*`) in production
- [ ] Enable HTTPS (automatic on Koyeb)
- [ ] Set strong API_KEY_SECRET if using API key authentication
- [ ] Review rate limits (RATE_LIMIT_PER_MINUTE)

---

## 💰 Cost Summary

| Service | Cost | Notes |
|---------|------|-------|
| Koyeb Backend | $0/month | Free tier (512MB RAM) |
| GitHub | $0/month | Free for public repos |
| Groq API | $0/month | Free tier available |
| Firebase Distribution | $0/month | Free for testing |
| **Total** | **$0/month** | **Completely free!** |

**Optional Costs**:
- Google Play Store: $25 one-time
- Apple App Store: $99/year
- Koyeb Paid Tier: $7/month (1GB RAM)

---

## 🎯 Next Steps

1. **Test thoroughly** with real users
2. **Set up analytics** (Firebase Analytics)
3. **Monitor errors** (Sentry or Firebase Crashlytics)
4. **Gather feedback** and iterate
5. **Plan for scaling** if user base grows

---

## 📞 Need Help?

- **Koyeb Support**: https://www.koyeb.com/docs
- **Flutter Docs**: https://docs.flutter.dev/
- **FastAPI Docs**: https://fastapi.tiangolo.com/

---

## ✅ Deployment Verification

After deployment, verify everything works:

```bash
# 1. Test health endpoint
curl https://your-app.koyeb.app/api/v1/health

# 2. Test prediction endpoint
curl -X POST https://your-app.koyeb.app/api/v1/predict \
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

# 3. Test smart consultant endpoint
curl -X POST https://your-app.koyeb.app/api/v1/smart-consultant \
  -H "Content-Type: application/json" \
  -d '{
    "province": "Kigali City",
    "district": "Gasabo",
    "season": "Season A",
    "slope": "No",
    "seeds": "Improved seeds",
    "crop": "Maize",
    "inorganic_fert": 1,
    "organic_fert": 1,
    "used_lime": 0
  }'
```

All endpoints should return JSON responses without errors.

---

**🎉 Congratulations! Your app is now deployed and ready for users!**
