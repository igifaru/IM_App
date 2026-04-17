# 🚀 Igisubizo Muhinzi - Deployment Guide

## 📊 Codebase Analysis

### Project Overview
**Igisubizo Muhinzi** is an agricultural crop prediction system for Rwanda with:
- **Backend**: FastAPI-based REST API with ML model integration
- **Frontend**: Flutter mobile/web application
- **ML Model**: Scikit-learn based crop recommendation system (53MB)
- **AI Service**: Groq/Llama integration for agronomic interpretations

---

## 🏗️ Architecture Analysis

### Backend Architecture
```
backend/
├── app/
│   ├── api/endpoints/      # API routes (predict, health, smart-consultant)
│   ├── core/               # Core utilities (config, auth, validation, logging)
│   ├── models/             # Pydantic schemas
│   ├── services/           # Business logic (ML, AI, advice)
│   └── utils/              # Helper functions
├── models/                 # ML model files (53MB + 1.2KB)
├── tests/                  # Pytest test suite
└── requirements.txt        # Python dependencies
```

### Frontend Architecture
```
frontend/
├── lib/
│   ├── core/              # Core utilities (network, theme, localization)
│   ├── features/          # Feature modules (home, prediction, history, etc.)
│   └── shared/            # Shared widgets and models
├── assets/
│   ├── translations/      # i18n (en, fr, rw)
│   └── data/              # GeoJSON maps, administrative data
└── pubspec.yaml           # Flutter dependencies
```

### Key Technologies

#### Backend Stack
- **Framework**: FastAPI 0.104.1
- **Server**: Uvicorn with async support
- **ML**: Scikit-learn 1.3.2, Pandas, NumPy
- **AI**: Groq API (Llama 3.3 70B)
- **Database**: PostgreSQL (optional), Redis (optional)
- **Testing**: Pytest with async support
- **Logging**: JSON structured logging

#### Frontend Stack
- **Framework**: Flutter 3.10+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Localization**: Easy Localization (3 languages)
- **Maps**: Flutter Map with GeoJSON
- **UI**: Material Design with custom theming

---

## 📦 Deployment Requirements

### Backend Requirements
- **Python**: 3.10+
- **Memory**: Minimum 512MB (recommended 1GB for ML model)
- **Storage**: 100MB+ (53MB model + dependencies)
- **Environment Variables**: 15+ configuration options
- **External APIs**: Groq API key required

### Frontend Requirements
- **Build**: Flutter SDK 3.10+
- **Android**: Min SDK 21 (Android 5.0)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers (Chrome, Firefox, Safari)

---

## 🌐 Deployment Strategy

### Option 1: Backend on Koyeb (Recommended)

#### Why Koyeb?
- ✅ Free tier available
- ✅ Automatic HTTPS
- ✅ Git-based deployments
- ✅ Environment variable management
- ✅ Auto-scaling
- ✅ Global CDN

#### Koyeb Deployment Steps

**Step 1: Prepare Backend for Koyeb**

Create `Procfile` in backend directory:
```procfile
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

Create `runtime.txt`:
```
python-3.11
```

Update `requirements.txt` to include:
```
gunicorn==21.2.0
```

**Step 2: Handle Large Model File**

Since the model is 53MB, we have 3 options:

**Option A: Use Git LFS (Recommended)**
```bash
# Install Git LFS
git lfs install

# Track model files
git lfs track "models/*.pkl"
git add .gitattributes
git add models/
git commit -m "Add model files with Git LFS"
```

**Option B: Download model at runtime**
Upload model to cloud storage (AWS S3, Google Cloud Storage, or Cloudinary) and download on startup:

```python
# Add to app/main.py startup event
import requests
import os

@app.on_event("startup")
async def download_model():
    model_url = os.getenv("MODEL_URL")
    if not os.path.exists("models/crop_model_seasonal.pkl"):
        response = requests.get(model_url)
        with open("models/crop_model_seasonal.pkl", "wb") as f:
            f.write(response.content)
```

**Option C: Use Docker with model baked in**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy model first (cached layer)
COPY models/ /app/models/

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY backend/app /app/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Step 3: Deploy to Koyeb**

1. **Push to GitHub**:
```bash
git remote add origin https://github.com/yourusername/igisubizo-muhinzi.git
git push -u origin main
```

2. **Create Koyeb Account**: https://app.koyeb.com/

3. **Create New Service**:
   - Click "Create Service"
   - Select "GitHub" as source
   - Connect your repository
   - Select branch: `main`
   - Build path: `backend/`
   - Build command: `pip install -r requirements.txt`
   - Run command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

4. **Configure Environment Variables**:
```
ENVIRONMENT=production
PROJECT_NAME=Igisubizo Muhinzi API
VERSION=1.0.0
API_HOST=0.0.0.0
API_PORT=8000
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

