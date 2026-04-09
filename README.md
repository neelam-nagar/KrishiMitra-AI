<div align="center">

# 🌾 KrishiMitra-AI

### *Empowering Farmers with the Power of Artificial Intelligence*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-Latest-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Google%20Gemini-API-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)
[![Made with ❤️ for Farmers](https://img.shields.io/badge/Made%20with%20%E2%9D%A4%EF%B8%8F-for%20Farmers-orange?style=flat-square)]()

<br/>

> **KrishiMitra-AI** is a comprehensive AI-powered mobile application built for Indian farmers — providing real-time weather updates, crop guidance, access to government schemes, plant disease detection, a farmer marketplace, and much more. All in one app, in the farmer's language.

<br/>

[📱 View Demo](#-demo) · [🐛 Report Bug](../../issues) · [✨ Request Feature](../../issues)

</div>

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation (Frontend)](#installation--flutter-frontend)
  - [Installation (Backend)](#installation--python-backend)
  - [Firebase Setup](#firebase-setup)
- [Usage Guide](#-usage-guide)
- [Project Structure](#-project-structure)
- [API Endpoints](#-api-endpoints)
- [Screenshots / Demo](#-demo)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🌱 About the Project

India has over **140 million farmers**, yet many lack access to timely information on weather, crop health, government aid, and market prices. **KrishiMitra-AI** bridges this gap by bringing an intelligent, multilingual, farmer-first digital assistant right to their fingertips.

Whether a farmer needs to check tomorrow's rain forecast, detect a disease in their wheat crop, apply for a government scheme, or sell their produce directly to buyers — KrishiMitra-AI makes it simple, fast, and accessible.

---

## ✨ Features

### 🔐 Authentication
- **Mobile OTP Login** — Secure and simple login using mobile number + OTP (via Firebase Auth)
- No email or password required — farmer-friendly onboarding

### 🌤️ Weather Forecast
- **Real-time weather** data for the farmer's location
- **7-day forecast** with temperature, rainfall, humidity, and wind speed
- Intelligent alerts for extreme weather events (storms, drought warnings)

### 🌾 Fasal (Crop) Guidance
- Crop-specific advice on sowing, irrigation, fertilizers, and harvesting
- Personalized recommendations based on region, season, and soil type
- AI-powered crop health tips via **Google Gemini API**

### 📋 Sarkari Yojna (Government Schemes)
- Browse and search all active government schemes for farmers
- Eligibility checker, application links, and deadline alerts
- State-wise and central scheme filtering

### 🌿 Organic Farming Guidance
- Step-by-step guides on transitioning to organic farming
- Natural pesticide and fertilizer recommendations
- Certification process walkthrough (PGS, NPOP)

### 🛒 Buyer & Seller Marketplace
- Direct-to-buyer produce listing — no middlemen
- Buyers can browse, filter, and contact sellers
- Price discovery and market rate display

### 💰 Muavja (Crop Compensation)
- Information on crop loss compensation schemes (PM Fasal Bima Yojana)
- Step-by-step claim filing guidance
- Real-time status tracking

### 🗺️ Bhulekh (Land Records)
- Access official state land records directly in-app
- Check khatauni, khasra number, and plot details
- State-wise Bhulekh portal integration

### 🔬 Plant Disease Detection
- **AI-powered image recognition** — snap a photo of a diseased plant
- Instant disease diagnosis with treatment recommendations
- Powered by Google Gemini Vision API

### 🏦 Farmer Loan Information
- Kisan Credit Card (KCC) guide and eligibility
- Bank-wise loan schemes for agriculture
- EMI calculator and interest rate comparator

### 💬 Community Chat
- Connect with other farmers, ask questions, share experiences
- Region-based and crop-based chat groups
- Moderated and farmer-safe environment

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter 3.x | Cross-platform mobile app (Android & iOS) |
| **Language** | Dart | Flutter application logic |
| **Backend** | Python 3.11+ | Server-side logic and AI integration |
| **API Framework** | FastAPI | High-performance REST API |
| **Authentication** | Firebase Auth | OTP-based mobile login |
| **Database** | Firebase Firestore | Real-time NoSQL database |
| **Storage** | Firebase Storage | Image uploads (disease detection, marketplace) |
| **AI / LLM** | Google Gemini API | Crop guidance, disease detection, chat AI |
| **Weather** | OpenWeatherMap API | Real-time and forecast weather data |
| **Notifications** | Firebase Cloud Messaging | Push notifications |

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed on your machine:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0 or above)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- [Python 3.11+](https://www.python.org/downloads/)
- [pip](https://pip.pypa.io/en/stable/)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A [Google Gemini API Key](https://ai.google.dev/)
- A [Firebase Project](https://console.firebase.google.com/)

---

### Installation — Flutter Frontend

1. **Clone the repository**

```bash
git clone https://github.com/neelam-nagar/KrishiMitra-AI.git
cd KrishiMitra-AI
```

2. **Navigate to the Flutter app directory**

```bash
cd krishimitra_app
```

3. **Install Flutter dependencies**

```bash
flutter pub get
```

4. **Configure Firebase**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

> This will generate `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) automatically.

5. **Add API Keys**

Create a `.env` file or update `lib/config/app_config.dart`:

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String weatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String backendBaseUrl = 'http://your-backend-url:8000';
}
```

6. **Run the app**

```bash
# For Android
flutter run

# For iOS (macOS required)
flutter run --device-id your_ios_device_id

# For specific device
flutter devices  # List devices
flutter run -d <device_id>
```

---

### Installation — Python Backend

1. **Navigate to the backend directory**

```bash
cd backend
```

2. **Create and activate a virtual environment**

```bash
python -m venv venv

# On macOS/Linux
source venv/bin/activate

# On Windows
venv\Scripts\activate
```

3. **Install dependencies**

```bash
pip install -r requirements.txt
```

4. **Set up environment variables**

Create a `.env` file in the `backend/` directory:

```env
GEMINI_API_KEY=your_google_gemini_api_key
WEATHER_API_KEY=your_openweathermap_api_key
FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json
SECRET_KEY=your_secret_key_here
DEBUG=True
```

5. **Add Firebase Service Account**

Download your Firebase service account JSON from:
`Firebase Console → Project Settings → Service Accounts → Generate New Private Key`

Save it as `backend/firebase-service-account.json`.

6. **Run the backend server**

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at: `http://localhost:8000`
Interactive API docs: `http://localhost:8000/docs`

---

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Enable the following services:
   - **Authentication** → Phone (OTP)
   - **Firestore Database**
   - **Storage**
   - **Cloud Messaging**
3. Add your app (Android/iOS) to the Firebase project.
4. Download and place configuration files as described in the Flutter setup above.

---

## 📖 Usage Guide

### For Farmers (End Users)

| Step | Action |
|---|---|
| 1 | Download and open the KrishiMitra-AI app |
| 2 | Enter your mobile number and verify OTP |
| 3 | Allow location access for weather & local schemes |
| 4 | Select your crops and region during onboarding |
| 5 | Explore the dashboard: Weather, Fasal, Yojna, Market & more |

### Disease Detection
1. Tap on **"Rog Pahchaan"** (Disease Detection) from the home screen
2. Take a photo or upload an image of the affected plant
3. Wait 2–5 seconds for AI analysis
4. View the disease name, cause, and recommended treatment

### Marketplace
1. **Sellers**: Tap **"Becho"** (Sell) → Add produce details, quantity, price, and photo
2. **Buyers**: Tap **"Kharido"** (Buy) → Browse listings by crop, location, or price

---

## 📁 Project Structure

```
KrishiMitra-AI/
│
├── 📱 krishimitra_app/              # Flutter Frontend
│   ├── lib/
│   │   ├── config/                  # App configuration & constants
│   │   ├── models/                  # Data models (Crop, User, Scheme, etc.)
│   │   ├── screens/                 # UI Screens
│   │   │   ├── auth/                # Login, OTP verification
│   │   │   ├── home/                # Dashboard & home screen
│   │   │   ├── weather/             # Weather forecast screen
│   │   │   ├── fasal/               # Crop guidance screens
│   │   │   ├── yojna/               # Government schemes
│   │   │   ├── marketplace/         # Buyer & seller screens
│   │   │   ├── disease/             # Plant disease detection
│   │   │   ├── community/           # Farmer community chat
│   │   │   ├── loan/                # Loan information
│   │   │   ├── muavja/              # Compensation details
│   │   │   └── bhulekh/             # Land records
│   │   ├── services/                # API services, Firebase, Gemini
│   │   ├── widgets/                 # Reusable UI components
│   │   ├── providers/               # State management (Provider/Riverpod)
│   │   └── utils/                   # Helpers, formatters, validators
│   ├── assets/                      # Images, icons, fonts, translations
│   ├── android/                     # Android-specific files
│   ├── ios/                         # iOS-specific files
│   └── pubspec.yaml                 # Flutter dependencies
│
├── 🐍 backend/                      # Python Backend
│   ├── main.py                      # FastAPI app entry point
│   ├── routers/                     # API route handlers
│   │   ├── auth.py                  # OTP & authentication routes
│   │   ├── weather.py               # Weather API routes
│   │   ├── crops.py                 # Crop guidance routes
│   │   ├── schemes.py               # Government scheme routes
│   │   ├── marketplace.py           # Marketplace routes
│   │   ├── disease.py               # Disease detection routes
│   │   └── community.py             # Community chat routes
│   ├── services/                    # Business logic & external API calls
│   │   ├── gemini_service.py        # Google Gemini integration
│   │   ├── weather_service.py       # OpenWeatherMap integration
│   │   └── firebase_service.py      # Firebase Admin SDK
│   ├── models/                      # Pydantic request/response models
│   ├── utils/                       # Utility functions
│   ├── firebase-service-account.json # Firebase credentials (gitignored)
│   ├── requirements.txt             # Python dependencies
│   └── .env                         # Environment variables (gitignored)
│
├── 📄 README.md
├── 📄 CONTRIBUTING.md
└── 📄 LICENSE
```

---

## 🔌 API Endpoints

Base URL: `http://your-backend-url:8000/api/v1`

### 🔐 Authentication

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/send-otp` | Send OTP to mobile number |
| `POST` | `/auth/verify-otp` | Verify OTP and issue token |
| `POST` | `/auth/refresh-token` | Refresh authentication token |

### 🌤️ Weather

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/weather/current?lat={lat}&lon={lon}` | Get current weather |
| `GET` | `/weather/forecast?lat={lat}&lon={lon}` | Get 7-day forecast |

### 🌾 Crops (Fasal)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/crops/` | List all crops |
| `GET` | `/crops/{crop_id}` | Get crop details & guidance |
| `POST` | `/crops/advice` | Get AI-powered crop advice |

### 📋 Schemes (Yojna)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/schemes/` | List all schemes |
| `GET` | `/schemes/{state}` | Get state-specific schemes |
| `GET` | `/schemes/{id}` | Get scheme details |

### 🔬 Disease Detection

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/disease/detect` | Upload plant image for AI diagnosis |

**Request:**
```json
{
  "image": "<base64_encoded_image>"
}
```

**Response:**
```json
{
  "disease_name": "Leaf Blight",
  "confidence": 0.94,
  "description": "Fungal infection causing yellowing of leaves...",
  "treatment": ["Apply Mancozeb fungicide...", "Remove infected leaves..."],
  "prevention": ["Ensure proper drainage...", "Avoid overhead irrigation..."]
}
```

### 🛒 Marketplace

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/marketplace/listings` | Browse all listings |
| `POST` | `/marketplace/listings` | Create a new listing (seller) |
| `GET` | `/marketplace/listings/{id}` | Get listing details |
| `DELETE` | `/marketplace/listings/{id}` | Delete a listing |

### 💬 Community

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/community/groups` | List community groups |
| `GET` | `/community/groups/{id}/messages` | Get group messages |
| `POST` | `/community/groups/{id}/messages` | Post a message |

> 📘 Full interactive API documentation is available at `http://localhost:8000/docs` when the backend server is running.

---

## 📸 Demo

> 📷 Screenshots and demo video coming soon!

| Home Dashboard | Weather Forecast | Disease Detection |
|---|---|---|
| ![Home](assets/screenshots/home_placeholder.png) | ![Weather](assets/screenshots/weather_placeholder.png) | ![Disease](assets/screenshots/disease_placeholder.png) |

| Marketplace | Government Schemes | Community Chat |
|---|---|---|
| ![Market](assets/screenshots/market_placeholder.png) | ![Schemes](assets/screenshots/schemes_placeholder.png) | ![Community](assets/screenshots/community_placeholder.png) |

> 🎥 **Demo Video**: [Watch on YouTube](#) *(Coming Soon)*

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**! 🙏

### How to Contribute

1. **Fork** the repository

```bash
git clone https://github.com/neelam-nagar/KrishiMitra-AI.git
```

2. **Create your feature branch**

```bash
git checkout -b feature/AmazingFeature
```

3. **Make your changes and commit**

```bash
git add .
git commit -m "feat: Add some AmazingFeature"
```

> Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

4. **Push to the branch**

```bash
git push origin feature/AmazingFeature
```

5. **Open a Pull Request** on GitHub

### Contribution Guidelines

- 🐛 **Bug Reports**: Open an issue with the `bug` label and include reproduction steps
- ✨ **Feature Requests**: Open an issue with the `enhancement` label
- 💻 **Code Style**: Follow Flutter/Dart linting rules and Python PEP8
- 🧪 **Tests**: Add tests for new features where applicable
- 📖 **Documentation**: Update the README or add inline comments for any new functionality

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

```
MIT License — Copyright (c) 2024 KrishiMitra-AI Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 📬 Contact

**Project Maintainer** — Neelam Nagar

📧 Email: your-real-email@gmail.com  
🐙 GitHub: https://github.com/neelam-nagar  
🔗 LinkedIn: https://www.linkedin.com/in/neelamnagar/

**Project Link**: [KrishiMitra-AI](https://github.com/neelam-nagar/KrishiMitra-AI)
---

<div align="center">

Made with ❤️ for the Farmers of India 🇮🇳

*"जय किसान — Jai Kisan"*

⭐ Star this repo if you found it helpful!

</div>
