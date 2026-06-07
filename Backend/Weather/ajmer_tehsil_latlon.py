import requests
import json
import time
from bs4 import BeautifulSoup

STATE_CODE = "08"
STATE_NAME = "Rajasthan"
DISTRICT = "Alwar"

HEADERS = {
    "User-Agent": "GaonMitra-AI"
}

# -----------------------------
# Get lat-lon of TEHSIL only
# -----------------------------
def get_tehsil_lat_lon(tehsil):
    query = f"{tehsil}, {DISTRICT}, {STATE_NAME}, India"
    url = "https://nominatim.openstreetmap.org/search"
    params = {
        "q": query,
        "format": "json",
        "limit": 1
    }

    r = requests.get(url, params=params, headers=HEADERS)
    data = r.json()

    if data:
        return float(data[0]["lat"]), float(data[0]["lon"])
    return None, None


def build_alwar_tehsil_based():
    district_url = f"https://vlist.in/district/{STATE_CODE}/{DISTRICT.upper()}.html"
    soup = BeautifulSoup(
        requests.get(district_url, headers=HEADERS).text,
        "html.parser"
    )

    output = {
        "district": DISTRICT,
        "tehsils": []
    }

    table = soup.find("table")
    rows = table.find_all("tr")[1:]  # skip header

    for row in rows:
        cols = row.find_all("td")
        if len(cols) < 2:
            continue

        tehsil_name = cols[1].text.strip()
        link_tag = cols[1].find("a")
        if not link_tag:
            continue

        print(f"\n📍 Tehsil: {tehsil_name}")

        # ✅ ONE lat-lon per tehsil
        t_lat, t_lon = get_tehsil_lat_lon(tehsil_name)
        print(f"  Tehsil LatLon -> {t_lat}, {t_lon}")

        time.sleep(1)

        tehsil_url = "https://vlist.in" + link_tag.get("href")
        tsoup = BeautifulSoup(
            requests.get(tehsil_url, headers=HEADERS).text,
            "html.parser"
        )

        villages_data = []
        vtable = tsoup.find("table")
        vrows = vtable.find_all("tr")[1:]

        for vrow in vrows:
            vcols = vrow.find_all("td")
            if len(vcols) >= 2:
                village = vcols[1].text.strip()

                villages_data.append({
                    "name": village,
                    "lat": t_lat,
                    "lon": t_lon
                })

        output["tehsils"].append({
            "tehsil": tehsil_name,
            "lat": t_lat,
            "lon": t_lon,
            "villages": villages_data
        })

    with open("alwar_final.json", "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print("\n✅ alwar_final.json (TEHSIL-BASED) READY")


# -----------------------------
# RUN
# -----------------------------
build_alwar_tehsil_based()