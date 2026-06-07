"""
KrishiMitra AI — Unified Production Backend
============================================
Single FastAPI application serving all modules:

  POST /api/chat           → AI chatbot (Gemini)
  GET  /api/weather        → Weather (district/tehsil/village)
  GET  /api/weather/districts    → list districts
  GET  /api/weather/tehsils      → list tehsils for a district
  GET  /api/weather/villages     → list villages for a tehsil
  GET  /api/mandi          → Crop prices
  GET  /api/mandi/districts
  GET  /api/mandi/mandis
  GET  /api/mandi/crops
  GET  /api/schemes        → Government schemes list
  GET  /api/schemes/{id}   → Scheme detail
  POST /api/disease/predict       → Crop disease (file upload)
  POST /api/disease/predict-base64→ Crop disease (base64)
  GET  /api/health         → Health check
  GET  /api/compensation/calculate → Compensation estimate

Run:
  uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

import os
import re
import json
import base64
import io
import logging
from contextlib import asynccontextmanager
from typing import Optional, Any

import requests
from fastapi import FastAPI, HTTPException, UploadFile, File, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, field_validator
from dotenv import load_dotenv

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)
log = logging.getLogger("krishimitra")

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
BASE_DIR = os.path.dirname(os.path.abspath(__file__))


# ---------------------------------------------------------------------------
# Data loading helpers
# ---------------------------------------------------------------------------

def _load_json(filename: str) -> Any:
    path = os.path.join(BASE_DIR, filename)
    if not os.path.exists(path):
        log.warning(f"Data file not found: {path}")
        return None
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


# ---------------------------------------------------------------------------
# Module-level data stores (loaded once at startup)
# ---------------------------------------------------------------------------

MANDI_DATA: list = []
WEATHER_DATA: dict = {}
SCHEME_DATA: list = []

# ---------------------------------------------------------------------------
# AI model (lazy-loaded)
# ---------------------------------------------------------------------------
_genai_model = None


def get_genai_model():
    global _genai_model
    if _genai_model is not None:
        return _genai_model
    if not GEMINI_API_KEY:
        return None
    try:
        import google.generativeai as genai  # type: ignore
        genai.configure(api_key=GEMINI_API_KEY)
        # Use stable model name - gemini-1.5-flash is the correct current model
        _genai_model = genai.GenerativeModel("gemini-1.5-flash")
        log.info("Gemini model loaded")
        return _genai_model
    except Exception as e:
        log.error(f"Failed to load Gemini model: {e}")
        return None


# ---------------------------------------------------------------------------
# ML Disease model (lazy-loaded — heavy, only if torch is available)
# ---------------------------------------------------------------------------
_disease_model = None
_disease_transform = None
DISEASE_CLASSES = [
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
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'आलू_Late_Blight': {
        'hindi': 'आलू - पछेती झुलसा', 'severity': 'High 🔴',
        'pesticides': [
            {'naam': 'Metalaxyl + Mancozeb', 'matra': '2.5 gram/litre paani', 'kimat': '₹450/kg'},
            {'naam': 'Cymoxanil 8% + Mancozeb 64%', 'matra': '3 gram/litre paani', 'kimat': '₹380/kg'},
        ],
        'spray': 'Har 5-7 din mein',
        'savdhani': 'Baarish ke baad zaroor spray karein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'आलू_Healthy': {
        'hindi': 'आलू - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'टमाटर_Early_Blight': {
        'hindi': 'टमाटर - अगेती झुलसा', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
            {'naam': 'Iprodione 50% WP', 'matra': '2 gram/litre paani', 'kimat': '₹520/kg'},
        ],
        'spray': 'Har 7 din mein', 'savdhani': 'Gili pattiyaan hatayein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'टमाटर_Late_Blight': {
        'hindi': 'टमाटर - पछेती झुलसा', 'severity': 'High 🔴',
        'pesticides': [
            {'naam': 'Metalaxyl + Mancozeb', 'matra': '2.5 gram/litre paani', 'kimat': '₹450/kg'},
            {'naam': 'Fenamidone 10% + Mancozeb 50%', 'matra': '3 gram/litre paani', 'kimat': '₹680/kg'},
        ],
        'spray': 'Har 5 din mein', 'savdhani': 'Infected patte turant hatayein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'टमाटर_Healthy': {
        'hindi': 'टमाटर - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'मक्का_Blight': {
        'hindi': 'मक्का - झुलसा रोग', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Mancozeb 75% WP', 'matra': '2.5 gram/litre paani', 'kimat': '₹180/kg'},
            {'naam': 'Zineb 75% WP', 'matra': '2 gram/litre paani', 'kimat': '₹210/kg'},
        ],
        'spray': 'Har 10 din mein', 'savdhani': 'Beej upchar zaroor karein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'मक्का_Rust': {
        'hindi': 'मक्का - रतुआ रोग', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Propiconazole 25% EC', 'matra': '1 ml/litre paani', 'kimat': '₹650/litre'},
            {'naam': 'Tebuconazole 25.9% EC', 'matra': '1 ml/litre paani', 'kimat': '₹780/litre'},
        ],
        'spray': 'Har 7-10 din mein', 'savdhani': 'Nami kam rakhein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'मक्का_Healthy': {
        'hindi': 'मक्का - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'मिर्च_Bacterial_Spot': {
        'hindi': 'मिर्च - जीवाणु धब्बा', 'severity': 'Moderate ⚠️',
        'pesticides': [
            {'naam': 'Copper Oxychloride 50% WP', 'matra': '3 gram/litre paani', 'kimat': '₹280/kg'},
            {'naam': 'Streptomycin + Tetracycline', 'matra': '1 gram/litre paani', 'kimat': '₹420/kg'},
        ],
        'spray': 'Har 7 din mein', 'savdhani': 'Paani ka chhidkav pattiyaan par na karein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'मिर्च_Healthy': {
        'hindi': 'मिर्च - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
    'सोयाबीन_Healthy': {
        'hindi': 'सोयाबीन - स्वस्थ पत्ती ✅', 'severity': 'Healthy ✅',
        'pesticides': [], 'spray': 'Koi zaroorat nahi',
        'savdhani': 'Fasal ki regular nigrani karte rahein',
        'helpline': [{'naam': 'Kisan Call Center', 'number': '1800-180-1551'}],
    },
}


def get_disease_model():
    global _disease_model, _disease_transform
    if _disease_model is not None:
        return _disease_model, _disease_transform
    try:
        import torch
        import torchvision.transforms as transforms
        from torchvision import models
        from torch import nn

        model_path = os.path.join(BASE_DIR, "model", "rajasthan_crop_model.pth")
        if not os.path.exists(model_path):
            log.warning("Disease model file not found")
            return None, None

        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        model = models.efficientnet_b0(weights=None)
        model.classifier[1] = nn.Linear(model.classifier[1].in_features, len(DISEASE_CLASSES))
        checkpoint = torch.load(model_path, map_location=device, weights_only=False)
        model.load_state_dict(checkpoint['model_state_dict'])
        model.to(device)
        model.eval()

        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])

        _disease_model = (model, device)
        _disease_transform = transform
        log.info("Disease model loaded")
        return _disease_model, _disease_transform
    except ImportError:
        log.warning("PyTorch not installed — disease detection disabled")
        return None, None
    except Exception as e:
        log.error(f"Failed to load disease model: {e}")
        return None, None


# ---------------------------------------------------------------------------
# Lifespan — load data once at startup
# ---------------------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    global MANDI_DATA, WEATHER_DATA, SCHEME_DATA
    log.info("Loading data files...")
    mandi = _load_json("mandi_cache.json")
    MANDI_DATA = mandi if isinstance(mandi, list) else []
    weather = _load_json("final_clean.json")
    WEATHER_DATA = weather if isinstance(weather, dict) else {}
    scheme = _load_json("scheme.json")
    SCHEME_DATA = scheme if isinstance(scheme, list) else []
    log.info(f"Loaded: {len(MANDI_DATA)} mandi records, "
             f"{len(WEATHER_DATA.get('districts', []))} weather districts, "
             f"{len(SCHEME_DATA)} schemes")
    # Pre-warm models in background
    get_genai_model()
    yield
    log.info("Shutting down KrishiMitra backend")


# ---------------------------------------------------------------------------
# App
# ---------------------------------------------------------------------------

app = FastAPI(
    title="KrishiMitra AI Backend",
    description="Unified API for the KrishiMitra farmer intelligence platform",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Health
# ---------------------------------------------------------------------------

@app.get("/api/health", tags=["System"])
def health():
    return {
        "status": "ok",
        "version": "2.0.0",
        "modules": {
            "chat": bool(GEMINI_API_KEY),
            "weather": bool(WEATHER_DATA),
            "mandi": bool(MANDI_DATA),
            "schemes": bool(SCHEME_DATA),
        },
    }


# ---------------------------------------------------------------------------
# CHATBOT
# ---------------------------------------------------------------------------

CHATBOT_INSTRUCTION = """
You are KrishiMitra-AI, an intelligent assistant for Indian farmers in Rajasthan.

