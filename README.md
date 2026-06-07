# 🌾 KrishiMitra AI

> Intelligent farming companion for Rajasthan farmers — AI chatbot, real-time weather, mandi prices, government schemes, crop disease detection, and compensation calculator.

---

## Architecture

```
KrishiMitra-AI/
├── backend_unified/        # Single FastAPI backend (all modules)
│   ├── main.py             # Unified API — all 6 modules
│   ├── Dockerfile          # Production container (gunicorn + uvicorn)
│   ├── requirements.txt
│   ├── .env.example        # Copy → .env, fill in secrets
│   ├── final_clean.json    # Weather location data (31 districts)
│   ├── mandi_cache.json    # Crop price data (709 records)
│   ├── scheme.json         # Government schemes (62 schemes)
│   ├── model/              # Crop disease ML model (.pth)
│   └── tests/
│       └── test_main.py    # 37 tests — all passing
│
└── Frontend/               # Flutter mobile app
    ├── lib/
    │   ├── main.dart
    │   ├── firebase_options.dart   ← replace with real Firebase config
    │   ├── core/config/app_config.dart
    │   ├── presentation/           # All screens
    │   └── services/               # Storage, Firestore, OrganicGuide
    ├── pubspec.yaml
    ├── env.json.example    # Copy → env.json, fill in BACKEND_BASE
    └── test/
        └── widget_test.dart  # LanguageProvider + LocationProvider tests
```

---

## Quick Start

### 1. Backend

```bash
cd backend_unified

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env — set GEMINI_API_KEY

# Run (development)
uvicorn main:app --reload --port 8000

# Run (production)
gunicorn main:app --worker-class uvicorn.workers.UvicornWorker \
  --workers 2 --bind 0.0.0.0:8000

# Run tests
pytest tests/ -v
```

**API docs**: http://localhost:8000/docs  
**Health check**: http://localhost:8000/api/health

### 2. Flutter App

```bash
cd Frontend

# Copy and fill environment
cp env.json.example env.json
# Edit env.json — set BACKEND_BASE to your deployed backend URL

# Get packages
flutter pub get

# Run on emulator (Android — connects to localhost via 10.0.2.2)
flutter run --dart-define-from-file=env.json

# Run tests
flutter test

# Build release APK
flutter build apk --dart-define-from-file=env.json
```

---

## Required External Setup

### Firebase (mandatory for auth, community, marketplace)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a project named `krishimitra-ai`
3. Enable **Phone Authentication**
4. Enable **Firestore** and **Storage**
5. Install FlutterFire CLI and run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This overwrites `lib/firebase_options.dart` with real credentials.

### Gemini API Key (mandatory for chatbot)

1. Get a free key at [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Add to `backend_unified/.env`:
   ```
   GEMINI_API_KEY=your_key_here
   ```

### PyTorch — Crop Disease Detection (optional)

```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
```
Without PyTorch the disease endpoint returns HTTP 503 gracefully.

---

## Environment Files

### `backend_unified/.env`
```env
GEMINI_API_KEY=your_gemini_key_here
```

### `Frontend/env.json`
```json
{
  "BACKEND_BASE": "https://your-deployed-backend.onrender.com"
}
```
> **Never commit `.env` or `env.json`.** Both are in `.gitignore`.

---

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check + module status |
| POST | `/api/chat` | AI chatbot (Gemini 1.5 Flash) |
| GET | `/api/weather/districts` | List all 31 Rajasthan districts |
| GET | `/api/weather/tehsils?district=` | List tehsils for a district |
| GET | `/api/weather/villages?district=&tehsil=` | List villages |
| GET | `/api/weather?district=&tehsil=&village=` | Current + 7-day forecast |
| GET | `/api/mandi/districts` | All mandi districts |
| GET | `/api/mandi/mandis?district=` | Mandis in a district |
| GET | `/api/mandi/crops?district=&mandi=` | Crops at a mandi |
| GET | `/api/mandi?district=&mandi=&crop=` | Crop price history |
| GET | `/api/schemes` | List government schemes |
| GET | `/api/schemes/{id}` | Scheme detail |
| POST | `/api/disease/predict` | Crop disease (multipart image) |
| POST | `/api/disease/predict-base64` | Crop disease (base64 JSON) |
| GET | `/api/compensation/calculate` | Compensation estimate |

Full interactive docs: `/docs` (Swagger UI)

---

## Deployment

### Backend on Render (recommended free tier)

1. Connect the `KrishiMitra-AI` repo to Render
2. Set **Root Directory**: `backend_unified`
3. Set **Build Command**: `pip install -r requirements.txt`
4. Set **Start Command**: `gunicorn main:app --worker-class uvicorn.workers.UvicornWorker --workers 2 --bind 0.0.0.0:$PORT`
5. Add environment variable: `GEMINI_API_KEY`

### Backend with Docker

```bash
cd backend_unified
docker build -t krishimitra-backend .
docker run -p 8000:8000 -e GEMINI_API_KEY=your_key krishimitra-backend
```

---

## Module Status

| Module | Backend | Flutter | Notes |
|--------|---------|---------|-------|
| AI Chatbot | ✅ | ✅ | Needs GEMINI_API_KEY |
| Weather | ✅ | ✅ | Uses Open-Meteo (free, no key) |
| Mandi Prices | ✅ | ✅ | 709 records, Rajasthan |
| Government Schemes | ✅ | ✅ | 62 schemes, bilingual |
| Crop Disease | ✅ | ✅ | Needs PyTorch (optional) |
| Compensation Calc | ✅ | ✅ | Crop-specific PMFBY/SDRF rates |
| Community Chat | ✅ | ✅ | Needs Firebase |
| Marketplace | ✅ | ✅ | Needs Firebase Storage |
| Land Records | — | ✅ | External (Rajasthan e-Dharti) |
| Kisan Loan | — | ✅ | Static info screen |
| Profile | — | ✅ | Firebase Auth + SharedPreferences |

---

## Security Notes

- No secrets are hardcoded — all come from environment variables or `--dart-define`
- Firebase Auth enforces phone-number identity before Firestore writes
- Firestore Security Rules should restrict each user to their own documents
- Backend CORS is open (`*`) — appropriate for a mobile-first API; tighten if adding a web frontend

---

## Test Results

```
Backend:  37/37 passing  (pytest tests/ -v)
Frontend: Widget + unit tests for LanguageProvider & LocationProvider
```
