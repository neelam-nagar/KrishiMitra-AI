#!/usr/bin/env python3
# kisan_muavza_cli.py
"""
Kisan Compensation System — Attractive CLI (Hindi/English)
Estimate based on indicative per-hectare values near SDRF / PMFBY norms.
This is ONLY an approximation, not an official claim calculator.
"""

import sys
import time
import os
from datetime import datetime
from itertools import cycle

# Optional PDF export (ReportLab). If not installed, script falls back to text.
try:
    from reportlab.lib.pagesizes import A4
    from reportlab.pdfgen import canvas
    REPORTLAB_AVAILABLE = True
except Exception:
    REPORTLAB_AVAILABLE = False

# ---------- Terminal color & utils ----------
CSI = "\033["
RESET = CSI + "0m"
BOLD = CSI + "1m"

# Colors
FG_GREEN = CSI + "32m"
FG_CYAN = CSI + "36m"
FG_YELLOW = CSI + "33m"
FG_RED = CSI + "31m"
FG_MAG = CSI + "35m"
FG_BLUE = CSI + "34m"
FG_WHITE = CSI + "37m"

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

def slow_print(text, delay=0.005, nl=True):
    for ch in text:
        sys.stdout.write(ch)
        sys.stdout.flush()
        time.sleep(delay)
    if nl:
        sys.stdout.write("\n")

def header(title):
    clear()
    line = FG_CYAN + BOLD + ("=" * 60) + RESET
    print(line)
    print(FG_GREEN + BOLD + f"    {title.center(52)}" + RESET)
    print(line)

def box_print(lines, color=FG_YELLOW):
    width = max(len(l) for l in lines) + 4
    print(color + "┌" + "─" * (width - 2) + "┐" + RESET)
    for l in lines:
        print(color + "│ " + RESET + l.ljust(width - 4) + color + " │" + RESET)
    print(color + "└" + "─" * (width - 2) + "┘" + RESET)

def spinner(seconds=2, msg="Processing"):
    sp = cycle(["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"])
    start = time.time()
    while time.time() - start < seconds:
        sys.stdout.write(FG_MAG + f"\r{next(sp)} {msg}..." + RESET)
        sys.stdout.flush()
        time.sleep(0.08)
    sys.stdout.write("\r" + " " * (len(msg)+8) + "\r")

