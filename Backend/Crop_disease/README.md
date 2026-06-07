# KrishMitra AI — Setup Instructions

## Folder Structure:
```
~/Desktop/Crop_disease/
    ├── model/
    │   └── rajasthan_crop_model.pth  ← Google Drive se download karo
    ├── app.py                         ← Flask API
    ├── requirements.txt               ← Dependencies
    └── crop_disease_screen.dart       ← Flutter code
```

## Step 1 — Install dependencies:
```bash
cd ~/Desktop/Crop_disease
pip install -r requirements.txt
```

## Step 2 — Model rakho:
```
Google Drive → Crop_Disease_Model →
rajasthan_crop_model.pth download karo →
~/Desktop/Crop_disease/model/ mein rakho
```

## Step 3 — Flask API chalao:
```bash
python3 app.py
```
API URL: http://localhost:5000

## Step 4 — Apna local IP dhundo:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```
Jaise: 192.168.1.100

## Step 5 — Flutter mein IP lagao:
```dart
# crop_disease_screen.dart mein:
const String API_URL = 'http://192.168.1.100:5000';
# Apna IP lagao yahan
```

## Step 6 — Flutter dependencies add karo:
```yaml
# pubspec.yaml mein add karo:
dependencies:
  image_picker: ^1.0.4
  http: ^1.1.0
```

## Test karo:
```bash
curl http://localhost:5000/health
# Response: {"model": "loaded", "status": "ok"}
```