Rules:
- Never guess real-time data (prices, weather, land records)
- If unsure → say: "⚠️ इस विषय पर सटीक जानकारी अभी उपलब्ध नहीं है। कृपया संबंधित मॉड्यूल में देखें।"
- Give short, practical advice in Hindi
- Use only 2–3 bullet points with ✅ ⚠️ 💡
- Each bullet must be ONE complete sentence ending with ।
- Never leave any sentence incomplete
- When mentioning days, always use small realistic numbers (e.g. 20-25 दिन)

Behavior:
- For general farming advice → answer directly with bullets
- For real-time data (weather/prices/land) → redirect to the appropriate module
- For both → give advice AND suggest the module
"""

CHAT_HISTORY_INIT = [
    {"role": "user", "parts": [CHATBOT_INSTRUCTION]},
    {"role": "model", "parts": ["✅ Samajh gaya। Main hamesha 2-3 poore bullets mein jawab dunga।"]},
]

# Per-session chat objects (in-memory, keyed by session_id)
_chat_sessions: dict = {}

MODULE_INTENTS = {
    "weather": ["weather", "barish", "mausam", "बारिश", "मौसम", "बरसात", "tufan", "तूफान"],
    "mandi": ["bhav", "price", "mandi", "भाव", "मंडी", "daam", "दाम", "बाज़ार", "बाजार"],
    "scheme": ["yojana", "scheme", "योजना", "subsidy", "सब्सिडी", "sarkar", "सरकार"],
    "loan": ["loan", "लोन", "karz", "कर्ज", "उधार", "rin", "ऋण"],
    "land": ["zameen", "land", "जमीन", "ज़मीन", "khasra", "खसरा", "bhoomi", "भूमि"],
    "disease": ["bimari", "keede", "बीमारी", "कीड़े", "rog", "रोग", "pest", "फसल रोग"],
}

MODULE_RESPONSES = {
    "weather": "🌦️ सटीक मौसम जानकारी के लिए Weather Module खोलें। वहाँ आपको वर्तमान मौसम और अगले 7 दिनों का पूर्वानुमान मिलेगा।",
    "mandi": "💰 ताज़ा मंडी भाव देखने के लिए Crop Price Module खोलें। यहाँ आपको विभिन्न फसलों के अपडेटेड बाजार भाव मिलेंगे।",
    "scheme": "📋 सरकारी योजनाओं की पूरी जानकारी के लिए Government Schemes Module देखें। यहाँ पात्रता, लाभ और आवेदन प्रक्रिया उपलब्ध है।",
    "loan": "🏦 कृषि लोन से जुड़ी जानकारी के लिए Kisan Loan Guide खोलें। यहाँ आपको सही विकल्प और आवेदन प्रक्रिया समझाई गई है।",
    "land": "📍 जमीन से संबंधित जानकारी के लिए Land Records Module खोलें। यहाँ आप अपने भूमि रिकॉर्ड और विवरण देख सकते हैं।",
    "disease": "🌱 फसल की बीमारी पहचानने के लिए Crop Disease Module में फोटो अपलोड करें। आपको तुरंत सही पहचान और उपचार के सुझाव मिलेंगे।",
}


def detect_intent(msg: str) -> Optional[str]:
    lower = msg.lower()
    for intent, keywords in MODULE_INTENTS.items():
        if any(kw in lower for kw in keywords):
            return intent
    return None


def _fix_bad_numbers(text: str) -> str:
    def _replace(match):
        num = int(match.group(1))
        unit = match.group(2)
        if num > 100:
            s = str(num)
            fixed = f"{s[:2]}-{s[2:4] if len(s) >= 4 else s[2:]}"
            return f"{fixed} {unit}"
        return match.group(0)
    return re.sub(r'(\d{3,4})\s*(दिन|din|days|दिनों)', _replace, text)


def _clean_output(raw: str) -> list[str]:
    text = re.sub(r'[*#•\-–]', '', raw).strip()
    text = _fix_bad_numbers(text)
    lines, clean = text.split("\n"), []
    for line in lines:
        line = line.strip()
        if not line or len(line) < 6:
            continue
        if not (line.startswith("✅") or line.startswith("💡") or line.startswith("⚠️")):
            continue
        if line[-1] not in ["।", ".", "!", "?"]:
            line += "।"
        clean.append(line)
        if len(clean) == 3:
            break
    if not clean:
        parts = re.split(r'(?<=[।.])\s+', text)
        for p in parts:
            p = p.strip()
            if len(p) > 8:
                if p[-1] not in ["।", "."]:
                    p += "।"
                clean.append(p)
            if len(clean) == 3:
                break
    return clean


class ChatRequest(BaseModel):
    question: str
    session_id: str = "default"

    @field_validator("question")
    @classmethod
    def validate_question(cls, v):
        v = v.strip()
        if not v:
            raise ValueError("Question cannot be empty")
        if len(v) > 1000:
            raise ValueError("Question too long (max 1000 chars)")
        return v


@app.post("/api/chat", tags=["Chatbot"])
def chat(data: ChatRequest):
    intent = detect_intent(data.question)
    if intent:
        return {"status": "success", "answer": MODULE_RESPONSES[intent], "intent": intent}

    model = get_genai_model()
    if model is None:
        return {
            "status": "error",
            "answer": "⚠️ AI सेवा अभी उपलब्ध नहीं है। कृपया GEMINI_API_KEY सेट करें।",
        }

    try:
        # Get or create session
        session = _chat_sessions.get(data.session_id)
        if session is None:
            session = model.start_chat(history=list(CHAT_HISTORY_INIT))
            _chat_sessions[data.session_id] = session

        response = session.send_message(
            data.question,
            generation_config={"max_output_tokens": 250, "temperature": 0.2},
        )

        # Trim history to avoid context bloat
        if len(session.history) > 10:
            session.history = session.history[-10:]

        lines = _clean_output(response.text)
        answer = "\n".join(lines) if lines else (
            "⚠️ उत्तर सही format में नहीं आया।\n"
            "💡 अपना सवाल फिर से clearly लिखें।\n"
            "✅ या Kisan Helpline 1551 पर call करें।"
        )
        return {"status": "success", "answer": answer}

    except Exception as e:
        log.error(f"Chat error: {e}")
        return {
            "status": "error",
            "answer": "⚠️ अभी सेवा उपलब्ध नहीं है। कृपया थोड़ी देर बाद पुनः प्रयास करें।",
        }


# ---------------------------------------------------------------------------
# WEATHER
# ---------------------------------------------------------------------------

def _get_current_weather(lat: float, lon: float) -> Optional[dict]:
    try:
        url = (
            f"https://api.open-meteo.com/v1/forecast?"
            f"latitude={lat}&longitude={lon}"
            f"&current=temperature_2m,relative_humidity_2m,rain,wind_speed_10m"
        )
        res = requests.get(url, timeout=10).json()
        if "current" not in res:
            return None
        return {
            "temperature": res["current"].get("temperature_2m"),
            "humidity": res["current"].get("relative_humidity_2m"),
            "rain": res["current"].get("rain"),
            "wind": res["current"].get("wind_speed_10m"),
        }
    except Exception as e:
        log.error(f"Weather current error: {e}")
        return None


def _get_7day_forecast(lat: float, lon: float) -> list:
    try:
        url = (
            f"https://api.open-meteo.com/v1/forecast?"
            f"latitude={lat}&longitude={lon}"
            f"&daily=temperature_2m_max,temperature_2m_min,rain_sum"
            f"&timezone=auto"
        )
        res = requests.get(url, timeout=10).json()
        forecast = []
        daily = res.get("daily", {})
        for i in range(len(daily.get("time", []))):
            tmax = daily["temperature_2m_max"][i]
            tmin = daily["temperature_2m_min"][i]
            rain = daily["rain_sum"][i]
            condition = "Rainy" if rain > 0 else ("Sunny" if tmax >= 30 else "Cloudy")
            forecast.append({
                "date": daily["time"][i],
                "highTemp": tmax,
                "lowTemp": tmin,
                "rainfallProbability": rain,
                "humidity": 0,
                "condition": condition,
            })
        return forecast
    except Exception as e:
        log.error(f"Weather forecast error: {e}")
        return []


def _get_hourly_forecast(lat: float, lon: float) -> list:
    try:
        url = (
            f"https://api.open-meteo.com/v1/forecast?"
            f"latitude={lat}&longitude={lon}"
            f"&hourly=temperature_2m,rain"
            f"&forecast_days=1&timezone=auto"
        )
        res = requests.get(url, timeout=10).json()
        hourly = res.get("hourly", {})
        return [
            {"time": hourly["time"][i], "temperature": hourly["temperature_2m"][i], "rain": hourly["rain"][i]}
            for i in range(len(hourly.get("time", [])))
        ]
    except Exception as e:
        log.error(f"Hourly forecast error: {e}")
        return []


@app.get("/api/weather/districts", tags=["Weather"])
def weather_districts():
    districts = WEATHER_DATA.get("districts", [])
    return {"districts": [d["district"] for d in districts]}


@app.get("/api/weather/tehsils", tags=["Weather"])
def weather_tehsils(district: str = Query(...)):
    districts = WEATHER_DATA.get("districts", [])
    d = next((x for x in districts if x["district"].lower() == district.lower()), None)
    if not d:
        return {"tehsils": []}
    return {"tehsils": [t["tehsil"] for t in d.get("tehsils", [])]}


@app.get("/api/weather/villages", tags=["Weather"])
def weather_villages(district: str = Query(...), tehsil: str = Query(...)):
    districts = WEATHER_DATA.get("districts", [])
    d = next((x for x in districts if x["district"].lower() == district.lower()), None)
    if not d:
        return {"villages": []}
    t = next((x for x in d.get("tehsils", []) if x["tehsil"].lower() == tehsil.lower()), None)
    if not t:
        return {"villages": []}
    return {"villages": [v["village"] for v in t.get("villages", []) if isinstance(v, dict)]}


@app.get("/api/weather", tags=["Weather"])
def weather(
    district: str = Query(...),
    tehsil: str = Query(...),
    village: str = Query(...),
):
    districts = WEATHER_DATA.get("districts", [])
    d_obj = next((x for x in districts if x["district"].lower() == district.lower()), None)
    if not d_obj:
        raise HTTPException(status_code=404, detail="District not found")
    t_obj = next((x for x in d_obj.get("tehsils", []) if x["tehsil"].lower() == tehsil.lower()), None)
    if not t_obj:
        raise HTTPException(status_code=404, detail="Tehsil not found")
    v_obj = next(
        (x for x in t_obj.get("villages", [])
         if isinstance(x, dict) and x.get("village", "").lower() == village.lower()),
        None,
    )
    if not v_obj:
        raise HTTPException(status_code=404, detail="Village not found")

    lat, lon = float(v_obj["lat"]), float(v_obj["lon"])
    current = _get_current_weather(lat, lon)
    if current is None:
        raise HTTPException(status_code=503, detail="Weather service unavailable")

    return {
        "location": {"state": "Rajasthan", "district": district, "tehsil": tehsil, "village": village},
        "current": current,
        "hourly": _get_hourly_forecast(lat, lon)[:6],
        "forecast": _get_7day_forecast(lat, lon),
    }


# ---------------------------------------------------------------------------
# MANDI / CROP PRICES
# ---------------------------------------------------------------------------

CROP_MAP = {
    "wheat": "गेहूं", "rice": "चावल", "onion": "प्याज",
    "potato": "आलू", "soybean": "सोयाबीन", "mustard": "सरसों",
    "maize": "मक्का", "gram": "चना", "cotton": "कपास",
}


@app.get("/api/mandi/districts", tags=["Mandi"])
def mandi_districts():
    return {"districts": sorted(set(r["district"].strip() for r in MANDI_DATA))}


@app.get("/api/mandi/mandis", tags=["Mandi"])
def mandi_mandis(district: str = Query(...)):
    dl = district.lower()
    return {
        "mandis": sorted(set(
            r["mandi"].strip() for r in MANDI_DATA
            if dl in r["district"].strip().lower()
        ))
    }


@app.get("/api/mandi/crops", tags=["Mandi"])
def mandi_crops(district: str = Query(...), mandi: str = Query(...)):
    dl, ml = district.lower(), mandi.lower()
    return {
        "crops": sorted(set(
            r["crop"].strip() for r in MANDI_DATA
            if dl in r["district"].strip().lower() and ml in r["mandi"].strip().lower()
        ))
    }


@app.get("/api/mandi", tags=["Mandi"])
def mandi_price(
    district: str = Query(...),
    mandi: str = Query(...),
    crop: str = Query(...),
):
    dl, ml = district.strip().lower(), mandi.strip().lower()
    crop_q = CROP_MAP.get(crop.strip().lower(), crop.strip())
    cl = crop_q.lower()

    records = [
        r for r in MANDI_DATA
        if dl in r["district"].strip().lower()
        and ml in r["mandi"].strip().lower()
        and (cl in r["crop"].strip().lower() or cl in r["crop"].strip())
    ][:6]

    if not records:
        raise HTTPException(status_code=404, detail="No price data found for the given district/mandi/crop")

    prices = []
    for r in records:
        raw = str(r.get("max", "0"))
        cleaned = raw.replace("Rs", "").replace("₹", "").replace("/ क्विंटल", "").replace("/ Quintal", "").strip()
        try:
            price = int(float(cleaned))
        except ValueError:
            price = 0
        prices.append({"date": r["date"], "price": price})

    vals = [p["price"] for p in prices if p["price"] > 0]
    return {
        "district": district,
        "mandi": mandi,
        "crop": crop_q,
        "minPrice": min(vals) if vals else 0,
        "maxPrice": max(vals) if vals else 0,
        "avgPrice": sum(vals) // len(vals) if vals else 0,
        "prices": prices,
    }


# ---------------------------------------------------------------------------
# GOVERNMENT SCHEMES
# ---------------------------------------------------------------------------

@app.get("/api/schemes", tags=["Schemes"])
def schemes_list(lang: str = Query("en")):
    result = []
    for i, s in enumerate(SCHEME_DATA):
        name = s.get("name", {})
        result.append({
            "id": i,
            "name": name.get(lang) or name.get("en", ""),
            "type": s.get("type", ""),
            "link": s.get("link", ""),
        })
    return {"schemes": result}


@app.get("/api/schemes/{scheme_id}", tags=["Schemes"])
def scheme_detail(scheme_id: int, lang: str = Query("en")):
    if scheme_id < 0 or scheme_id >= len(SCHEME_DATA):
        raise HTTPException(status_code=404, detail="Scheme not found")
    s = SCHEME_DATA[scheme_id]

    def t(obj):
        if isinstance(obj, dict):
            return obj.get(lang) or obj.get("en", "")
        return str(obj)

    return {
        "id": scheme_id,
        "name": t(s.get("name", {})),
        "type": s.get("type", ""),
        "link": s.get("link", ""),
        "eligibility": t(s.get("eligibility", {})),
        "docs": [t(d) for d in s.get("docs", [])],
        "apply_process": t(s.get("apply_process", {})),
    }


# ---------------------------------------------------------------------------
# CROP DISEASE DETECTION
# ---------------------------------------------------------------------------

def _run_disease_prediction(image_bytes: bytes) -> dict:
    from PIL import Image  # type: ignore

    model_data, transform = get_disease_model()
    if model_data is None:
        raise HTTPException(status_code=503, detail="Disease detection model not available")

    import torch
    model, device = model_data
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    tensor = transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        outputs = model(tensor)
        probs = torch.softmax(outputs, dim=1)[0]
        conf, idx = probs.max(0)

    label = DISEASE_CLASSES[idx.item()]
    confidence = conf.item() * 100
    info = PESTICIDE_DB[label]

    return {
        "success": True,
        "label": label,
        "hindi": info["hindi"],
        "confidence": round(confidence, 2),
        "severity": info["severity"],
        "pesticides": info["pesticides"],
        "spray": info["spray"],
        "savdhani": info["savdhani"],
        "helpline": info["helpline"],
        "is_healthy": len(info["pesticides"]) == 0,
    }


@app.post("/api/disease/predict", tags=["Crop Disease"])
async def predict_disease(image: UploadFile = File(...)):
    allowed = {"image/jpeg", "image/png", "image/jpg", "image/webp"}
    if image.content_type not in allowed:
        raise HTTPException(status_code=400, detail="Only JPEG/PNG images supported")
    data = await image.read()
    if len(data) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="Image too large (max 10MB)")
    try:
        return _run_disease_prediction(data)
    except HTTPException:
        raise
    except Exception as e:
        log.error(f"Disease prediction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


class Base64ImageRequest(BaseModel):
    image: str  # base64-encoded bytes


@app.post("/api/disease/predict-base64", tags=["Crop Disease"])
def predict_disease_base64(data: Base64ImageRequest):
    try:
        image_bytes = base64.b64decode(data.image)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid base64 data")
    try:
        return _run_disease_prediction(image_bytes)
    except HTTPException:
        raise
    except Exception as e:
        log.error(f"Disease prediction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ---------------------------------------------------------------------------
# COMPENSATION CALCULATOR
# ---------------------------------------------------------------------------

COMP_RATES = {
    "wheat":        {"pmfby": 30000, "sdrf": 13500},
    "mustard":      {"pmfby": 25000, "sdrf": 13500},
    "soybean":      {"pmfby": 20000, "sdrf": 6800},
    "gram":         {"pmfby": 22000, "sdrf": 6800},
    "maize":        {"pmfby": 20000, "sdrf": 6800},
    "rice":         {"pmfby": 25000, "sdrf": 6800},
    "cotton":       {"pmfby": 35000, "sdrf": 13500},
    "default":      {"pmfby": 20000, "sdrf": 6800},
}

CROP_NAMES_HI = {
    "गेहूं": "wheat", "सरसों": "mustard", "सोयाबीन": "soybean",
    "चना": "gram", "मक्का": "maize", "चावल": "rice", "कपास": "cotton",
}


@app.get("/api/compensation/calculate", tags=["Compensation"])
def compensation_calculate(
    crop: str = Query(..., description="Crop name (en or hi)"),
    damage_percent: float = Query(..., ge=0, le=100),
    cause: str = Query("other"),
):
    crop_key = CROP_NAMES_HI.get(crop.strip(), crop.strip().lower())
    rates = COMP_RATES.get(crop_key, COMP_RATES["default"])
    pmfby = round((damage_percent / 100) * rates["pmfby"], 2)
    sdrf = round((damage_percent / 100) * rates["sdrf"], 2)
    return {
        "crop": crop,
        "cause": cause,
        "damage_percent": damage_percent,
        "pmfby_per_hectare": pmfby,
        "sdrf_per_hectare": sdrf,
        "total_per_hectare": round(pmfby + sdrf, 2),
        "threshold_note": "Damage ≥ 33% typically required for PMFBY/SDRF claims",
        "disclaimer": "Indicative estimate only. Actual compensation depends on district notifications and official assessment.",
    }


# ---------------------------------------------------------------------------
# Root
# ---------------------------------------------------------------------------

@app.get("/", tags=["System"])
def root():
    return {
        "app": "KrishiMitra AI",
        "version": "2.0.0",
        "docs": "/docs",
        "health": "/api/health",
    }
