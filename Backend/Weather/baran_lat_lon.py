import json
import requests
import time
import sys

def get_lat_lon(query):
    url = f"https://nominatim.openstreetmap.org/search?format=json&q={query}"
    headers = {"User-Agent": "Mozilla/5.0"}

    r = requests.get(url, headers=headers)
    data = r.json()

    if len(data) == 0:
        return None, None

    return data[0]["lat"], data[0]["lon"]


def main(input_file, output_file):
    with open(input_file, "r") as f:
        data = json.load(f)

    district_name = data["district"]
    tehsils = data["tehsils"]

    final_output = {
        "district": district_name,
        "tehsils": []
    }

    print(f"Total tehsils: {len(tehsils)}")

    for tehsil_obj in tehsils:
        tehsil_name = tehsil_obj["tehsil"]
        village_list = tehsil_obj["villages"]

        print(f"\n➡ Processing tehsil: {tehsil_name} ({len(village_list)} villages)\n")

        new_village_data = []

        for village in village_list:
            query = f"{village}, {tehsil_name}, {district_name}, Rajasthan, India"
            print(f"Fetching: {query}")

            lat, lon = get_lat_lon(query)

            new_village_data.append({
                "village": village,
                "lat": lat,
                "lon": lon
            })

            time.sleep(1)

        final_output["tehsils"].append({
            "tehsil": tehsil_name,
            "villages": new_village_data
        })

    with open(output_file, "w") as f:
        json.dump(final_output, f, indent=4)

    print(f"\n✔ Output saved to {output_file}\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python baran_lat_lon.py input.json output.json")
    else:
        main(sys.argv[1], sys.argv[2])