# ---------- Language strings ----------
STR = {
    "en": {
        "title": "KISAN COMPENSATION SYSTEM",
        "menu": ["Compensation Calculator", "Eligibility Check", "Process Guide", "Save Report (PDF/TXT)", "Exit"],
        "choose": "Choose option (number): ",
        "ask_crop": "Which crop was damaged?",
        "crops": ["Wheat","Mustard","Soybean","Chana (Gram)","Maize"],
        "enter_damage": "Enter damage percent (0-100): ",
        "ask_cause": "Select cause of damage",
        "causes": ["Hailstorm","Flood","Drought","Pest/Disease","Other (fire/accident)"],
        "result": "Result",
        "pmfby": "PMFBY Compensation (estimated per hectare)",
        "sdrf": "SDRF / State Relief (estimated per hectare)",
        "total": "Total Estimated Compensation (per hectare)",
        "disclaimer": "NOTE: This is only an approximate estimate. Actual compensation depends on district notifications, crop insurance data and official assessment.",
        "elig_check": "Eligibility Check for Compensation",
        "question_insured": "Is the farmer insured under PMFBY? (y/n): ",
        "question_aadhaar": "Is Aadhaar linked with bank account? (y/n): ",
        "question_notify": "Was the damage due to a notified natural calamity? (y/n): ",
        "eligible_yes": "✅ Farmer is likely ELIGIBLE to claim compensation. Follow the process guide.",
        "eligible_no": "❌ Farmer is likely NOT eligible (missing one or more essentials). See process guide to fix.",
        "process_title": "Step-by-step Application Process",
        "docs_needed": "Documents required",
        "where_apply": "Where to apply",
        "how_apply_online": "Online application steps",
        "how_apply_offline": "Offline application steps",
        "press_enter": "Press ENTER to return to menu...",
        "save_prompt": "Would you like to save a report of the last result? (y/n): ",
        "pdf_missing": "ReportLab not installed — saving text report instead.",
        "saved_txt": "Saved text report to",
        "saved_pdf": "Saved PDF report to",
        "invalid": "Invalid input, please try again.",
        "goodbye": "Goodbye! Stay safe.",
    },
    "hi": {
        "title": "किसान मुआवज़ा प्रणाली",
        "menu": ["मुआवज़ा कैलकुलेटर", "पात्रता जांच", "प्रक्रिया मार्गदर्शिका", "रिपोर्ट सेव करें (PDF/TXT)", "बाहर निकलें"],
        "choose": "अपना विकल्प चुनें (संख्या): ",
        "ask_crop": "किस फसल का नुकसान हुआ?",
        "crops": ["गेहूं","सरसों","सोयाबीन","चना","मक्का"],
        "enter_damage": "नुकसान प्रतिशत दर्ज करें (0-100): ",
        "ask_cause": "नुकसान का कारण चुनें",
        "causes": ["ओलावृष्टि","बाढ़","सूखा","कीट/रोग","अन्य (आग/दुर्घटना)"],
        "result": "परिणाम",
        "pmfby": "PMFBY मुआवज़ा (प्रति हेक्टेयर अनुमानित)",
        "sdrf": "SDRF / राज्य राहत (प्रति हेक्टेयर अनुमानित)",
        "total": "कुल अनुमानित मुआवज़ा (प्रति हेक्टेयर)",
        "disclaimer": "नोट: यह केवल एक अनुमान है। असली मुआवज़ा ज़िले की सूचनाओं, बीमा कंपनी और सरकारी सर्वे पर निर्भर करेगा।",
        "elig_check": "मुआवज़ा के लिए पात्रता जांच",
        "question_insured": "क्या किसान PMFBY के अंतर्गत बीमित हैं? (y/n): ",
        "question_aadhaar": "क्या आधार बैंक खाते से जुड़ा हुआ है? (y/n): ",
        "question_notify": "क्या नुकसान किसी सरकारी रूप से सूचित प्राकृतिक आपदा के कारण हुआ? (y/n): ",
        "eligible_yes": "✅ किसान मुआवज़ा पाने के लिए सम्भवतः पात्र है। प्रक्रिया मार्गदर्शिका देखें।",
        "eligible_no": "❌ किसान सम्भवतः पात्र नहीं है (किसी आवश्यक चीज़ की कमी)। इसे ठीक करने के लिए प्रक्रिया देखें।",
        "process_title": "आवेदन की चरण-दर-चरण प्रक्रिया",
        "docs_needed": "ज़रूरी दस्तावज़",
        "where_apply": "कहाँ आवेदन करें",
        "how_apply_online": "ऑनलाइन आवेदन कैसे करें",
        "how_apply_offline": "ऑफलाइन आवेदन कैसे करें",
        "press_enter": "मेन्यू पर लौटने के लिए ENTER दबाएँ...",
        "save_prompt": "क्या आप पिछले परिणाम की रिपोर्ट सेव करना चाहेंगे? (y/n): ",
        "pdf_missing": "ReportLab इंस्टॉल नहीं है — टेक्स्ट रिपोर्ट सेव की जा रही है।",
        "saved_txt": "टेक्स्ट रिपोर्ट सेव हुई:",
        "saved_pdf": "PDF रिपोर्ट सेव हुई:",
        "invalid": "अमान्य इनपुट, पुनः प्रयत्न करें।",
        "goodbye": "अलविदा! सुरक्षित रहें।",
    }
}

