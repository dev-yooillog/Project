import pandas as pd

COLUMN_NAMES = [
    "bike_id", "rental_datetime", "rental_station_no", "rental_station_name",
    "rental_dock", "return_datetime", "return_station_no", "return_station_name",
    "return_dock", "usage_minutes", "usage_distance",
    "birth_year", "gender", "user_type",
    "rental_station_id", "return_station_id", "bike_type"
]


def transform(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    if list(df.columns) != COLUMN_NAMES:
        df.columns = COLUMN_NAMES

    # datetime 변환
    df["rental_datetime"] = pd.to_datetime(df["rental_datetime"], errors="coerce")
    df["return_datetime"] = pd.to_datetime(df["return_datetime"], errors="coerce")

    # 결측치 처리 
    df["gender"] = df["gender"].fillna("U")
    df["usage_distance"] = pd.to_numeric(df["usage_distance"], errors="coerce").clip(lower=0.0, upper=200_000.0).fillna(0.0)  # 단위: 미터 (200km)

    # 파생 변수
    df["rental_hour"] = df["rental_datetime"].dt.hour
    df["rental_weekday"] = df["rental_datetime"].dt.weekday

    return df