import json

with open("jhalawar_final.json", "r", encoding="utf-8") as f:
    d = json.load(f)

print("District name:", d["district"])
print("Total tehsils:", len(d["tehsils"]))
print("First tehsil:", d["tehsils"][0]["tehsil"])