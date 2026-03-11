import pandas as pd
import numpy as np 
from scipy.signal import find_peaks

def growth_summary(df: pd.DataFrame, country: str) -> pd.DataFrame:
    c = df[df["country"] == country].copy()
    c["week"] = c["date"].dt.to_period("W")
    weekly = c.groupby("week").agg(
        avg_growth  = ("growth_rate", "mean"),
        total_new   = ("new_confirmed", "sum"),
        peak_new    = ("new_confirmed", "max"),
    ).reset_index()
    return weekly

def compare_growth(df: pd.DataFrame, countries: list, metric="ma7_confirmed") -> pd.DataFrame:
    frames = []
    for c in countries:
        sub = df[df["country"] == c][["date", metric]].copy()
        sub = sub.rename(columns={metric: c})
        frames.append(sub.set_index("date"))
    return pd.concat(frames, axis=1)

POLICY_EVENTS = {
    "Korea, South": [
        ("2020-02-23", "사회적 거리두기 1단계"),
        ("2020-08-16", "수도권 거리두기 2단계"),
        ("2021-07-12", "수도권 거리두기 4단계"),
    ],
    "US": [
        ("2020-03-13", "국가 비상사태 선포"),
        ("2020-04-01", "Stay-at-home 권고"),
        ("2021-01-20", "마스크 의무화"),
    ],
    "Germany": [
        ("2020-03-22", "1차 봉쇄령"),
        ("2020-11-02", "2차 부분 봉쇄"),
        ("2020-12-16", "강화 봉쇄령"),
    ],
}

def policy_impact(df: pd.DataFrame, country: str, window: int = 14) -> pd.DataFrame:
    events = POLICY_EVENTS.get(country, [])
    if not events:
        print(f"'{country}' 정책 데이터 없음")
        return pd.DataFrame()

    c = df[df["country"] == country].set_index("date")
    rows = []
    for date_str, label in events:
        dt = pd.to_datetime(date_str)
        before = c.loc[dt - pd.Timedelta(days=window) : dt - pd.Timedelta(days=1), "growth_rate"].mean()
        after  = c.loc[dt : dt + pd.Timedelta(days=window), "growth_rate"].mean()
        rows.append({
            "policy":      label,
            "date":        dt.date(),
            "before_avg":  round(before, 4),
            "after_avg":   round(after, 4),
            "change_pct":  round(after - before, 4),
        })
    return pd.DataFrame(rows)

def detect_waves(df: pd.DataFrame, country: str,
                 prominence: int = 1000) -> pd.DataFrame:
    c = df[df["country"] == country].reset_index(drop=True)
    values = c["ma7_confirmed"].fillna(0).values
    peaks, props = find_peaks(values, prominence=prominence, distance=30)

    result = pd.DataFrame({
        "wave":               range(1, len(peaks) + 1),
        "date":               c.loc[peaks, "date"].values,
        "peak_new_confirmed": c.loc[peaks, "ma7_confirmed"].values.round(0),
    })
    return result

def wave_comparison(df: pd.DataFrame, countries: list) -> pd.DataFrame:
    rows = []
    for country in countries:
        try:
            waves = detect_waves(df, country)
            rows.append({
                "country":      country,
                "wave_count":   len(waves),
                "max_peak":     waves["peak_new_confirmed"].max() if not waves.empty else 0,
                "first_peak":   waves["date"].min() if not waves.empty else None,
            })
        except Exception:
            pass
    return pd.DataFrame(rows).sort_values("max_peak", ascending=False)