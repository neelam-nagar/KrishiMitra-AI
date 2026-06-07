from flask import Flask, jsonify, request
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)

with open("mandi_cache.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# 🔥 Get unique districts
def get_districts():
    return sorted(list(set(r["district"].strip() for r in data)))

# 🔥 Get mandis by district
def get_mandis(district):
    return sorted(list(set(
        r["mandi"].strip()
        for r in data
        if district.lower() in r["district"].strip().lower()
    )))

# 🔥 Get crops by district + mandi
def get_crops(district, mandi):
    return sorted(list(set(
        r["crop"].strip()
        for r in data
        if district.lower() in r["district"].strip().lower()
        and mandi.lower() in r["mandi"].strip().lower()
    )))

@app.route("/mandi", methods=["GET"])
def mandi_price():
    district = (request.args.get("district") or "").strip().lower()
    mandi = (request.args.get("mandi") or "").strip().lower()
    crop = (request.args.get("crop") or "").strip().lower()

    # Simple mapping (EN → HI)
    crop_map = {
        "wheat": "गेहूं",
        "rice": "चावल",
        "onion": "प्याज",
        "potato": "आलू",
        "soybean": "सोयाबीन",
        "mustard": "सरसों"
    }

    if crop in crop_map:
        crop = crop_map[crop]

    records = [
        r for r in data
        if district in r["district"].strip().lower()
        and mandi in r["mandi"].strip().lower()
        and (crop in r["crop"].strip().lower() or crop in r["crop"].strip())
    ]

    if not records:
        return jsonify({
            "error": "No data found",
            "debug": {
                "district": district,
                "mandi": mandi,
                "crop": crop
            }
        })

    records = records[:6]

    prices = []
    for r in records:
        raw_price = str(r.get("max", "0"))
        cleaned = (
            raw_price
            .replace("Rs", "")
            .replace("₹", "")
            .replace("/ क्विंटल", "")
            .replace("/ Quintal", "")
            .strip()
        )

        try:
            price = int(float(cleaned))
        except:
            price = 0
        prices.append({
            "date": r["date"],
            "price": price
        })

    price_values = [p["price"] for p in prices if p["price"] > 0]

    if price_values:
        min_price = min(price_values)
        max_price = max(price_values)
        avg_price = sum(price_values) // len(price_values)
    else:
        min_price = max_price = avg_price = 0

    return jsonify({
        "district": district,
        "mandi": mandi,
        "crop": crop,
        "minPrice": min_price,
        "maxPrice": max_price,
        "avgPrice": avg_price,
        "prices": prices
    })

# ✅ Get all districts
@app.route("/districts", methods=["GET"])
def districts():
    return jsonify({"districts": get_districts()})


# ✅ Get mandis for a district
@app.route("/mandis", methods=["GET"])
def mandis():
    district = (request.args.get("district") or "").strip()
    return jsonify({"mandis": get_mandis(district)})


# ✅ Get crops for district + mandi
@app.route("/crops", methods=["GET"])
def crops():
    district = (request.args.get("district") or "").strip()
    mandi = (request.args.get("mandi") or "").strip()
    return jsonify({"crops": get_crops(district, mandi)})

if __name__ == "__main__":
    app.run(port=5000, debug=True)