import json
import requests
import time
import sys


def get_lat_lon(query):
    url = f"https://nominatim.openstreetmap.org/search?format=json&q={query}"
    headers = {"User-Agent": "Mozilla/5.0"}

    try:
        r = requests.get(url, headers=headers, timeout=10)
        data = r.json()
    except:
        return None, None

    if len(data) == 0:
        return None, None

    return data[0].get("lat"), data[0].get("lon")


def main(input_file, output_file):
    # Load input JSON
    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    district_name = data["district"]
    tehsils = data["tehsils"]

    final_output = {
        "district": district_name,
        "tehsils": []
    }

    print(f"Total tehsils: {len(tehsils)}")

    # Loop tehsils
    for tehsil_obj in tehsils:
        tehsil_name = tehsil_obj["tehsil"]
        village_list = tehsil_obj["villages"]

        print(f"\n➡ Processing tehsil: {tehsil_name} ({len(village_list)} villages)\n")

        new_village_data = []

        # Loop villages
        for village in village_list:
            query = f"{village}, {tehsil_name}, {district_name}, Rajasthan, India"
            print(f"Fetching: {query}")

            lat, lon = get_lat_lon(query)

            new_village_data.append({
                "village": village,
                "lat": lat,
                "lon": lon
            })

            time.sleep(1)   # avoid rate-limit

        final_output["tehsils"].append({
            "tehsil": tehsil_name,
            "villages": new_village_data
        })

    # Save output
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(final_output, f, indent=4, ensure_ascii=False)

    print(f"\n✔ Output saved to {output_file}\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python auto_lat_lon.py input.json output.json")
    else:
        main(sys.argv[1], sys.argv[2])