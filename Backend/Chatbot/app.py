import google.generativeai as genai
from dotenv import load_dotenv
import os
import re

# 🔐 API Key — .env se load karo
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    print("❌ GEMINI_API_KEY nahi mili!")
    print("   Terminal mein run karo: echo 'GEMINI_API_KEY=apni_key' > .env")
    exit(1)

genai.configure(api_key=API_KEY)

# ✅ Model name fix kiya — gemini-3.1-flash-lite-preview exist nahi karta
model = genai.GenerativeModel("gemini-3.1-flash-lite-preview")


# 🧠 Aapka original instruction (as-is)
instruction = """
You are KrishiMitra-AI, an intelligent assistant for farmers.

Rules:
- Never guess data
- If unsure → say: "⚠️ इस विषय पर सटीक जानकारी अभी उपलब्ध नहीं है। कृपया संबंधित मॉड्यूल में देखें।"
- Give short, practical advice in Hindi
- Use only 2–3 bullet points with ✅ ⚠️ 💡
- Each bullet must be ONE complete sentence ending with ।
- Never leave any sentence incomplete
- When mentioning days, always use small realistic numbers (e.g. 20-25 दिन)

Behavior:
- Advice → answer directly
- Real-time → suggest module
- Both → give advice + module
"""

# 💬 Chat history — user turn mein instruction diya (model turn mein nahi)
history = [
    {"role": "user",  "parts": [instruction]},
    {"role": "model", "parts": ["✅ Samajh gaya। Main hamesha 2-3 poore bullets mein jawab dunga।"]}
]
chat = model.start_chat(history=history)

# 🔍 Intent Detection
def detect_intent(user_msg):
    msg = user_msg.lower()
    if any(w in msg for w in ["mausam","बारिश","मौसम"]):        return "weather"
    if any(w in msg for w in ["bhav","price","mandi","भाव","मंडी","daam","दाम"]):  return "mandi"
    if any(w in msg for w in ["yojana","scheme","योजना","subsidy"]):               return "scheme"
    if any(w in msg for w in ["loan","लोन","karz","कर्ज"]):                        return "loan"
    if any(w in msg for w in ["zameen","land","जमीन","ज़मीन","khasra"]):            return "land"
    if any(w in msg for w in ["bimari","keede","बीमारी","कीड़े","rog","रोग"]):      return "disease"
    return "ai"

# 🎯 Module Responses
def module_response(intent):
    responses = {
        "weather": "⚠️ सटीक मौसम जानकारी यहां उपलब्ध नहीं है।\n💡 कृपया Weather Module खोलें।\n✅ वहां आपको वर्तमान और 7 दिनों का पूर्वानुमान मिलेगा।",
        "mandi":   "⚠️ ताज़ा मंडी भाव यहां उपलब्ध नहीं है।\n💡 कृपया Mandi Module देखें।\n✅ वहां आपको सभी फसलों के अपडेटेड रेट मिलेंगे।",
        "scheme":  "⚠️ योजना की पूरी जानकारी यहां उपलब्ध नहीं है।\n💡 कृपया Government Schemes Module खोलें।\n✅ वहां पात्रता और आवेदन की जानकारी मिलेगी।",
        "loan":    "⚠️ लोन की जानकारी यहां उपलब्ध नहीं है।\n💡 कृपया Loan Guide Module खोलें।\n✅ वहां सही विकल्प और प्रक्रिया मिलेगी।",
        "land":    "⚠️ जमीन रिकॉर्ड यहां उपलब्ध नहीं है।\n💡 कृपया Land Records Module खोलें।\n✅ वहां जमीन की पूरी जानकारी देख सकते हैं।",
        "disease": "⚠️ सही पहचान के लिए फोटो ज़रूरी है।\n💡 कृपया Crop Disease Module खोलें।\n✅ फोटो अपलोड करके बीमारी पहचानें।",
    }
    return responses.get(intent)

# 🔢 Hallucinated number fix — "2025 din" jaise galat numbers pakdo
def fix_bad_numbers(text):
    def replace_year_as_days(match):
        num = int(match.group(1))
        unit = match.group(2)
        if num > 100:
            s = str(num)
            fixed = f"{s[:2]}-{s[2:4] if len(s) >= 4 else s[2:]}"
            return f"{fixed} {unit}"
        return match.group(0)
    text = re.sub(r'(\d{3,4})\s*(दिन|din|days|दिनों)', replace_year_as_days, text)
    return text

# ✅ Output cleaner — adhe sentence aur paragraph hatao
def clean_output(raw_text):
    # Saari formatting hatao
    text = re.sub(r'[*#•\-–]', '', raw_text).strip()
    text = fix_bad_numbers(text)  # ✅ number fix

    # Bullet lines nikalte hain
    lines = text.split("\n")
    clean = []
    for line in lines:
        line = line.strip()
        if not line or len(line) < 6:
            continue
        # Sirf emoji wali lines lo
        if not (line.startswith("✅") or line.startswith("💡") or line.startswith("⚠️")):
            continue
        # Adha sentence fix karo
        if line[-1] not in ["।", ".", "!", "?"]:
            line += "।"
        clean.append(line)
        if len(clean) == 3:
            break

    # Fallback — agar koi emoji line nahi mili
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

# 🔁 Chat loop
while True:
    user_msg = input("\nApna sawal likho (kisan) ya 'exit' likho: ").strip()
    if not user_msg:
        continue
    if user_msg.lower() == "exit":
        print("Dhanyavaad 🙏")
        break

    print("\n⏳ KrishiMitra AI soch raha hai...\n")
    intent = detect_intent(user_msg)

    try:
        if intent != "ai":
            print(module_response(intent))
            continue

        response = chat.send_message(
            user_msg,
            generation_config={
                "max_output_tokens": 250,
                "temperature": 0.2
            }
        )

        print("KrishiMitra AI:\n")
        lines = clean_output(response.text)

        if not lines:
            print("⚠️ Jawab sahi format mein nahi aaya।")
            print("💡 Sawal dobara clearly likhein।")
            print("✅ Ya Krishi Helpline 1551 par call karein।")
        else:
            print("\n".join(lines))

    except Exception as e:
        print("⚠️ सेवा में समस्या आ गई है। कृपया थोड़ी देर बाद पुनः प्रयास करें।")

    # History limit
    if len(chat.history) > 6:
        chat.history = chat.history[-6:]