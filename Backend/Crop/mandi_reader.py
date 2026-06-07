#!/usr/bin/env python3
import json
import os
from datetime import datetime
from rajasthan_mandis import RAJASTHAN_MANDIS

CACHE_FILE = "mandi_cache.json"

LANG = {
    "hi": {
        "district": "जिला",
        "mandi": "मंडी",
        "crop": "फसल",
        "select": "चुनें",
        "no_price": "⚠️ इस मंडी में इस फसल का पिछले 6 दिनों में कोई भाव उपलब्ध नहीं है",
    },
    "en": {
        "district": "District",
        "mandi": "Mandi",
        "crop": "Crop",
        "select": "Select",
        "no_price": "⚠️ No price available for this crop in last 6 days",
    }
}

# ================= LOAD DATA =================
def load_data():
    if not os.path.exists(CACHE_FILE):
        return []
    with open(CACHE_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

data = load_data()

# ================= LANGUAGE =================
print("\n1. हिंदी\n2. English")
lang = "hi" if input("Choose: ").strip() == "1" else "en"
T = LANG[lang]

# ================= DISTRICT =================
districts = sorted(RAJASTHAN_MANDIS.keys())
print(f"\n📍 {T['district']}s:")
for i, d in enumerate(districts, 1):
    print(f"{i}. {d}")

district = districts[int(input(f"\n{T['select']} {T['district']}: ")) - 1]

# ================= MANDI =================
mandis = sorted({
    r["mandi"] for r in data
    if r["district"].strip().lower() == district.strip().lower()
})
if not mandis:
    print("\n⚠️ No mandi data available for this district in JSON.")
    exit()
print(f"\n🏬 {T['mandi']}s:")
for i, m in enumerate(mandis, 1):
    print(f"{i}. {m}")

mandi = mandis[int(input(f"\n{T['select']} {T['mandi']}: ")) - 1]

# ================= CROP =================
crops = sorted({
    r["crop"] for r in data
    if r["district"].strip().lower() == district.strip().lower()
    and r["mandi"].strip().lower() == mandi.strip().lower()
})
if not crops:
    print("\n⚠️ No crop data available for this mandi.")
    exit()
print(f"\n🌾 {T['crop']}s:")
for i, c in enumerate(crops, 1):
    print(f"{i}. {c}")

crop = crops[int(input(f"\n{T['select']} {T['crop']}: ")) - 1]

# ================= FILTER =================
filtered = [
    r for r in data
    if r["district"].strip().lower() == district.strip().lower()
    and r["mandi"].strip().lower() == mandi.strip().lower()
    and r["crop"].strip().lower() == crop.strip().lower()
]

print("\n" + "=" * 60)
print("        🌾 मंडी भाव रिपोर्ट (पिछले 6 दिन)")
print("=" * 60)
print(f"जिला : {district}")
print(f"मंडी : {mandi}")
print(f"फसल : {crop}")
print("-" * 60)

if not filtered:
    print(T["no_price"])
    exit()

# ================= REMOVE DUPLICATES (DATE-WISE) =================
daily = {}
for r in filtered:
    daily[r["date"]] = r

# ================= SORT LAST 6 DAYS =================
final = sorted(
    daily.values(),
    key=lambda x: datetime.strptime(x["date"], "%d/%m/%Y"),
    reverse=True
)[:6]

print(f"{'तारीख':<15}{'अधिकतम भाव (₹)':<20}")
print("-" * 60)

prices = []

for r in final:
    max_price = int(float(
        r["max"]
        .replace("Rs", "")
        .replace("₹", "")
        .replace("/ क्विंटल", "")
        .replace("/ Quintal", "")
        .strip()
    ))
    prices.append(max_price)
    print(f"{r['date']:<15}₹{max_price:<20}")

print("=" * 60)

# ================= FARMER DECISION (6 DAY LOGIC) =================
oldest = prices[-1]   # 6 din purana
latest = prices[0]    # aaj ka
change = latest - oldest

print("\n📌 सलाह:")

if change > 100:
    print("➡️ पिछले कुछ दिनों में भाव लगातार बढ़ा है।")
    print("✅ अगर तुरंत पैसों की जरूरत नहीं है,")
    print("   तो 1–2 दिन और रुकना फायदेमंद हो सकता है।")

elif change < -100:
    print("➡️ पिछले कुछ दिनों में भाव गिरा है।")
    print("⚠️ देर करने पर और नुकसान हो सकता है।")
    print("✅ आज बेचना ज्यादा सुरक्षित रहेगा।")

else:
    print("➡️ पिछले 6 दिनों में भाव लगभग एक जैसा रहा है।")
    print("ℹ️ किसान अपनी जरूरत के अनुसार कभी भी बेच सकते हैं।")
print("=" * 60)