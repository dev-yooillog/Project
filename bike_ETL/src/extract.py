import pandas as pd
from config import CSV_PATH, CHUNK_SIZE

def extract_csv():
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV 파일 없음: {CSV_PATH}")

    return pd.read_csv(
        CSV_PATH,
        chunksize=CHUNK_SIZE,
        encoding="cp949",
        na_values=["\\N"]
    )