5. **Set Instance Type**:
   - Instance: Nano (512MB RAM) or Small (1GB RAM recommended)
   - Region: Choose closest to Rwanda (Europe or Asia)
   - Scaling: 1 instance (free tier)

6. **Deploy**: Click "Deploy"

**Step 4: Verify Deployment**
```bash
# Test health endpoint
curl https://your-app.koyeb.app/api/v1/health

# Test prediction endpoint
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
```

---

### Option 2: Backend on Railway (Alternative)

Railway is another excellent option with similar features:

1. **Create Railway Account**: https://railway.app/
2. **New Project** → **Deploy from GitHub**
3. **Configure**:
   - Root directory: `backend/`
   - Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. **Add Environment Variables** (same as Koyeb)
5. **Deploy**

---

### Option 3: Backend on Render (Alternative)

1. **Create Render Account**: https://render.com/
2. **New Web Service** → **Connect GitHub**
3. **Configure**:
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - Root Directory: `backend`
4. **Add Environment Variables**
5. **Deploy**

---

## 📱 Mobile App Deployment

### Android Deployment (Google Play Store)

**Step 1: Prepare for Release**

Update `frontend/android/app/build.gradle.kts`:
```kotlin
android {
    defaultConfig {
        applicationId "com.antigravity.im_app.igisubizo_muhinzi"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            storeFile = file("../keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

**Step 2: Update API Endpoint**

Update `frontend/lib/core/utils/app_constants.dart`:
```dart
class AppConstants {
  // Production API URL
  static const String baseUrl = 'https://your-app.koyeb.app/api/v1';
  
  // Other constants...
}
```

**Step 3: Generate Signing Key**
```bash
cd frontend/android
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias igisubizo
```

**Step 4: Build Release APK**
```bash
cd frontend
flutter build apk --release
```

**Step 5: Build App Bundle (for Play Store)**
```bash
flutter build appbundle --release
```

Output: `frontend/build/app/outputs/bundle/release/app-release.aab`

**Step 6: Upload to Google Play Console**
1. Create developer account: https://play.google.com/console
2. Create new app
3. Upload app bundle
4. Fill in store listing details
5. Submit for review

---

### iOS Deployment (App Store)

**Step 1: Configure Xcode Project**
```bash
cd frontend
open ios/Runner.xcworkspace
```

**Step 2: Update Bundle Identifier**
- Select Runner → General
- Change Bundle Identifier: `com.antigravity.igisubizo-muhinzi`

**Step 3: Configure Signing**
- Select Runner → Signing & Capabilities
- Team: Select your Apple Developer team
- Enable "Automatically manage signing"

**Step 4: Build for Release**
```bash
flutter build ios --release
```

**Step 5: Archive and Upload**
- In Xcode: Product → Archive
- Window → Organizer
- Select archive → Distribute App
- Upload to App Store Connect

---

### Alternative: Open Source App Distribution

#### Option 1: F-Droid (Android Only)

**Advantages**:
- ✅ Free and open source
- ✅ No developer fees
- ✅ Privacy-focused
- ✅ Automatic updates

**Steps**:
1. Ensure app is fully open source
2. Create metadata in `fastlane/metadata/android/`
3. Submit to F-Droid: https://f-droid.org/docs/Submitting_to_F-Droid/

#### Option 2: GitHub Releases

**Advantages**:
- ✅ Completely free
- ✅ Version control integration
- ✅ Direct APK distribution

**Steps**:
```bash
# Build release APK
flutter build apk --release

# Create GitHub release
gh release create v1.0.0 \
  frontend/build/app/outputs/flutter-apk/app-release.apk \
  --title "Igisubizo Muhinzi v1.0.0" \
  --notes "Initial release"
```

Users download APK directly from: `https://github.com/yourusername/igisubizo-muhinzi/releases`

#### Option 3: Firebase App Distribution

**Advantages**:
- ✅ Free for testing
- ✅ Easy beta distribution
- ✅ Analytics included

**Steps**:
1. Create Firebase project
2. Add Android/iOS apps
3. Install Firebase CLI:
```bash
npm install -g firebase-tools
firebase login
```

4. Distribute:
```bash
firebase appdistribution:distribute \
  frontend/build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_APP_ID \
  --groups testers
```

#### Option 4: APKPure / APKMirror

Upload APK to third-party stores:
- APKPure: https://apkpure.com/developer-upload
- APKMirror: https://www.apkmirror.com/

---

## 🔧 Configuration Files for Deployment

