import re

def clean_text(text):
    text = str(text)
    text = re.sub(r"[^가-힣a-zA-Z0-9\s]", "", text)
    text = text.strip()
    return text