# ---------- Indicative per-hectare values (near govt norms) ----------
# PMFBY sum insured ~ district Scale of Finance (example ranges). [web:14][web:20][web:207]
# SDRF as per central norms: ~₹6,800 rainfed, ~₹13,500 irrigated (loss >= 33%). [web:212][web:222]
COMP_RATES = {
    "Wheat":       {"pmfby_rate_per_ha": 30000, "sdrf_per_ha": 13500},  # irrigated example [web:213][web:212]
    "Mustard":     {"pmfby_rate_per_ha": 25000, "sdrf_per_ha": 13500},  # irrigated [web:213][web:212]
    "Soybean":     {"pmfby_rate_per_ha": 20000, "sdrf_per_ha": 6800},   # mostly rainfed [web:210][web:212]
    "Chana (Gram)": {"pmfby_rate_per_ha": 22000, "sdrf_per_ha": 6800},  # pulses, rainfed norm [web:212][web:217]
    "Maize":       {"pmfby_rate_per_ha": 20000, "sdrf_per_ha": 6800},   # kharif example [web:210][web:212]
}

CROP_KEY_MAP_HI = {
    "गेहूं": "Wheat",
    "सरसों": "Mustard",
    "सोयाबीन": "Soybean",
    "चना": "Chana (Gram)",
    "मक्का": "Maize",
}

# ---------- Core logic ----------
def choose_language():
    clear()
    print(FG_BLUE + BOLD + "🌾  Kisan Compensation — Language / भाषा" + RESET)
    print()
    print("1. English")
    print("2. हिन्दी (Hindi)")
    c = input("\nChoose option (1/2): ").strip()
    if c == "2":
        return "hi"
    return "en"

def compensation_calculator(lang):
    header(STR[lang]["title"])
    slow_print(FG_GREEN + BOLD + "🌾 " + STR[lang]["ask_crop"] + RESET, 0.002)
    crops = STR[lang]["crops"]
    for i, c in enumerate(crops, 1):
        print(FG_YELLOW + f"{i}. " + RESET + c)
    while True:
        ch = input("\n" + STR[lang]["choose"]).strip()
        if ch.isdigit() and 1 <= int(ch) <= len(crops):
            crop = crops[int(ch)-1]
            break
        else:
            print(FG_RED + STR[lang]["invalid"] + RESET)

    crop_key = CROP_KEY_MAP_HI.get(crop, crop) if lang == 'hi' else crop

    while True:
        try:
            dmg = float(input("\n" + STR[lang]["enter_damage"]).strip())
            if 0 <= dmg <= 100:
                break
            else:
                print(FG_RED + STR[lang]["invalid"] + RESET)
        except:
            print(FG_RED + STR[lang]["invalid"] + RESET)

    print()
    print(FG_GREEN + STR[lang]["ask_cause"] + RESET)
    for i, c in enumerate(STR[lang]["causes"], 1):
        print(FG_YELLOW + f"{i}. " + RESET + c)
    while True:
        cch = input("\n" + STR[lang]["choose"]).strip()
        if cch.isdigit() and 1 <= int(cch) <= len(STR[lang]["causes"]):
            cause = STR[lang]["causes"][int(cch)-1]
            break
        else:
            print(FG_RED + STR[lang]["invalid"] + RESET)

    spinner(1.2, msg="Calculating estimates")

    rates = COMP_RATES.get(crop_key, {"pmfby_rate_per_ha": 20000, "sdrf_per_ha": 6800})
    pmfby_full = rates["pmfby_rate_per_ha"]
    sdrf_full = rates["sdrf_per_ha"]

    threshold = 33.0  # typical loss threshold in govt norms [web:212][web:217]
    if dmg < 1.0:
        pmfby_award = 0.0
        sdrf_award = 0.0
    else:
        pmfby_award = round((dmg / 100.0) * pmfby_full, 2)
        sdrf_award = round((dmg / 100.0) * sdrf_full, 2)

    total = round(pmfby_award + sdrf_award, 2)

    lines = [
        f"{STR[lang]['result']} - {crop} / {cause}",
        f"Damage: {dmg}%",
        f"{STR[lang]['pmfby']}: ₹{pmfby_award:,.2f}",
        f"{STR[lang]['sdrf']}: ₹{sdrf_award:,.2f}",
        f"{STR[lang]['total']}: ₹{total:,.2f}",
    ]
    box_print(lines, color=FG_GREEN)

    print()
    print(FG_YELLOW + STR[lang]["disclaimer"] + RESET)

    last_result = {
        "timestamp": datetime.now().isoformat(),
        "lang": lang,
        "crop": crop,
        "cause": cause,
        "damage_percent": dmg,
        "pmfby_award": pmfby_award,
        "sdrf_award": sdrf_award,
        "total_award": total,
        "threshold_for_claim_percent": threshold,
    }

    return last_result