### 1. Create `backend/Procfile`
```procfile
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 2
```

### 2. Create `backend/runtime.txt`
```
python-3.11
```

### 3. Create `backend/.dockerignore`
```
__pycache__
*.pyc
*.pyo
*.pyd
.Python
venv/
.env
.git
.gitignore
.vscode
tests/
*.md
```

### 4. Create `backend/Dockerfile` (Optional)
```dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy models first (for caching)
COPY models/ /app/models/

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ /app/app/

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/api/v1/health')"

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 5. Update `frontend/lib/core/utils/app_constants.dart`
```dart
class AppConstants {
  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://your-app.koyeb.app/api/v1',
  );
  
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // App Configuration
  static const String appName = 'Igisubizo Muhinzi';
  static const String appVersion = '1.0.0';
  
  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'fr', 'rw'];
  static const String defaultLanguage = 'rw';
}
```

---

## 🔐 Security Checklist

### Backend Security
- [ ] Set strong `API_KEY_SECRET` in production
- [ ] Enable HTTPS only (handled by Koyeb)
- [ ] Set appropriate CORS origins (not `*` in production)
- [ ] Enable rate limiting
- [ ] Use environment variables for secrets
- [ ] Enable request logging
- [ ] Set up monitoring and alerts
- [ ] Regular dependency updates

### Frontend Security
- [ ] Obfuscate code: `flutter build apk --obfuscate --split-debug-info=build/debug-info`
- [ ] Use HTTPS for all API calls
- [ ] Validate all user inputs
- [ ] Implement certificate pinning (optional)
- [ ] Store sensitive data securely (use flutter_secure_storage)

---

## 📊 Monitoring & Maintenance

### Backend Monitoring
1. **Koyeb Dashboard**: Monitor CPU, memory, requests
2. **Logs**: View application logs in Koyeb console
3. **Uptime Monitoring**: Use UptimeRobot or Pingdom
4. **Error Tracking**: Integrate Sentry

### Frontend Analytics
1. **Firebase Analytics**: Track user behavior
2. **Crashlytics**: Monitor crashes
3. **Performance Monitoring**: Track app performance

---

## 💰 Cost Estimation

### Koyeb (Backend)
- **Free Tier**: 1 Nano instance (512MB RAM) - $0/month
- **Paid Tier**: Small instance (1GB RAM) - ~$7/month
- **Recommended**: Start with free tier, upgrade if needed

### Google Play Store
- **One-time fee**: $25
- **Annual fee**: $0

### Apple App Store
- **Annual fee**: $99/year

### Total Estimated Cost
- **Minimum**: $25 (Android only, free backend)
- **Full**: $124/year (Android + iOS, free backend)
- **With paid backend**: $208/year

---

## 🚀 Quick Start Deployment

### 1. Backend to Koyeb (5 minutes)
```bash
# Add Procfile
echo "web: uvicorn app.main:app --host 0.0.0.0 --port \$PORT" > backend/Procfile

# Push to GitHub
git add .
git commit -m "Prepare for deployment"
git push origin main

# Deploy on Koyeb (via web interface)
# https://app.koyeb.com/
```

### 2. Android APK (10 minutes)
```bash
# Update API URL in app_constants.dart
# Build APK
cd frontend
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### 3. Distribute via GitHub Releases
```bash
gh release create v1.0.0 \
  frontend/build/app/outputs/flutter-apk/app-release.apk \
  --title "Igisubizo Muhinzi v1.0.0"
```

---

## 📞 Support & Resources

- **Koyeb Docs**: https://www.koyeb.com/docs
- **Flutter Deployment**: https://docs.flutter.dev/deployment
- **FastAPI Deployment**: https://fastapi.tiangolo.com/deployment/
- **Groq API**: https://console.groq.com/

---

## ✅ Deployment Checklist

### Pre-Deployment
- [ ] Test backend locally
- [ ] Test frontend with production API
- [ ] Update all environment variables
- [ ] Set up Groq API key
- [ ] Configure CORS properly
- [ ] Test all API endpoints
- [ ] Run tests: `pytest backend/tests/`
- [ ] Build and test APK

### Deployment
- [ ] Deploy backend to Koyeb
- [ ] Verify backend health endpoint
- [ ] Update frontend API URL
- [ ] Build release APK/AAB
- [ ] Test app with production backend
- [ ] Upload to Play Store / distribute APK

### Post-Deployment
- [ ] Monitor logs for errors
- [ ] Set up uptime monitoring
- [ ] Configure analytics
- [ ] Create user documentation
- [ ] Set up feedback mechanism

---

**Ready to deploy? Start with the Quick Start section above! 🚀**
