from flask import Flask, request, jsonify
from flask_cors import CORS
from fetch_weather import get_current_weather, get_7_day_forecast, get_hourly_forecast
import json

app = Flask(__name__)
CORS(app)  
DATA_FILE = "final_clean.json"

with open(DATA_FILE, "r", encoding="utf-8") as f:
    LOCATION_DATA = json.load(f)

@app.route("/locations/districts", methods=["GET"])
def get_districts():
    districts = [d["district"] for d in LOCATION_DATA["districts"]]
    return jsonify(districts)


@app.route("/locations/tehsils", methods=["GET"])
def get_tehsils():
    district = request.args.get("district")
    if not district:
        return jsonify([])

    for d in LOCATION_DATA["districts"]:
        if d["district"].lower() == district.lower():
            tehsils = [t["tehsil"] for t in d["tehsils"]]
            return jsonify(tehsils)

    return jsonify([])


@app.route("/locations/villages", methods=["GET"])
def get_villages():
    district = request.args.get("district")
    tehsil = request.args.get("tehsil")

    if not district or not tehsil:
        return jsonify([])

    for d in LOCATION_DATA["districts"]:
        if d["district"].lower() == district.lower():
            for t in d["tehsils"]:
                if t["tehsil"].lower() == tehsil.lower():
                    villages = [v["village"] for v in t["villages"]]
                    return jsonify(villages)

    return jsonify([])

def format_forecast(daily):
    formatted = []
    for i in range(len(daily["time"])):
        formatted.append({
            "date": daily["time"][i],
            "day": daily["time"][i],
            "weatherIcon": "wb_sunny",
            "condition": "Clear",
            "highTemp": round(daily["temperature_2m_max"][i]),
            "lowTemp": round(daily["temperature_2m_min"][i]),
            "rainfallProbability": round(daily["rain_sum"][i]),
            "humidity": 0
        })
    return formatted


def find_location(district, tehsil, village):
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    district_data = next(
        d for d in data["districts"]
        if d["district"].lower() == district.lower()
    )

    tehsil_data = next(
        t for t in district_data["tehsils"]
        if t["tehsil"].lower() == tehsil.lower()
    )

    village_data = next(
        v for v in tehsil_data["villages"]
        if v["village"].lower() == village.lower()
    )

    return float(village_data["lat"]), float(village_data["lon"])


@app.route("/weather", methods=["GET"])
def weather():
    district = request.args.get("district")
    tehsil = request.args.get("tehsil")
    village = request.args.get("village")

    if not district or not tehsil or not village:
        return jsonify({"error": "Missing parameters"}), 400

    try:
        lat, lon = find_location(district, tehsil, village)

        forecast_raw = get_7_day_forecast(lat, lon)
        forecast = format_forecast(forecast_raw["daily"])

        current = get_current_weather(lat, lon)
        hourly_raw = get_hourly_forecast(lat, lon)

        return jsonify({
            "location": {
                "district": district,
                "tehsil": tehsil,
                "village": village,
                "lat": lat,
                "lon": lon
            },
            "current": current,
            "hourly": hourly_raw[:6],
            "forecast": forecast
        })

    except Exception:
        return jsonify({"error": "Location not found"}), 404


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)