def eligibility_check(lang):
    header(STR[lang]["elig_check"])
    slow_print(FG_GREEN + STR[lang]["elig_check"] + RESET, 0.005)
    insured = input("\n" + STR[lang]["question_insured"]).strip().lower()
    aadhaar = input(STR[lang]["question_aadhaar"]).strip().lower()
    notified = input(STR[lang]["question_notify"]).strip().lower()

    dmg_known = input("\nDo you know damage percent? (y/n): ").strip().lower()
    dmg_val = None
    if dmg_known == 'y':
        try:
            dmg_val = float(input("Enter damage percent: ").strip())
        except:
            dmg_val = None

    spinner(1.0, msg="Checking eligibility")

    msgs = []
    eligible = True
    if insured != 'y':
        msgs.append("Farmer is NOT insured under PMFBY — may be ineligible for PMFBY claims.")
        eligible = False
    if aadhaar != 'y':
        msgs.append("Aadhaar not linked with bank — DBT can't be processed. Link Aadhaar with bank immediately.")
        eligible = False
    if notified != 'y':
        msgs.append("Damage not reported as a notified natural calamity — state relief (SDRF) may not apply.")
    if dmg_val is not None:
        if dmg_val < 33.0:
            msgs.append("Damage percent is below typical threshold (33%) — crop insurance payouts may not be triggered.")
            eligible = False

    if eligible:
        print(FG_GREEN + STR[lang]["eligible_yes"] + RESET)
    else:
        print(FG_RED + STR[lang]["eligible_no"] + RESET)

    if msgs:
        print()
        box_print(msgs, color=FG_YELLOW)

    print()
    print(FG_CYAN + STR[lang]["process_title"] + RESET)
    steps = [
        "1) Contact your nearest Block Agriculture Office / Tehsil within 7 days of event.",
        "2) Register damage in Girdawari / Field Survey with officials.",
        "3) File claim via PMFBY portal / bank branch / CSC (if insured).",
        "4) Submit documents (Aadhaar, bank passbook, land record, crop/girdawari, photos).",
        "5) Keep receipts and follow up until DBT credited."
    ]
    for s in steps:
        print(FG_YELLOW + "- " + RESET + s)

    input("\n" + STR[lang]["press_enter"])
    return {"eligible": eligible, "notes": msgs}

def process_guide(lang):
    header(STR[lang]["process_title"])
    docs = [
        "- Aadhaar copy",
        "- Bank passbook / cancelled cheque (Aadhaar linked)",
        "- Jamabandi / Land Record (Patta)",
        "- Damage report / Girdawari certificate",
        "- Photo evidence (time-stamped if possible)",
        "- Identity proof, mobile number",
        "- Farmer code / PM-KISAN ID (if available)"
    ]
    box_print([STR[lang]["docs_needed"]], color=FG_CYAN)
    for d in docs:
        print(FG_YELLOW + "• " + RESET + d)
    print()

    print(FG_CYAN + STR[lang]["where_apply"] + RESET)
    where = [
        "- District/Block Agriculture Office (primary)",
        "- Nearest Bank Branch (for KCC/PMFBY linked claims)",
        "- Common Service Centre (CSC) for e-filing in some states",
        "- RajKisan / State agricultural portal (state-specific)",
        "- PMFBY / crop insurance toll-free/helpdesk"
    ]
    for w in where:
        print(FG_YELLOW + "• " + RESET + w)
    print()

    print(FG_CYAN + STR[lang]["how_apply_online"] + RESET)
    online_steps = [
        "1) Visit PMFBY / state agriculture portal.",
        "2) Farmer login (Aadhaar/registered mobile) or visit bank/CSC.",
        "3) Select season & crop, attach girdawari/damage photos & submit claim.",
        "4) Track claim with reference number; follow-up with bank for DBT."
    ]
    for o in online_steps:
        print(FG_YELLOW + o + RESET)
    print()

    print(FG_CYAN + STR[lang]["how_apply_offline"] + RESET)
    offline_steps = [
        "1) Visit Block Agriculture / Tehsil office.",
        "2) Submit physical claim form with documents and girdawari certificate.",
        "3) Officials will inspect and record; claims processed and sanctioned as per norms."
    ]
    for o in offline_steps:
        print(FG_YELLOW + o + RESET)

    input("\n" + STR[lang]["press_enter"])

