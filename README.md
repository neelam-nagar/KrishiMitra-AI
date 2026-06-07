<div align="center">

```
██╗  ██╗██████╗ ██╗███████╗██╗  ██╗██╗    ███╗   ███╗██╗████████╗██████╗  █████╗
██║ ██╔╝██╔══██╗██║██╔════╝██║  ██║██║    ████╗ ████║██║╚══██╔══╝██╔══██╗██╔══██╗
█████╔╝ ██████╔╝██║███████╗███████║██║    ██╔████╔██║██║   ██║   ██████╔╝███████║
██╔═██╗ ██╔══██╗██║╚════██║██╔══██║██║    ██║╚██╔╝██║██║   ██║   ██╔══██╗██╔══██║
██║  ██╗██║  ██║██║███████║██║  ██║██║    ██║ ╚═╝ ██║██║   ██║   ██║  ██║██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝    ╚═╝     ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝
```

### 🌾 *Your Digital Friend in the Field — Empowering Rajasthan's Farmers with AI*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-83.6%25-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-ML_Backend-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://tensorflow.org)
[![Firebase](https://img.shields.io/badge/Firebase-Auth_&_DB-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-6366f1?style=for-the-badge&logo=android)](https://flutter.dev/multi-platform/mobile)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)

<br/>

[🌾 Overview](#-overview) &nbsp;•&nbsp;
[✨ Features](#-features) &nbsp;•&nbsp;
[🛠 Tech Stack](#-tech-stack) &nbsp;•&nbsp;
[🏗 Architecture](#-architecture) &nbsp;•&nbsp;
[📁 Structure](#-project-structure) &nbsp;•&nbsp;
[🚀 Installation](#-installation) &nbsp;•&nbsp;
[📡 API Docs](#-api-documentation) &nbsp;•&nbsp;
[🤝 Contributing](#-contributing)

</div>

---

## 🌾 Overview

> **"Rajasthan has over 65 lakh farming families. Most of them don't know which scheme they qualify for. Most of them can't diagnose a diseased crop fast enough. KrishiMitra AI changes that."**

KrishiMitra AI is a **Flutter-based mobile application** built specifically for the farmers of **Rajasthan, India**. The app brings together AI-powered crop disease detection, real-time weather alerts, government scheme discovery, live mandi prices, and a direct-to-buyer marketplace — all in one place.

Farmers no longer need to wait for an agricultural officer. They snap a photo of a sick crop leaf, and within seconds, an AI tells them exactly what's wrong and how to fix it. They check live weather before irrigating. They find out which PM Kisan or Rajasthan state scheme they qualify for. They sell directly to buyers without a middleman.

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                       │
│   📱 FLUTTER APP  ←→  🐍 PYTHON ML API  ←→  🧠 TENSORFLOW MODEL     │
│         ↕                                                             │
│   🔥 FIREBASE (Auth · Firestore · Storage)                           │
│         ↕                                                             │
│   ☀️ WEATHER API  ·  🤖 GEMINI AI  ·  📊 MANDI PRICES               │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

### 🔬 AI Crop Disease Detection
| Step | What Happens |
|------|-------------|
| 📸 **Capture** | Farmer clicks a photo of the diseased leaf |
| 📤 **Upload** | Image is compressed client-side and sent to Python backend |
| 🧠 **Analyze** | CNN model runs inference and returns disease + confidence |
| 💊 **Treat** | App shows disease name, severity, and treatment steps in Hindi/English |

### 🌦 Real-Time Weather Dashboard
- Location-aware 5-day forecast (temperature, humidity, rainfall)
- ⚠️ Storm & heat-wave alerts with push notifications
- Irrigation scheduling based on upcoming rainfall predictions
- Designed for Rajasthan's arid and semi-arid climate zones

### 🌱 AI Crop Advisory
- Gemini AI-powered seasonal crop recommendations
- Region-specific advice (Jodhpur, Jaipur, Udaipur, Bikaner zones)
- Guidance on fertilizers, irrigation, soil health, and crop rotation
- 24/7 expert chat assistant

### 🏛 Government Scheme Navigator
- Browse **PM Kisan Samman Nidhi**, **Rajasthan Kisan Kalyan Yojana**, and 50+ other schemes
- Eligibility checker based on land size, crop type, and district
- Step-by-step application guidance

### 📈 Live Mandi Price Tracker
```
┌────────────────────────────────────────┐
│  🌾 Wheat        ₹2,150 / quintal  ↑  │
│  🌽 Maize        ₹1,890 / quintal  →  │
│  🫘 Moong Dal    ₹7,200 / quintal  ↑  │
│  🌻 Mustard      ₹5,450 / quintal  ↓  │
└────────────────────────────────────────┘
```

### 🛒 Direct-to-Buyer Marketplace
- List your produce directly — no middlemen
- Connect with verified buyers across Rajasthan
- Real photo listings with GPS-tagged location
- 30–40% better prices vs. local mandis

### 👥 Farmer Community Forum
- Ask questions, share experiences with thousands of Rajasthani farmers
- Crop-specific threads (wheat, bajra, jowar, mustard, vegetables)
- Expert agronomist replies

---

## 🛠 Tech Stack

```
┌──────────────────────────────────────────────────────────────────┐
│                        TECH STACK                                 │
├─────────────────────┬────────────────────────────────────────────┤
│  Layer              │  Technology                                 │
├─────────────────────┼────────────────────────────────────────────┤
│  📱 Mobile App      │  Flutter (Dart) — Android & iOS            │
│  🎨 UI/State        │  Flutter Widgets + Provider/Riverpod        │
│  🔐 Authentication  │  Firebase Auth (Email + Phone OTP)          │
│  🗄  Database        │  Firebase Firestore (NoSQL)                 │
│  🖼  Image Storage   │  Firebase Storage                          │
│  ⚡ Real-time       │  Firebase Realtime Database                 │
│  🐍 ML Backend      │  Python — Flask / FastAPI                   │
│  🧠 AI Model        │  TensorFlow / Keras (CNN)                   │
│  📓 Model Training  │  Jupyter Notebook                           │
│  🤖 AI Assistant    │  Google Gemini API                          │
│  ☀️ Weather         │  OpenWeatherMap API                         │
│  🐳 DevOps          │  Docker                                     │
│  💻 IDE             │  VS Code                                    │
└─────────────────────┴────────────────────────────────────────────┘
```

**Language Breakdown:**
```
Dart (Flutter)      ████████████████████  83.6%
Python (ML)         ██████                10.9%
Jupyter Notebook    ██                     4.5%
HTML / Other        █                      1.0%
```

---

## 🏗 Architecture

### System Architecture

```
                    ┌─────────────────────────────┐
                    │       📱 FLUTTER APP          │
                    │   (Android / iOS Frontend)    │
                    └──────────┬──────────────────┘
                               │
           ┌───────────────────┼───────────────────────┐
           │                   │                       │
           ▼                   ▼                       ▼
  ┌─────────────────┐ ┌─────────────────┐  ┌─────────────────┐
  │  🐍 PYTHON ML   │ │  🔥 FIREBASE    │  │  🌐 EXTERNAL    │
  │    BACKEND      │ │                 │  │    APIs         │
  │                 │ │ • Auth          │  │                 │
  │ • Disease API   │ │ • Firestore     │  │ • Gemini AI     │
  │ • CNN Model     │ │ • Storage       │  │ • Weather API   │
  │ • Jupyter NB    │ │ • Realtime DB   │  │ • Mandi Prices  │
  └────────┬────────┘ └─────────────────┘  └─────────────────┘
           │
  ┌────────▼────────┐
  │  🧠 TENSORFLOW  │
  │   CNN MODEL     │
  │  (.h5 / TFLite) │
  └─────────────────┘
```

### Disease Detection Flow

```
  Farmer                Flutter App             Python Backend         ML Model
    │                       │                         │                    │
    │── Tap Camera ─────────▶                         │                    │
    │                       │── Compress Image ──▶    │                    │
    │                       │                         │── Load .h5 ────────▶
    │                       │── POST /api/predict ────▶                    │
    │                       │                         │── Predict ─────────▶
    │                       │                         │◀── Label + Score ──│
    │                       │◀── JSON Response ───────│                    │
    │◀── Disease Card ───────│                         │                    │
    │   (Name + Treatment)  │                         │                    │
```

### App Screen Flow

```
  ┌──────────┐
  │  Splash  │
  └────┬─────┘
       │
  ┌────▼─────┐     ┌──────────────────────────────────────────────────┐
  │  Login /  │────▶│                   HOME SCREEN                    │
  │ Register  │     └──┬──────┬──────┬───────┬──────────┬─────────────┘
  └──────────┘         │      │      │       │          │
                        ▼      ▼      ▼       ▼          ▼
                    🔬Disease ☀️Weather 🌱Crops 🏛Schemes 🛒Market
                    Detector  Board   Advisory Navigator  Place
```

---

## 📁 Project Structure

```
KrishiMitra-AI/
│
├── 📁 Backend/                      # Python ML Service
│   ├── 📄 app.py                    # Flask/FastAPI server entry point
│   ├── 📄 requirements.txt          # Python dependencies
│   ├── 📁 models/                   # Trained ML model files
│   │   └── 🧠 disease_model.h5      # CNN plant disease classifier
│   ├── 📁 routes/                   # API route handlers
│   │   └── 📄 predict.py            # POST /api/predict endpoint
│   ├── 📁 utils/                    # Helper utilities
│   │   └── 📄 image_utils.py        # Image preprocessing
│   └── 📁 notebooks/                # Jupyter training notebooks
│       ├── 📓 model_training.ipynb  # CNN model training
│       └── 📓 model_evaluation.ipynb
│
├── 📁 Frontend/                     # Flutter Mobile App
│   ├── 📄 pubspec.yaml              # Flutter dependencies & assets
│   ├── 📁 lib/
│   │   ├── 📄 main.dart             # App entry point
│   │   ├── 📄 firebase_options.dart # Firebase config (auto-generated)
│   │   ├── 📁 models/               # Dart data models
│   │   │   ├── crop_model.dart
│   │   │   ├── disease_result.dart
│   │   │   ├── weather_model.dart
│   │   │   └── listing_model.dart
│   │   ├── 📁 screens/              # UI Screens
│   │   │   ├── home_screen.dart
│   │   │   ├── disease_detector_screen.dart
│   │   │   ├── weather_screen.dart
│   │   │   ├── crop_advisory_screen.dart
│   │   │   ├── scheme_navigator_screen.dart
│   │   │   ├── marketplace_screen.dart
│   │   │   └── community_screen.dart
│   │   ├── 📁 services/             # API & Firebase services
│   │   │   ├── disease_service.dart
│   │   │   ├── weather_service.dart
│   │   │   ├── gemini_service.dart
│   │   │   ├── auth_service.dart
│   │   │   └── firestore_service.dart
│   │   ├── 📁 widgets/              # Reusable UI components
│   │   └── 📁 utils/                # Constants, theme, helpers
│   ├── 📁 android/                  # Android platform config
│   ├── 📁 ios/                      # iOS platform config
│   └── 📁 assets/                   # Images, fonts, icons
│
├── 📁 .vscode/                      # VS Code workspace settings
├── 📄 .gitattributes
└── 📄 README.md
```

---

## 🚀 Installation

### Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| Flutter SDK | 3.x+ | [flutter.dev](https://docs.flutter.dev/get-started/install) |
| Python | 3.10+ | [python.org](https://python.org/downloads) |
| Android Studio | Latest | [developer.android.com](https://developer.android.com/studio) |
| Firebase CLI | Latest | `npm install -g firebase-tools` |
| Git | Any | [git-scm.com](https://git-scm.com) |

---

### Step 1 — Clone the Repository

```bash
git clone https://github.com/neelam-nagar/KrishiMitra-AI.git
cd KrishiMitra-AI
```

---

### Step 2 — Set Up Python Backend

```bash
# Go to backend folder
cd Backend

# Create virtual environment
python -m venv venv

# Activate it
source venv/bin/activate          # macOS / Linux
# venv\Scripts\activate           # Windows

# Install dependencies
pip install -r requirements.txt

# Create your environment file
cp .env.example .env
# → Now fill in your API keys (see Environment Variables section)

# Start the backend server
python app.py
# Running at: http://127.0.0.1:8000
```

---

### Step 3 — Set Up Flutter Frontend

```bash
# Go to frontend folder
cd ../Frontend

# Get all Flutter packages
flutter pub get

# Set up Firebase (one-time)
dart pub global activate flutterfire_cli
flutterfire configure
# → Select your Firebase project
# → This auto-generates firebase_options.dart

# Run the app on your device / emulator
flutter run
```

---

### Step 4 — (Optional) Docker for Backend

```bash
cd Backend
docker build -t krishimitra-backend .
docker run -p 8000:8000 --env-file .env krishimitra-backend
```

---

## 🔑 Environment Variables

### Backend — `Backend/.env`

| Variable | Required | Description | Example |
|----------|:--------:|-------------|---------|
| `GOOGLE_API_KEY` | ✅ | Google Gemini API key | `AIzaSy...` |
| `WEATHER_API_KEY` | ✅ | OpenWeatherMap API key | `0532ccbb...` |
| `MODEL_PATH` | ✅ | Path to trained .h5 model | `models/disease_model.h5` |
| `CONFIDENCE_THRESHOLD` | ⚙️ | Min confidence before fallback | `0.75` |
| `PORT` | ⚙️ | API server port | `8000` |
| `DEBUG` | ⚙️ | Debug mode toggle | `False` |
| `ALLOWED_ORIGINS` | ⚙️ | CORS origins (production: your domain) | `*` |

### Frontend — `Frontend/lib/utils/env_keys.dart`

| Variable | Required | Description |
|----------|:--------:|-------------|
| `BACKEND_BASE_URL` | ✅ | Python ML backend URL |
| `WEATHER_API_KEY` | ✅ | OpenWeatherMap key |
| `GEMINI_API_KEY` | ✅ | Google Gemini key |
| `FIREBASE_*` | ✅ | Auto-generated by FlutterFire CLI |

> ⚠️ **Never commit `.env` files or API keys to GitHub. Add them to `.gitignore`.**

---

## ⚙️ Configuration

### Firebase Setup

```bash
# Login to Firebase
firebase login

# Initialize in the project
firebase init

# Generate Flutter config
flutterfire configure
```

Enable these Firebase services in your project console:
- ✅ **Authentication** — Email/Password + Phone OTP
- ✅ **Firestore Database** — User data, listings, community posts
- ✅ **Storage** — Crop disease images
- ✅ **Realtime Database** — Chat / live features

### ML Model Training (Optional)

```bash
# Open Jupyter notebooks
cd Backend/notebooks
jupyter notebook

# Run model_training.ipynb end-to-end
# → Exports trained model to Backend/models/disease_model.h5
```

---

## 📱 Usage Examples

### Detecting a Crop Disease

```dart
// Flutter — call the disease detection service
final File imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

final DiseaseResult result = await DiseaseService.predict(imageFile);

print(result.diseaseName);      // "Tomato Late Blight"
print(result.confidence);       // 0.92
print(result.severity);         // "High"
print(result.treatmentSteps);   // ["Remove infected leaves", "Apply copper fungicide"]
```

### Fetching Weather for a Location

```dart
// Get weather for farmer's location
final WeatherData weather = await WeatherService.getForecast(
  city: "Jodhpur",
  state: "Rajasthan",
);

print(weather.temperature);    // 38°C
print(weather.rainfall);       // 0mm expected
print(weather.alert);          // "Heatwave warning — avoid irrigation between 11AM–4PM"
```

### Checking Government Schemes

```dart
// Filter schemes by farmer profile
final List<Scheme> schemes = await SchemeService.getEligible(
  state: "Rajasthan",
  landSize: 3.5,          // acres
  cropType: "Wheat",
  category: "Small Farmer",
);

// Returns: PM Kisan, PMFBY, Rajasthan Krishi Yantra Subsidy...
```

---

## 📡 API Documentation

Base URL: `http://localhost:8000/api`

---

### `POST /api/predict` — Disease Detection

Accepts a crop leaf image, returns disease prediction with treatment advice.

**Request:**
```http
POST /api/predict
Content-Type: multipart/form-data

file: <image_file>    # JPEG or PNG, max 5 MB
```

**Success Response (200):**
```json
{
  "success": true,
  "disease": "Tomato Late Blight",
  "confidence": 0.92,
  "severity": "High",
  "treatment": [
    "Remove and destroy all infected leaves immediately.",
    "Apply copper-based fungicide every 7–10 days.",
    "Switch to drip irrigation to reduce leaf wetness."
  ],
  "prevention": [
    "Use certified disease-free seeds.",
    "Rotate crops every season."
  ],
  "source": "ml_model"
}
```

**Error Response (422):**
```json
{
  "success": false,
  "error": "Could not identify disease. Please upload a clearer image."
}
```

---

### `GET /health` — Health Check

```http
GET /health
```

```json
{
  "status": "ok",
  "model_loaded": true,
  "version": "1.0.0"
}
```

---

> **Note:** Weather, Gemini AI, and Mandi Price features are called directly from the Flutter app using their respective SDKs. The Python backend handles only ML inference.

---

## 🗄 Database Schema

KrishiMitra uses **Firebase Firestore** as its primary database.

### Collections Overview

```
Firestore
│
├── 👤 users/{uid}
│   ├── name, phone, state, district
│   ├── landSize (acres)
│   └── primaryCrops [ ]
│
├── 🛒 listings/{listingId}
│   ├── sellerId → users/{uid}
│   ├── cropType, quantity, pricePerUnit
│   ├── location (GeoPoint)
│   ├── imageUrls [ ]
│   └── status: "active" | "sold" | "expired"
│
├── 🔬 disease_scans/{scanId}
│   ├── userId → users/{uid}
│   ├── imageUrl (Firebase Storage)
│   ├── disease, confidence
│   └── treatmentSteps [ ]
│
└── 💬 community_posts/{postId}
    ├── authorId → users/{uid}
    ├── title, body, tags [ ]
    ├── likes (number)
    └── replies/ (subcollection)
```

### Firestore Security Rules (Summary)

```javascript
// Users can only read/write their own profile
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
}

// Listings are public to read, auth required to write
match /listings/{id} {
  allow read: if true;
  allow write: if request.auth != null;
}

// Scans are private to the owner
match /disease_scans/{id} {
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

---

## 🔐 Authentication

KrishiMitra uses **Firebase Authentication** with two sign-in methods:

```
User Opens App
      │
      ▼
  New User?
  ├── YES → Register with Phone OTP (preferred for farmers)
  │           └── Firebase sends OTP → User verifies → Profile created in Firestore
  └── NO  → Login with Email/Password or Phone
              └── Firebase returns ID Token → Stored securely → Navigate to Home
```

**Why Phone OTP?** Most Rajasthani farmers are more comfortable with their mobile number than an email address. OTP-based login requires no password to remember.

---

## 🚢 Deployment

### Backend — Python ML Service

**Option A: Render / Railway (Recommended)**
1. Connect your GitHub repo to [render.com](https://render.com)
2. Set **Root Directory** to `Backend`
3. Set **Start Command** to `python app.py`
4. Add all environment variables in the dashboard
5. Deploy ✅

**Option B: Google Cloud Run**

```bash
# Build Docker image
docker build -t krishimitra-backend ./Backend

# Push to Google Container Registry
docker tag krishimitra-backend gcr.io/YOUR_PROJECT/krishimitra-backend
docker push gcr.io/YOUR_PROJECT/krishimitra-backend

# Deploy to Cloud Run
gcloud run deploy krishimitra-backend \
  --image gcr.io/YOUR_PROJECT/krishimitra-backend \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_API_KEY=...,WEATHER_API_KEY=...
```

### Frontend — Flutter App

**Build Android APK:**
```bash
cd Frontend
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Build Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

**Build iOS (App Store):**
```bash
flutter build ios --release
# Then archive and upload via Xcode → App Store Connect
```

**Deploy Firebase Rules:**
```bash
firebase deploy --only firestore:rules,storage
```

---

## 🧪 Testing

### Flutter Tests

```bash
cd Frontend

# Run all unit and widget tests
flutter test

# Run with verbose output
flutter test --reporter=expanded

# Run integration tests (requires connected device)
flutter test integration_test/
```

### Python Backend Tests

```bash
cd Backend
source venv/bin/activate

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=. --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Manual API Testing

```bash
# Disease detection
curl -X POST http://localhost:8000/api/predict \
  -F "file=@sample_leaf.jpg"

# Health check
curl http://localhost:8000/health
```

---

## 🔒 Security Notes

```
⚠️  Never expose API keys in the Flutter app bundle.
     Use a server-side proxy for sensitive keys.

⚠️  Set strict Firestore Security Rules before going to production.
     The default rules allow open read/write — dangerous!

⚠️  Validate all image uploads on the backend.
     Check MIME type and file size before running ML inference.

⚠️  In production, set ALLOWED_ORIGINS to your specific domain.
     Never ship with CORS = * in production.

⚠️  Rate-limit the /api/predict endpoint.
     Without limits, it's vulnerable to abuse and high server costs.
```

---

## ⚡ Performance Optimizations

| Optimization | Description |
|-------------|-------------|
| 📦 **Client-side compression** | Crop photos resized before upload — reduces payload and prevents backend OOM |
| 📲 **TFLite export** | CNN model exported to `.tflite` for on-device inference (offline support) |
| 📄 **Firestore pagination** | Marketplace listings loaded in pages using Firestore cursors |
| 🖼 **Image caching** | `cached_network_image` caches marketplace photos locally |
| 🔁 **Debounced search** | Community search debounced at 300ms — prevents unnecessary Firestore reads |
| 🧵 **Dart Isolates** | Heavy image pre-processing runs in a separate Dart Isolate to keep UI smooth |
| 🤖 **Gemini fallback only** | ML model handles common cases fast; Gemini only invoked for low-confidence results |

---

## 🖼 Screenshots

> 📸 **Screenshots coming soon.**  
> Contributors — please add demo screenshots to `docs/screenshots/` and update this section.

| Screen | Preview |
|--------|---------|
| 🏠 Home Dashboard | `docs/screenshots/home.png` |
| 🔬 Disease Detector | `docs/screenshots/disease.png` |
| ☀️ Weather Board | `docs/screenshots/weather.png` |
| 🏛 Scheme Navigator | `docs/screenshots/schemes.png` |
| 🛒 Marketplace | `docs/screenshots/marketplace.png` |
| 👥 Community Forum | `docs/screenshots/community.png` |

---

## 🛣 Roadmap

- [x] Flutter mobile app (Android & iOS)
- [x] Python ML backend with CNN disease detection
- [x] Firebase Authentication (Email + Phone OTP)
- [x] Real-time weather integration
- [x] Government scheme navigator
- [x] Live mandi price tracker
- [x] Direct marketplace
- [x] Community forum
- [ ] **Offline mode** — TFLite on-device disease detection (no internet needed)
- [ ] **Hindi UI** — Full app localisation in Hindi for Rajasthani farmers
- [ ] **Voice input** — Speak queries in Hindi using Google Speech-to-Text
- [ ] **Push notifications** — Weather alerts & scheme deadlines via FCM
- [ ] **Crop calendar** — Personalised Rajasthan sowing & harvest schedule
- [ ] **IoT integration** — Soil moisture & NPK sensors for automated advisory
- [ ] **Price prediction** — ML-based mandi price forecasting
- [ ] **In-app payments** — UPI / Razorpay for marketplace transactions
- [ ] **WhatsApp bot** — Reach farmers who don't have smartphones

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

```bash
# 1. Fork the repo on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/KrishiMitra-AI.git

# 3. Create a feature branch
git checkout -b feature/add-offline-detection

# 4. Make your changes and commit
git commit -m "feat: add TFLite offline disease detection"

# 5. Push to your fork
git push origin feature/add-offline-detection

# 6. Open a Pull Request on GitHub
```

### Code Style Guidelines

| Language | Style Guide | Linter |
|----------|------------|--------|
| Dart / Flutter | [Effective Dart](https://dart.dev/guides/language/effective-dart) | `flutter analyze` |
| Python | [PEP 8](https://pep8.org) | `black` + `flake8` |
| Commits | [Conventional Commits](https://conventionalcommits.org) | `feat:` `fix:` `docs:` `refactor:` |

### Reporting Issues

- 🐛 **Bug?** — Open a GitHub Issue with device info, Flutter version, and steps to reproduce
- 💡 **Feature idea?** — Open a GitHub Discussion
- 🔐 **Security issue?** — Email directly, don't open a public issue

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License — Copyright (c) 2025 Neelam Nagar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

See the full [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

| Library / Service | Purpose |
|------------------|---------|
| [Flutter](https://flutter.dev) | Cross-platform mobile framework |
| [TensorFlow / Keras](https://tensorflow.org) | CNN disease detection model |
| [Google Gemini API](https://ai.google.dev) | AI crop advisory & chat |
| [Firebase](https://firebase.google.com) | Auth, database & storage |
| [OpenWeatherMap](https://openweathermap.org/api) | Real-time weather data |
| [FastAPI / Flask](https://fastapi.tiangolo.com) | Python REST API |
| [Jupyter](https://jupyter.org) | Model training & experimentation |
| [Docker](https://docker.com) | Backend containerisation |

---

<div align="center">

---

**Made with ❤️ for the Farmers of Rajasthan 🌾🇮🇳**

*"Jai Kisan — Technology in the hands of those who feed us."*

---

⭐ **If this project helped you, please give it a star on GitHub!** ⭐

[![GitHub stars](https://img.shields.io/github/stars/neelam-nagar/KrishiMitra-AI?style=social)](https://github.com/neelam-nagar/KrishiMitra-AI/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/neelam-nagar/KrishiMitra-AI?style=social)](https://github.com/neelam-nagar/KrishiMitra-AI/network/members)

**[⬆ Back to Top](#)**

</div>
