#!/usr/bin/env python3
import requests, json, time, os
from bs4 import BeautifulSoup
from datetime import datetime, timedelta

# ================= CONFIG =================
DISTRICTS = [
    "Ajmer","Alwar","Banswara","Baran","Barmer","Bharatpur","Bhilwara",
    "Bikaner","Bundi","Chittorgarh","Churu","Dausa","Dholpur","Dungarpur",
    "Hanumangarh","Jaipur","Jaisalmer","Jalore","Jhalawar","Jhunjhunu",
    "Jodhpur","Karauli","Kota","Nagaur","Pali","Pratapgarh","Rajsamand",
    "Sawai Madhopur","Sikar","Sirohi","Sri Ganganagar","Tonk","Udaipur"
]

CROPS = [
    "gehu","wheat","bajra","makka","maize","jowar","barley",
    "chana","gram","moong","urad","masoor","moth",
    "sarso","mustard","soyabean","groundnut","til","taramira",
    "jeera","dhaniya","methi","saunf",
    "guar","cotton","kapas",
    "onion","potato","tomato","garlic",
    "isabgol","ashwagandha","mehandi","chia"
]

BASE_URL = "https://www.commodityonline.com/hi/mandibhav/district/rajasthan"
CACHE_FILE = "mandi_cache.json"
KEEP_DAYS = 6
# =========================================


# ---------- RAJASTHAN FILTER ----------
RAJASTHAN_HINTS_EN = [
    "ajmer","alwar","baran","barmer","bharatpur","bhilwara","bikaner",
    "bundi","chittor","churu","dausa","dholpur","dungarpur",
    "hanumangarh","jaipur","jaisalmer","jalore","jhalawar",
    "jhunjhunu","jodhpur","karauli","kota","nagaur","pali",
    "pratapgarh","rajsamand","sawai","sikar","sirohi",
    "ganganagar","tonk","udaipur"
]

RAJASTHAN_HINTS_HI = [
    "अजमेर","अलवर","बारान","बारमेर","भरतपुर","भीलवाड़ा","बीकानेर",
    "बूंदी","चित्तौड़","चूरू","दौसा","धौलपुर","डूंगरपुर",
    "हनुमानगढ़","जयपुर","जैसलमेर","जालोर","झालावाड़",
    "झुंझुनूं","जोधपुर","करौली","कोटा","नागौर","पाली",
    "प्रतापगढ़","राजसमंद","सवाई","सीकर","सिरोही",
    "गंगानगर","टोंक","उदयपुर",
    "अन्ता","आट्रू","छबड़ा","नाहरगढ़","समरनियान"
]

def is_rajasthan_mandi(name):
    n = name.lower()
    for k in RAJASTHAN_HINTS_EN:
        if k in n:
            return True
    for h in RAJASTHAN_HINTS_HI:
        if h in name:
            return True
    return False


# ---------- CACHE ----------
def load_cache():
    if not os.path.exists(CACHE_FILE):
        return []
    try:
        with open(CACHE_FILE, "r", encoding="utf-8") as f:
            txt = f.read().strip()
            return json.loads(txt) if txt else []
    except:
        return []

def save_cache(data):
    with open(CACHE_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def is_recent(date_str):
    try:
        d = datetime.strptime(date_str, "%d/%m/%Y")
        return d >= datetime.now() - timedelta(days=KEEP_DAYS)
    except:
        return True


# ---------- START ----------
records = load_cache()

# old data delete (>6 days)
records = [r for r in records if is_recent(r.get("date", ""))]
save_cache(records)

print("\n⚡ RAJASTHAN MANDI AUTO FETCH STARTED\n")

for district in DISTRICTS:
    print(f"📍 {district}")

    for crop in CROPS:
        print(f"   🌾 {crop}")
        url = f"{BASE_URL}/{district.lower()}/{crop}"

        try:
            r = requests.get(url, timeout=8)
            if r.status_code != 200:
                continue

            soup = BeautifulSoup(r.text, "html.parser")
            rows = soup.select("table tbody tr")

            for tr in rows:
                td = tr.find_all("td")
                if len(td) >= 8:
                    mandi = td[5].get_text(strip=True)

                    # ❌ Rajasthan ke bahar block
                    if not is_rajasthan_mandi(mandi):
                        continue

                    record = {
                        "district": district,
                        "mandi": mandi,
                        "crop": td[0].get_text(strip=True),
                        "date": td[1].get_text(strip=True),
                        "min": td[6].get_text(strip=True),
                        "max": td[7].get_text(strip=True),
                        "lang": "Hindi/English"
                    }

                    if record not in records:
                        records.append(record)
                        save_cache(records)   # 🔥 instant save

        except:
            pass

        time.sleep(0.25)

print("\n✅ FETCH COMPLETE")
print(f"📦 Total Records: {len(records)}")
print("🗂 Only last 6 days Rajasthan data saved")
print("🚀 Ready for real users")