def save_report(last_result):
    if not last_result:
        print(FG_RED + "No result to save." + RESET)
        return
    lang = last_result.get("lang", "en")
    prompt = STR[lang]["save_prompt"]
    ans = input("\n" + prompt).strip().lower()
    if ans != 'y':
        return

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    basefn = f"kisan_report_{ts}"
    txt_path = basefn + ".txt"

    lines = []
    lines.append("Kisan Compensation Report (Indicative)")
    lines.append(f"Timestamp: {last_result.get('timestamp')}")
    lines.append(f"Crop: {last_result.get('crop')}")
    lines.append(f"Cause: {last_result.get('cause')}")
    lines.append(f"Damage %: {last_result.get('damage_percent')}")
    lines.append(f"PMFBY estimate (per ha): ₹{last_result.get('pmfby_award')}")
    lines.append(f"SDRF estimate (per ha): ₹{last_result.get('sdrf_award')}")
    lines.append(f"Total estimate (per ha): ₹{last_result.get('total_award')}")
    lines.append("")
    lines.append("IMPORTANT: This is only an approximate estimate based on generic norms.")
    lines.append("Actual compensation will depend on district notifications,")
    lines.append("official crop-cutting / damage assessment and insurer / government decisions.")

    if REPORTLAB_AVAILABLE:
        pdf_path = basefn + ".pdf"
        try:
            c = canvas.Canvas(pdf_path, pagesize=A4)
            width, height = A4
            text = c.beginText(40, height - 60)
            text.setFont("Helvetica-Bold", 12)
            text.textLine("Kisan Compensation Report (Indicative)")
            text.setFont("Helvetica", 10)
            text.textLine("")
            for ln in lines[1:]:
                text.textLine(ln)
            c.drawText(text)
            c.showPage()
            c.save()
            print(FG_GREEN + STR[lang]["saved_pdf"], pdf_path + RESET)
            return
        except Exception as e:
            print(FG_YELLOW + "PDF export failed:", e, RESET)

    with open(txt_path, "w", encoding="utf-8") as f:
        for ln in lines:
            f.write(ln + "\n")
    print(FG_GREEN + STR[lang]["saved_txt"], os.path.abspath(txt_path) + RESET)

# ---------- Main Menu ----------
def main():
    lang = choose_language()
    last_result = None
    while True:
        header(STR[lang]["title"])
        print()
        for i, m in enumerate(STR[lang]["menu"], 1):
            print(FG_YELLOW + f"{i}. " + RESET + m)
        choice = input("\n" + STR[lang]["choose"]).strip()
        if choice == "1":
            last_result = compensation_calculator(lang)
            input("\n" + STR[lang]["press_enter"])
        elif choice == "2":
            eligibility_check(lang)
        elif choice == "3":
            process_guide(lang)
        elif choice == "4":
            save_report(last_result)
            input("\n" + STR[lang]["press_enter"])
        elif choice == "5":
            print(FG_CYAN + STR[lang]["goodbye"] + RESET)
            break
        else:
            print(FG_RED + STR[lang]["invalid"] + RESET)
            time.sleep(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n" + FG_CYAN + "Interrupted. Bye." + RESET)
        sys.exit(0)
