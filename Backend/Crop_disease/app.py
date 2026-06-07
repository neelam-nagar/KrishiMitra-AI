"""
KrishMitra AI — Crop Disease Detection API
Flask Backend — Flutter se connect karo
Run: python3 app.py
API URL: http://localhost:5000
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
import torchvision.transforms as transforms
from torchvision import models
from torch import nn
from PIL import Image
import io
import base64
import os

app = Flask(__name__)
CORS(app)  # Flutter se connect hone ke liye

# ── Device ────────────────────────────────────────────────────
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Device: {device}")

# ── Classes ───────────────────────────────────────────────────
CLASSES = [
    'आलू_Early_Blight',
    'आलू_Healthy',
    'आलू_Late_Blight',
    'टमाटर_Early_Blight',
    'टमाटर_Healthy',
    'टमाटर_Late_Blight',
    'मक्का_Blight',
    'मक्का_Healthy',
    'मक्का_Rust',
    'मिर्च_Bacterial_Spot',
    'मिर्च_Healthy',
    'सोयाबीन_Healthy',
]

# ── Pesticide Database ────────────────────────────────────────
PESTICIDE_DB = {
    'आलू_Early_Blight': {
        'hindi': 'आलू - अगेती झुलसा',
        'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
            {'naam': 'Chlorothalonil', 'matra': '2 gram/litre paani', 'kimat': '₹320/kg'},
        ],
        'spray': 'Har 7 din mein, subah ya shaam',
        'savdhani': 'Spray ke baad haath achhe se dhoyen',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'Rajasthan Krishi', 'number': '0141-2227849'},
        ]
    },
    'आलू_Late_Blight': {
        'hindi': 'आलू - पछेती झुलसा',
        'severity': 'High 🔴',
        'pesticides': [
            {'naam': 'Metalaxyl + Mancozeb', 'matra': '2.5 gram/litre paani', 'kimat': '₹450/kg'},
            {'naam': 'Cymoxanil 8% + Mancozeb 64%', 'matra': '3 gram/litre paani', 'kimat': '₹380/kg'},
        ],
        'spray': 'Har 5-7 din mein',
        'savdhani': 'Baarish ke baad zaroor spray karein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'CAZRI Jodhpur', 'number': '0291-2786584'},
        ]
    },
    'आलू_Healthy': {
        'hindi': 'आलू - स्वस्थ पत्ती ✅',
        'severity': 'Healthy ✅',
        'pesticides': [],
        'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
        ]
    },
    'टमाटर_Early_Blight': {
        'hindi': 'टमाटर - अगेती झुलसा',
        'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
            {'naam': 'Iprodione 50% WP', 'matra': '2 gram/litre paani', 'kimat': '₹520/kg'},
        ],
        'spray': 'Har 7 din mein',
        'savdhani': 'Gili pattiyaan hatayein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'Rajasthan Krishi', 'number': '0141-2227849'},
        ]
    },
    'टमाटर_Late_Blight': {
        'hindi': 'टमाटर - पछेती झुलसा',
        'severity': 'High 🔴',
        'pesticides': [
            {'naam': 'Metalaxyl + Mancozeb', 'matra': '2.5 gram/litre paani', 'kimat': '₹450/kg'},
            {'naam': 'Fenamidone 10% + Mancozeb 50%', 'matra': '3 gram/litre paani', 'kimat': '₹680/kg'},
        ],
        'spray': 'Har 5 din mein',
        'savdhani': 'Infected patte turant hatayein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'CAZRI Jodhpur', 'number': '0291-2786584'},
        ]
    },
    'टमाटर_Healthy': {
        'hindi': 'टमाटर - स्वस्थ पत्ती ✅',
        'severity': 'Healthy ✅',
        'pesticides': [],
        'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
        ]
    },
    'मक्का_Blight': {
        'hindi': 'मक्का - झुलसा रोग',
        'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
            {'naam': 'Zineb 75% WP', 'matra': '2 gram/litre paani', 'kimat': '₹210/kg'},
        ],
        'spray': 'Har 10 din mein',
        'savdhani': 'Beej upchar zaroor karein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'Kota Agriculture College', 'number': '0744-2470458'},
        ]
    },
    'मक्का_Rust': {
        'hindi': 'मक्का - रतुआ रोग',
        'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Propiconazole 25% EC', 'matra': '1 ml/litre paani', 'kimat': '₹650/litre'},
            {'naam': 'Tebuconazole 25.9% EC', 'matra': '1 ml/litre paani', 'kimat': '₹780/litre'},
        ],
        'spray': 'Har 7-10 din mein',
        'savdhani': 'Nami kam rakhein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'CAZRI Jodhpur', 'number': '0291-2786584'},
        ]
    },
    'मक्का_Healthy': {
        'hindi': 'मक्का - स्वस्थ पत्ती ✅',
        'severity': 'Healthy ✅',
        'pesticides': [],
        'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
        ]
    },
    'मिर्च_Bacterial_Spot': {
        'hindi': 'मिर्च - जीवाणु धब्बा',
        'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Copper Oxychloride 50% WP', 'matra': '3 gram/litre paani', 'kimat': '₹280/kg'},
            {'naam': 'Streptomycin + Tetracycline', 'matra': '1 gram/litre paani', 'kimat': '₹420/kg'},
        ],
        'spray': 'Har 7 din mein',
        'savdhani': 'Paani ka chhidkav pattiyaan par na karein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'NRCS Ajmer', 'number': '0145-2631639'},
        ]
    },
    'मिर्च_Healthy': {
        'hindi': 'मिर्च - स्वस्थ पत्ती ✅',
        'severity': 'Healthy ✅',
        'pesticides': [],
        'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
        ]
    },
    'सोयाबीन_Healthy': {
        'hindi': 'सोयाबीन - स्वस्थ पत्ती ✅',
        'severity': 'Healthy ✅',
        'pesticides': [],
        'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [
            {'naam': 'Kisan Call Center', 'number': '1800-180-1551'},
            {'naam': 'Kota Agriculture College', 'number': '0744-2470458'},
        ]
    },
}

# ── Model Load ────────────────────────────────────────────────
print("Loading KrishMitra AI model...")
model = models.efficientnet_b0(weights=None)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, 12)
checkpoint = torch.load(
    'model/rajasthan_crop_model.pth',
    map_location=device,
    weights_only=False
)
model.load_state_dict(checkpoint['model_state_dict'])
model.to(device)
model.eval()
print("✅ Model loaded!")

# ── Image Transform ───────────────────────────────────────────
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    ),
])

# ── Helper Function ───────────────────────────────────────────
def predict_image(image):
    img_tensor = transform(image).unsqueeze(0).to(device)
    with torch.no_grad():
        outputs = model(img_tensor)
        probs = torch.softmax(outputs, dim=1)[0]
        conf, idx = probs.max(0)
    label = CLASSES[idx.item()]
    confidence = conf.item() * 100
    info = PESTICIDE_DB[label]
    return label, confidence, info

# ── Routes ────────────────────────────────────────────────────

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'status': '✅ KrishMitra AI API running!',
        'version': '1.0',
        'crops': len(CLASSES),
        'endpoints': ['/predict', '/predict-base64', '/health']
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'model': 'loaded'})

# Flutter camera se direct image upload
@app.route('/predict', methods=['POST'])
def predict():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'Image nahi mili'}), 400

        file = request.files['image']
        image = Image.open(file.stream).convert('RGB')
        label, confidence, info = predict_image(image)

        return jsonify({
            'success': True,
            'label': label,
            'hindi': info['hindi'],
            'confidence': round(confidence, 2),
            'severity': info['severity'],
            'pesticides': info['pesticides'],
            'spray': info['spray'],
            'savdhani': info['savdhani'],
            'helpline': info['helpline'],
            'is_healthy': len(info['pesticides']) == 0
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Base64 image (Flutter mein camera se base64 encode karke bhejo)
@app.route('/predict-base64', methods=['POST'])
def predict_base64():
    try:
        data = request.get_json()
        if 'image' not in data:
            return jsonify({'error': 'Image nahi mili'}), 400

        # Base64 decode karo
        img_data = base64.b64decode(data['image'])
        image = Image.open(io.BytesIO(img_data)).convert('RGB')
        label, confidence, info = predict_image(image)

        return jsonify({
            'success': True,
            'label': label,
            'hindi': info['hindi'],
            'confidence': round(confidence, 2),
            'severity': info['severity'],
            'pesticides': info['pesticides'],
            'spray': info['spray'],
            'savdhani': info['savdhani'],
            'helpline': info['helpline'],
            'is_healthy': len(info['pesticides']) == 0
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=5001,
        debug=True
    )
