from fastapi import FastAPI
from pydantic import BaseModel
import google.generativeai as genai
from dotenv import load_dotenv
import os
import re

# 🔐 API Key
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise Exception("GEMINI_API_KEY nahi mili")


genai.configure(api_key=API_KEY)
model = genai.GenerativeModel("gemini-3.1-flash-lite-preview")

# 🚀 FastAPI
app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Query(BaseModel):
    question: str


# =========================
# 🧠 YOUR ORIGINAL CODE
# =========================

instruction = """
You are KrishiMitra-AI, an intelligent assistant for farmers.

Rules:
- Never guess data
- If unsure → say: "⚠️ इस विषय पर सटीक जानकारी अभी उपलब्ध नहीं है। कृपया संबंधित मॉड्यूल में देखें।"
- Give short, practical advice in Hindi
- Use only 2–3 bullet points with ✅ ⚠️ 💡
- Each bullet must be ONE complete sentence ending with ।
- Never leave any sentence incomplete
"""

history = [
    {"role": "user",  "parts": [instruction]},
    {"role": "model", "parts": ["✅ Samajh gaya। Main hamesha 2-3 poore bullets mein jawab dunga।"]}
]

chat = model.start_chat(history=history)


def detect_intent(user_msg):
    msg = user_msg.lower()
    if any(w in msg for w in ["weather","barish","mausam","बारिश","मौसम"]): return "weather"
    if any(w in msg for w in ["bhav","price","mandi","भाव","मंडी","daam","दाम"]): return "mandi"
    if any(w in msg for w in ["yojana","scheme","योजना","subsidy"]): return "scheme"
    if any(w in msg for w in ["loan","लोन","karz","कर्ज"]): return "loan"
    if any(w in msg for w in ["zameen","land","जमीन","ज़मीन"]): return "land"
    if any(w in msg for w in ["bimari","keede","बीमारी","कीड़े"]): return "disease"
    return "ai"


def module_response(intent):
    responses = {
        "weather": "🌦️ सटीक मौसम जानकारी के लिए Weather Module खोलें। वहाँ आपको वर्तमान मौसम और अगले 7 दिनों का पूर्वानुमान मिलेगा।",
        "mandi": "💰 ताज़ा मंडी भाव देखने के लिए Mandi Price Module खोलें। यहाँ आपको विभिन्न फसलों के अपडेटेड बाजार भाव मिलेंगे।",
        "scheme": "📋 सरकारी योजनाओं की पूरी जानकारी के लिए Government Schemes Module देखें। यहाँ पात्रता, लाभ और आवेदन प्रक्रिया उपलब्ध है।",
        "loan": "🏦 कृषि लोन से जुड़ी जानकारी के लिए Loan Guide Module खोलें। यहाँ आपको सही विकल्प और आवेदन प्रक्रिया समझाई गई है।",
        "land": "📍 जमीन से संबंधित जानकारी के लिए Land Records Module खोलें। यहाँ आप अपने भूमि रिकॉर्ड और विवरण देख सकते हैं।",
        "disease": "🌱 फसल की बीमारी पहचानने के लिए Crop Disease Module में फोटो अपलोड करें। आपको तुरंत सही पहचान और उपचार के सुझाव मिलेंगे।",
    }
    return responses.get(intent)


def fix_bad_numbers(text):
    def replace_year_as_days(match):
        num = int(match.group(1))
        unit = match.group(2)
        if num > 100:
            s = str(num)
            fixed = f"{s[:2]}-{s[2:4] if len(s) >= 4 else s[2:]}"
            return f"{fixed} {unit}"
        return match.group(0)
    return re.sub(r'(\d{3,4})\s*(दिन|din|days|दिनों)', replace_year_as_days, text)


def clean_output(raw_text):
    text = re.sub(r'[*#•\-–]', '', raw_text).strip()
    text = fix_bad_numbers(text)

    lines = text.split("\n")
    clean = []

    for line in lines:
        line = line.strip()
        if not line:
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


# =========================
# 🌐 API ROUTE
# =========================

@app.post("/chat")
def chat_api(data: Query):
    try:
        user_msg = data.question.strip()

        intent = detect_intent(user_msg)

        if intent != "ai":
            return {
                "status": "success",
                "answer": module_response(intent)
            }

        response = chat.send_message(
            user_msg,
            generation_config={
                "max_output_tokens": 250,
                "temperature": 0.2
            }
        )

        lines = clean_output(response.text)

        return {
            "status": "success",
            "answer": "\n".join(lines)
        }

    except Exception as e:
        return {
            "status": "error",
            "message": "⚠️ अभी सेवा उपलब्ध नहीं है। कृपया थोड़ी देर बाद पुनः प्रयास करें।"
        }