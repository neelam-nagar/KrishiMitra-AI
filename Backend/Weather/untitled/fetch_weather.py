import json
import requests
import sys
from datetime import datetime

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


# -------------------------
# HOURLY FORECAST FUNCTION
# -------------------------
def get_hourly_forecast(lat, lon):
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&hourly=temperature_2m,rain"
        f"&forecast_days=1"
        f"&timezone=auto"
    )

    res = requests.get(url).json()

    if "hourly" not in res:
        return []

    times = res["hourly"]["time"]
    temps = res["hourly"]["temperature_2m"]
    rains = res["hourly"]["rain"]

    now = datetime.now()
    hourly_data = []

    for i in range(len(times)):
        hour_time = datetime.fromisoformat(times[i])

        # Only current & future hours
        if hour_time >= now:
            hourly_data.append({
                "time": times[i],
                "temperature": temps[i],
                "rain": rains[i]
            })

        if len(hourly_data) == 6:
            break

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


# -------------------------
# MAIN
# -------------------------

def main(json_file):

    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    print("\n🌾 STATE: Rajasthan")

    districts = data["districts"]

    # -------- DISTRICTS --------
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

    # -------- TEHSILS --------
    tehsils = district["tehsils"]

    print("\nAvailable Tehsils:")
    for i, t in enumerate(tehsils, 1):
        print(f" {i}. {t['tehsil']}")

    t_choice = input("\nEnter Tehsil Name or Number: ").strip()

    if t_choice.isdigit():
        tehsil = tehsils[int(t_choice) - 1]
    else:
        tehsil = next(
            t for t in tehsils
            if t["tehsil"].lower() == t_choice.lower()
        )

    # -------- VILLAGES --------
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

    # -------- CURRENT WEATHER --------
    current = get_current_weather(lat, lon)

    print("======= LIVE WEATHER =======")
    print(f"🌡 Temp: {current['temperature']} °C")
    print(f"💧 Humidity: {current['humidity']} %")
    print(f"🌧 Rain: {current['rain']} mm")
    print(f"💨 Wind: {current['wind']} km/h")
    print("============================")

    # -------- FORECAST --------
    forecast = get_7_day_forecast(lat, lon)
    print_forecast(forecast)


# -------------------------
# RUN
# -------------------------

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python fetch_weather.py final_clean.json")
    else:
        main(sys.argv[1])