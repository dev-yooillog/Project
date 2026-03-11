import pandas as pd
import numpy as np
from pathlib import Path

DATA_DIR = Path("data")

FILES = {
    "confirmed": DATA_DIR / "time_series_covid19_confirmed_global.csv",
    "deaths":    DATA_DIR / "time_series_covid19_deaths_global.csv",
    "recovered": DATA_DIR / "time_series_covid19_recovered_global.csv",
}


def _melt(path: Path, value_name: str) -> pd.DataFrame:
    df = pd.read_csv(path)
    id_cols   = ["Province/State", "Country/Region", "Lat", "Long"]
    date_cols = [c for c in df.columns if c not in id_cols]

    melted = df.melt(id_vars=id_cols, value_vars=date_cols,
                     var_name="date", value_name=value_name)
    melted["date"] = pd.to_datetime(melted["date"], format="%m/%d/%y")

    return (
        melted
        .groupby(["Country/Region", "date"], as_index=False)[value_name]
        .sum()
        .rename(columns={"Country/Region": "country"})
    )


def load_data() -> pd.DataFrame:
    df = (
        _melt(FILES["confirmed"], "confirmed")
        .merge(_melt(FILES["deaths"],    "deaths"),    on=["country", "date"], how="left")
        .merge(_melt(FILES["recovered"], "recovered"), on=["country", "date"], how="left")
    )

    df["recovered"] = df["recovered"].fillna(0)
    df = df.sort_values(["country", "date"]).reset_index(drop=True)

    for col in ["confirmed", "deaths", "recovered"]:
        df[col] = df[col].clip(lower=0).fillna(0).astype(int)

    df["active"] = (df["confirmed"] - df["deaths"] - df["recovered"]).clip(lower=0)

    df["new_confirmed"] = df.groupby("country")["confirmed"].diff().clip(lower=0).fillna(0).astype(int)
    df["new_deaths"]    = df.groupby("country")["deaths"].diff().clip(lower=0).fillna(0).astype(int)

    df["ma7_confirmed"] = df.groupby("country")["new_confirmed"].transform(
        lambda x: x.rolling(7, min_periods=1).mean()).round(1)
    df["ma7_deaths"] = df.groupby("country")["new_deaths"].transform(
        lambda x: x.rolling(7, min_periods=1).mean()).round(1)

    df["growth_rate"] = (df.groupby("country")["confirmed"]
                         .pct_change().replace([np.inf, -np.inf], np.nan).mul(100).round(4))
    df["cfr"] = np.where(df["confirmed"] > 0,
                         (df["deaths"] / df["confirmed"] * 100).round(4), np.nan)
    return df


def get_country(df, country, start=None, end=None):
    mask = df["country"] == country
    if start: mask &= df["date"] >= pd.to_datetime(start)
    if end:   mask &= df["date"] <= pd.to_datetime(end)
    return df[mask].reset_index(drop=True)

def get_top_n(df, n=10, by="confirmed"):
    return df[df["date"] == df["date"].max()].nlargest(n, by)["country"].tolist()