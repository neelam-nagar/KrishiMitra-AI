import json
import requests
import sys

# -------------------------
# WEATHER API
# -------------------------

def get_current_weather(lat, lon):
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&current=temperature_2m,relativehumidity_2m,rain,windspeed_10m"
    )
    res = requests.get(url).json()

    if "current" not in res:
        return None

    return {
        "temperature": res["current"].get("temperature_2m"),
        "humidity": res["current"].get("relativehumidity_2m"),
        "rain": res["current"].get("rain"),
        "wind": res["current"].get("windspeed_10m")
    }


def get_7_day_forecast(lat, lon):
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&daily=temperature_2m_max,temperature_2m_min,rain_sum"
        f"&timezone=auto"
    )
    return requests.get(url).json()


# --------------------------
# HOURLY FORECAST FUNCTION
# --------------------------
def get_hourly_forecast(lat, lon):
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&hourly=temperature_2m,rain"
        f"&forecast_days=1"
        f"&timezone=auto"
    )

    res = requests.get(url).json()

    hourly_data = []
    times = res["hourly"]["time"]
    temps = res["hourly"]["temperature_2m"]
    rains = res["hourly"]["rain"]

    for i in range(len(times)):
        hourly_data.append({
            "time": times[i],
            "temperature": temps[i],
            "rain": rains[i]
        })

    return hourly_data


def get_icon(rain, tmax):
    if rain > 0:
        return "🌧"
    if tmax >= 30:
        return "☀️"
    return "⛅"


def print_forecast(data):
    print("\n=========== 7-DAY FORECAST ===========")
    for i in range(len(data["daily"]["time"])):
        date = data["daily"]["time"][i]
        tmax = data["daily"]["temperature_2m_max"][i]
        tmin = data["daily"]["temperature_2m_min"][i]
        rain = data["daily"]["rain_sum"][i]
        icon = get_icon(rain, tmax)
        print(f"{date}  {icon}  {int(tmax)}° / {int(tmin)}°")
    print("====================================")


# -------------------------------------------------
# CHATBOT FUNCTION (NO input(), ONLY return)
# -------------------------------------------------

def get_weather_for_chatbot(json_file, district_name, tehsil_name, village_name):
    """
    Chatbot ke liye weather function
    """

    try:
        with open(json_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        districts = data["districts"]

        district = next(
            d for d in districts
            if d["district"].lower() == district_name.lower()
        )

        tehsil = next(
            t for t in district["tehsils"]
            if t["tehsil"].lower() == tehsil_name.lower()
        )

        village = next(
            v for v in tehsil["villages"]
            if v["village"].lower() == village_name.lower()
        )

        lat = float(village["lat"])
        lon = float(village["lon"])

        current = get_current_weather(lat, lon)

        if not current:
            return "Weather data available nahi hai"

        hourly = get_hourly_forecast(lat, lon)

        return {
            "location": {
                "state": "Rajasthan",
                "district": district_name,
                "tehsil": tehsil_name,
                "village": village_name
            },
            "current": current,
            "hourly": hourly[:6]
        }

    except Exception:
        return "Weather data abhi update ho raha hai"


# -------------------------------------------------
# CLI MODE (AS IT WAS)
# -------------------------------------------------

def main(json_file):

    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    print("\n🌾 STATE: Rajasthan")

    districts = data["districts"]

    district_names = sorted(d["district"] for d in districts)

    print("\nAvailable Districts:")
    for i, name in enumerate(district_names, 1):
        print(f" {i}. {name}")

    d_choice = input("\nEnter District Name or Number: ").strip()

    if d_choice.isdigit():
        district_name = district_names[int(d_choice) - 1]
    else:
        district_name = d_choice

    district = next(
        d for d in districts
        if d["district"].lower() == district_name.lower()
    )

    print("\nAvailable Tehsils:")
    for i, t in enumerate(district["tehsils"], 1):
        print(f" {i}. {t['tehsil']}")

    t_choice = input("\nEnter Tehsil Name or Number: ").strip()

    if t_choice.isdigit():
        tehsil = district["tehsils"][int(t_choice) - 1]
    else:
        tehsil = next(
            t for t in district["tehsils"]
            if t["tehsil"].lower() == t_choice.lower()
        )

    villages = [
        v for v in tehsil["villages"]
        if isinstance(v, dict) and v.get("village")
    ]

    print("\nAvailable Villages:")
    for v in villages:
        print(" -", v["village"])

    village_name = input("\nEnter Village Name: ").strip()

    village = next(
        v for v in villages
        if v["village"].lower() == village_name.lower()
    )

    lat = float(village["lat"])
    lon = float(village["lon"])

    print(f"\n📍 Weather for {village_name} ({lat}, {lon})\n")

    current = get_current_weather(lat, lon)

    print("======= LIVE WEATHER =======")
    print(f"🌡 Temp: {current['temperature']} °C")
    print(f"💧 Humidity: {current['humidity']} %")
    print(f"🌧 Rain: {current['rain']} mm")
    print(f"💨 Wind: {current['wind']} km/h")
    print("============================")

    forecast = get_7_day_forecast(lat, lon)
    print_forecast(forecast)

    hourly = get_hourly_forecast(lat, lon)

    print("\n=========== HOURLY FORECAST ===========")
    for h in hourly[:6]:
        time = h["time"].split("T")[1]
        print(f"{time}  🌡 {h['temperature']} °C  🌧 {h['rain']} mm")
    print("======================================")


# -------------------------------------------------
# RUN
# -------------------------------------------------


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python fetch_weather.py final_clean.json")
    else:
        main(sys.argv[1])