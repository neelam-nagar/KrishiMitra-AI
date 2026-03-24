# normalizer.py

def clean(text: str) -> str:
    """
    Universal normalizer for mandi / crop
    Hindi + English safe
    """
    return (
        text.lower()
        .replace(".", "")
        .replace("(", "")
        .replace(")", "")
        .replace("&", "")
        .replace("  ", " ")
        .strip()
    )
