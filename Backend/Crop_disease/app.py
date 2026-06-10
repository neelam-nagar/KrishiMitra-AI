from flask import Flask, request, jsonify
from flask_cors import CORS
import onnxruntime as ort
import numpy as np
from PIL import Image
import io, base64, os

app = Flask(__name__)
CORS(app)

CLASSES = [
    'आलू_Early_Blight', 'आलू_Healthy', 'आलू_Late_Blight',
    'टमाटर_Early_Blight', 'टमाटर_Healthy', 'टमाटर_Late_Blight',
    'मक्का_Blight', 'मक्का_Healthy', 'मक्का_Rust',
    'मिर्च_Bacterial_Spot', 'मिर्च_Healthy', 'सोयाबीन_Healthy',
]

PESTICIDE_DB = {
    'आलू_Early_Blight': {
        'hindi': 'आलू - अगेती झुलसा', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
            {'naam': 'Chlorothalonil', 'matra': '2 gram/litre paani', 'kimat': '₹320/kg'},
        ],
        'spray': 'Har 7 din mein, subah ya shaam',
        'savdhani': 'Spray ke baad haath achhe se dhoyen',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'आलू_Late_Blight': {
        'hindi': 'आलू - पछेती झुलसा', 'severity': 'High 🔴',
        'pesticides': [
            {'naam': 'Metalaxyl + Mancozeb', 'matra': '2.5 gram/litre paani', 'kimat': '₹450/kg'},
        ],
        'spray': 'Har 5-7 din mein',
        'savdhani': 'Baarish ke baad zaroor spray karein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'आलू_Healthy': {
        'hindi': 'आलू - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'टमाटर_Early_Blight': {
        'hindi': 'टमाटर - अगेती झुलसा', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
        ],
        'spray': 'Har 7 din mein',
        'savdhani': 'Gili pattiyaan hatayein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'टमाटर_Late_Blight': {
        'hindi': 'टमाटर - पछेती झुलसा', 'severity': 'High 🔴',
        'pesticides': [
            {'naam': 'Metalaxyl + Mancozeb', 'matra': '2.5 gram/litre paani', 'kimat': '₹450/kg'},
        ],
        'spray': 'Har 5 din mein',
        'savdhani': 'Infected patte turant hatayein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'टमाटर_Healthy': {
        'hindi': 'टमाटर - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'मक्का_Blight': {
        'hindi': 'मक्का - झुलसा रोग', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
        ],
        'spray': 'Har 10 din mein',
        'savdhani': 'Beej upchar zaroor karein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'मक्का_Rust': {
        'hindi': 'मक्का - रतुआ रोग', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Propiconazole 25% EC', 'matra': '1 ml/litre paani', 'kimat': '₹650/litre'},
        ],
        'spray': 'Har 7-10 din mein',
        'savdhani': 'Nami kam rakhein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'मक्का_Healthy': {
        'hindi': 'मक्का - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'मिर्च_Bacterial_Spot': {
        'hindi': 'मिर्च - जीवाणु धब्बा', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Copper Oxychloride 50% WP', 'matra': '3 gram/litre paani', 'kimat': '₹280/kg'},
        ],
        'spray': 'Har 7 din mein',
        'savdhani': 'Paani pattiyaan par na karein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'मिर्च_Healthy': {
        'hindi': 'मिर्च - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
    'सोयाबीन_Healthy': {
        'hindi': 'सोयाबीन - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}]
    },
}

print("Loading model...")
session = ort.InferenceSession("model/crop_disease.onnx")
print("✅ Model loaded!")

def preprocess(image):
    img = image.resize((224, 224)).convert('RGB')
    arr = np.array(img, dtype=np.float32) / 255.0
    arr = (arr - [0.485, 0.456, 0.406]) / [0.229, 0.224, 0.225]
    arr = np.transpose(arr, (2, 0, 1))
    return np.expand_dims(arr, axis=0).astype(np.float32)

def run_predict(image):
    input_data = preprocess(image)
    outputs = session.run(None, {'input': input_data})
    probs = outputs[0][0]
    idx = int(np.argmax(probs))
    confidence = float(np.max(probs)) * 100
    if confidence < 85:
        return None, confidence, None
    label = CLASSES[idx]
    info = PESTICIDE_DB[label]
    return label, confidence, info

@app.route('/', methods=['GET'])
def home():
    return jsonify({'status': '✅ KrishiMitra API running!', 'crops': len(CLASSES)})

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'model': 'loaded'})

@app.route('/api/disease/predict', methods=['POST'])
def predict():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'Image nahi mili'}), 400
        image = Image.open(request.files['image'].stream).convert('RGB')
        label, confidence, info = run_predict(image)
        if label is None:
            return jsonify({
                'success': False,
                'error': 'Yeh fasal ki patti nahi lagti! Kripya fasal ki sahi photo lo.',
                'confidence': round(confidence, 2)
            }), 400
        return jsonify({
            'success': True, 'label': label,
            'hindi': info['hindi'], 'confidence': round(confidence, 2),
            'severity': info['severity'], 'pesticides': info['pesticides'],
            'spray': info['spray'], 'savdhani': info['savdhani'],
            'helpline': info['helpline'],
            'is_healthy': len(info['pesticides']) == 0
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/predict-base64', methods=['POST'])
def predict_base64():
    try:
        data = request.get_json()
        if 'image' not in data:
            return jsonify({'error': 'Image nahi mili'}), 400
        img_data = base64.b64decode(data['image'])
        image = Image.open(io.BytesIO(img_data)).convert('RGB')
        label, confidence, info = run_predict(image)
        if label is None:
            return jsonify({
                'success': False,
                'error': 'Yeh fasal ki patti nahi lagti! Kripya fasal ki sahi photo lo.',
                'confidence': round(confidence, 2)
            }), 400
        return jsonify({
            'success': True, 'label': label,
            'hindi': info['hindi'], 'confidence': round(confidence, 2),
            'severity': info['severity'], 'pesticides': info['pesticides'],
            'spray': info['spray'], 'savdhani': info['savdhani'],
            'helpline': info['helpline'],
            'is_healthy': len(info['pesticides']) == 0
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=False)
