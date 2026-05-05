import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

parquet_dir = BASE_DIR / "data" / "processed" / "citibike_parquet"

def load_data() -> pd.DataFrame:
    files = sorted(parquet_dir.glob("*.parquet"))
    
    if not files:
        raise FileNotFoundError(f"No parquet files found in {parquet_dir}")
    print(f"Found {len(files)} parquet file(s). Loading...")
    
    df = pd.concat(
        [pd.read_parquet(f) for f in files],
        ignore_index=True
    )
    
    # Parse datetime columns
    df["started_at"] = pd.to_datetime(df["started_at"])
    df["ended_at"]   = pd.to_datetime(df["ended_at"])
    
    print(f"Loaded {len(df):,} records.")
    return df


if __name__ == "__main__":
    df = load_data()
    print(df.dtypes)
    print(df.head())