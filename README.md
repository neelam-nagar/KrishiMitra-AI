<div align="center">

# 🌾 KrishiMitra AI

**AI-powered farming assistant for Rajasthan's farmers**
*Disease detection · Weather alerts · Govt schemes · Mandi prices · Marketplace*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-ML-FF6F00?style=flat-square&logo=tensorflow&logoColor=white)](https://tensorflow.org)
[![Firebase](https://img.shields.io/badge/Firebase-Auth_&_DB-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-22c55e?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android_|_iOS-6366f1?style=flat-square&logo=android)](https://flutter.dev)

</div>

---

## 📖 About

KrishiMitra AI is a **Flutter mobile app** built for the farmers of **Rajasthan, India**. Farmers can photograph a diseased crop leaf and get an instant AI diagnosis, check live weather before irrigating, discover government schemes they qualify for, and sell produce directly to buyers — all in one app.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔬 **Disease Detection** | Click a leaf photo → CNN model diagnoses the disease + treatment steps |
| 🌦 **Weather Dashboard** | 5-day forecast with storm & heatwave alerts for Rajasthan |
| 🌱 **Crop Advisory** | Gemini AI-powered crop & fertilizer recommendations |
| 🏛 **Scheme Navigator** | Browse PM Kisan, PMFBY, Rajasthan state schemes with eligibility check |
| 📈 **Mandi Prices** | Live market prices before selling — never get cheated by traders |
| 🛒 **Marketplace** | Sell produce directly to buyers — 30–40% better prices, no middlemen |
| 👥 **Community Forum** | Ask questions, share experiences with farmers across Rajasthan |

---

## 🛠 Tech Stack

```
Frontend   →  Flutter (Dart)  ·  Firebase Auth  ·  Firestore  ·  Firebase Storage
Backend    →  Python (Flask / FastAPI)  ·  TensorFlow / Keras CNN
AI & APIs  →  Google Gemini API  ·  OpenWeatherMap API
DevOps     →  Docker  ·  VS Code
```

**Language breakdown:**
```
Dart        ████████████████████  83.6%
Python      ██████                10.9%
Jupyter     ██                     4.5%
Other       █                      1.0%
```

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    📱 Flutter App                        │
└────────┬────────────────┬───────────────┬───────────────┘
         │                │               │
         ▼                ▼               ▼
  ┌─────────────┐  ┌────────────┐  ┌───────────────┐
  │ 🐍 Python   │  │ 🔥 Firebase│  │  🌐 External  │
  │ ML Backend  │  │            │  │     APIs      │
  │             │  │ Auth       │  │               │
  │ /predict    │  │ Firestore  │  │ Gemini AI     │
  │ CNN Model   │  │ Storage    │  │ OpenWeather   │
  └──────┬──────┘  └────────────┘  └───────────────┘
         │
  ┌──────▼──────┐
  │ 🧠 TFLite  │
  │  .h5 Model  │
  └─────────────┘
```

### Disease Detection Flow
```
Farmer  →  📸 Snap photo  →  Flutter compresses image
       →  POST /api/predict  →  CNN runs inference
       →  Returns: disease + confidence + treatment  →  📱 Result card shown
```

---

## 📁 Project Structure

```
KrishiMitra-AI/
├── Backend/
│   ├── app.py                   # Flask/FastAPI entry point
│   ├── requirements.txt
│   ├── models/
│   │   └── disease_model.h5     # Trained CNN model
│   ├── routes/
│   │   └── predict.py           # POST /api/predict
│   └── notebooks/
│       └── model_training.ipynb
│
└── Frontend/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── screens/
        │   ├── home_screen.dart
        │   ├── disease_detector_screen.dart
        │   ├── weather_screen.dart
        │   ├── scheme_navigator_screen.dart
        │   ├── marketplace_screen.dart
        │   └── community_screen.dart
        ├── services/
        │   ├── disease_service.dart
        │   ├── weather_service.dart
        │   ├── gemini_service.dart
        │   └── auth_service.dart
        └── models/
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x · Python 3.10+ · Android Studio · Firebase CLI

### 1. Clone

```bash
git clone https://github.com/neelam-nagar/KrishiMitra-AI.git
cd KrishiMitra-AI
```

### 2. Backend

```bash
cd Backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env        # Add your API keys
python app.py               # Runs at http://localhost:8000
```

### 3. Frontend

```bash
cd Frontend
flutter pub get
flutterfire configure       # Connect your Firebase project
flutter run
```

---

## 🔑 Environment Variables

| Variable | Required | Description |
|----------|:--------:|-------------|
| `GOOGLE_API_KEY` | ✅ | Google Gemini API key |
| `WEATHER_API_KEY` | ✅ | OpenWeatherMap API key |
| `MODEL_PATH` | ✅ | Path to `disease_model.h5` |
| `PORT` | ⚙️ | Server port (default: `8000`) |
| `ALLOWED_ORIGINS` | ⚙️ | CORS origins |

> ⚠️ Never commit `.env` to GitHub.

---

## 📡 API Reference

### `POST /api/predict`

```bash
curl -X POST http://localhost:8000/api/predict \
  -F "file=@leaf_photo.jpg"
```

```json
{
  "success": true,
  "disease": "Tomato Late Blight",
  "confidence": 0.92,
  "severity": "High",
  "treatment": [
    "Remove infected leaves immediately.",
    "Apply copper-based fungicide every 7–10 days."
  ]
}
```

### `GET /health`

```json
{ "status": "ok", "model_loaded": true }
```

---

## 🗄 Database Schema (Firestore)

```
users/{uid}          →  name, phone, district, landSize, primaryCrops[]
listings/{id}        →  sellerId, cropType, quantity, price, location, status
disease_scans/{id}   →  userId, imageUrl, disease, confidence, treatment[]
community_posts/{id} →  authorId, title, body, tags[], likes, replies/
```

---

## 🚢 Deployment

**Backend (Render / Railway):**
```bash
# Set root directory: Backend
# Start command: python app.py
# Add env vars in dashboard → Deploy
```

**Flutter APK:**
```bash
cd Frontend
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

---

## 🛣 Roadmap

- [x] Disease detection (CNN model)
- [x] Weather dashboard
- [x] Government scheme navigator
- [x] Mandi price tracker
- [x] Direct marketplace
- [x] Community forum
- [ ] Offline mode (TFLite on-device)
- [ ] Hindi UI localisation
- [ ] Voice input in Hindi
- [ ] Push notifications (FCM)
- [ ] UPI / Razorpay in-app payments
- [ ] WhatsApp bot for feature phones

---

## 🤝 Contributing

```bash
git checkout -b feature/your-feature
git commit -m "feat: your change"
git push origin feature/your-feature
# Open a Pull Request
```

Use [Conventional Commits](https://conventionalcommits.org) · Run `flutter analyze` and `black` before pushing.

---

## 📄 License

MIT © [Neelam Nagar](https://github.com/neelam-nagar)

---

<div align="center">

Made with ❤️ for the farmers of Rajasthan 🌾

⭐ **Star this repo if it helped you!**

[![GitHub stars](https://img.shields.io/github/stars/neelam-nagar/KrishiMitra-AI?style=social)](https://github.com/neelam-nagar/KrishiMitra-AI)

</div>
