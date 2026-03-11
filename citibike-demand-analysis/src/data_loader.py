import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

parquet_dir = BASE_DIR / "data" / "processed" / "citibike_parquet"

def load_data():

    files = list(parquet_dir.glob("*.parquet"))

    df = pd.concat(
        [pd.read_parquet(f) for f in files],
        ignore_index=True
    )

    return df