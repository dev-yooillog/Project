import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
import pandas as pd
import numpy as np
from pathlib import Path
from analysis import POLICY_EVENTS, detect_waves

Path("results").mkdir(exist_ok=True)
plt.rcParams.update({"figure.dpi": 120, "font.size": 11})


def plot_country_overview(df: pd.DataFrame, country: str):
    c = df[df["country"] == country]
    fig, axes = plt.subplots(2, 2, figsize=(14, 8))
    fig.suptitle(f"{country} — COVID-19 Overview", fontsize=14, fontweight="bold")

    # 누적 확진
    axes[0, 0].plot(c["date"], c["confirmed"], color="#2196F3")
    axes[0, 0].set_title("누적 확진자")
    axes[0, 0].yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f"{x/1e6:.1f}M"))

    # 일별 신규 + 7일 MA
    axes[0, 1].bar(c["date"], c["new_confirmed"], color="#90CAF9", alpha=0.5, label="일별 신규")
    axes[0, 1].plot(c["date"], c["ma7_confirmed"], color="#E53935", linewidth=1.5, label="7일 MA")
    axes[0, 1].set_title("신규 확진자")
    axes[0, 1].legend(fontsize=9)

    # 사망자
    axes[1, 0].bar(c["date"], c["new_deaths"], color="#EF9A9A", alpha=0.6, label="일별 사망")
    axes[1, 0].plot(c["date"], c["ma7_deaths"], color="#B71C1C", linewidth=1.5, label="7일 MA")
    axes[1, 0].set_title("신규 사망자")
    axes[1, 0].legend(fontsize=9)

    # 치명률 CFR
    axes[1, 1].plot(c["date"], c["cfr"], color="#7B1FA2", linewidth=1.2)
    axes[1, 1].set_title("치명률 CFR (%)")

    for ax in axes.flat:
        ax.xaxis.set_major_formatter(mdates.DateFormatter("%y-%m"))
        ax.xaxis.set_major_locator(mdates.MonthLocator(interval=4))
        plt.setp(ax.xaxis.get_majorticklabels(), rotation=30)
        ax.grid(axis="y", alpha=0.3)

    plt.tight_layout()
    fig.savefig(f"results/{country.replace(' ', '_')}_overview.png")
    return fig


def plot_compare_countries(df: pd.DataFrame, countries: list):
    fig, ax = plt.subplots(figsize=(13, 6))
    for country in countries:
        c = df[df["country"] == country]
        ax.plot(c["date"], c["ma7_confirmed"], linewidth=1.8, label=country)

    ax.set_title("국가별 신규 확진자 (7일 이동평균)", fontsize=13)
    ax.set_ylabel("신규 확진자 수")
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y-%m"))
    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
    plt.setp(ax.xaxis.get_majorticklabels(), rotation=30)
    ax.legend(loc="upper left", fontsize=9)
    ax.grid(alpha=0.3)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f"{x/1e3:.0f}K"))
    plt.tight_layout()
    fig.savefig("results/compare_countries.png")
    return fig


def plot_policy_impact(df: pd.DataFrame, country: str):
    from analysis import policy_impact
    c  = df[df["country"] == country]
    events = POLICY_EVENTS.get(country, [])

    fig, ax = plt.subplots(figsize=(13, 5))
    ax.bar(c["date"], c["new_confirmed"], color="#90CAF9", alpha=0.4)
    ax.plot(c["date"], c["ma7_confirmed"], color="#E53935", linewidth=1.8)

    colors = ["#FF6F00", "#388E3C", "#7B1FA2", "#0277BD"]
    for i, (date_str, label) in enumerate(events):
        ax.axvline(pd.to_datetime(date_str), color=colors[i % len(colors)],
                   linestyle="--", linewidth=1.4, label=label)

    ax.set_title(f"{country} — 정책 이벤트 & 확진자 추이", fontsize=13)
    ax.set_ylabel("신규 확진자")
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y-%m"))
    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
    plt.setp(ax.xaxis.get_majorticklabels(), rotation=30)
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)
    plt.tight_layout()
    fig.savefig(f"results/{country.replace(' ', '_')}_policy.png")
    return fig


def plot_wave_detection(df: pd.DataFrame, country: str):
    from analysis import detect_waves
    c     = df[df["country"] == country].reset_index(drop=True)
    waves = detect_waves(df, country)

    fig, ax = plt.subplots(figsize=(13, 5))
    ax.plot(c["date"], c["ma7_confirmed"], color="#1565C0", linewidth=1.5)
    for _, row in waves.iterrows():
        ax.annotate(f"W{int(row['wave'])}",
                    xy=(row["date"], row["peak_new_confirmed"]),
                    xytext=(0, 12), textcoords="offset points",
                    ha="center", fontsize=9, color="#B71C1C",
                    arrowprops=dict(arrowstyle="->", color="#B71C1C"))

    ax.set_title(f"{country} — 감염 파동 감지", fontsize=13)
    ax.set_ylabel("7일 이동평균 신규 확진")
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y-%m"))
    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
    plt.setp(ax.xaxis.get_majorticklabels(), rotation=30)
    ax.grid(alpha=0.3)
    plt.tight_layout()
    fig.savefig(f"results/{country.replace(' ', '_')}_waves.png")
    return fig


def plot_heatmap_growth(df: pd.DataFrame, countries: list):
    sub = df[df["country"].isin(countries)].copy()
    sub["ym"] = sub["date"].dt.to_period("M")
    pivot = (sub.groupby(["country", "ym"])["growth_rate"]
               .mean().unstack("ym").fillna(0))
    pivot.columns = [str(c) for c in pivot.columns]

    if pivot.empty or pivot.shape[1] == 0:
        print("히트맵 데이터 없음")
        return None

    if pivot.shape[1] > 50:
        pivot = pivot.iloc[:, ::3]

    fig, ax = plt.subplots(figsize=(18, 6))
    sns.heatmap(pivot, cmap="RdYlGn_r", center=0, ax=ax,
                linewidths=0.3, cbar_kws={"label": "평균 성장률 (%)"})
    ax.set_title("국가×월 확진자 성장률 히트맵", fontsize=13)
    plt.xticks(rotation=45, fontsize=7)
    plt.tight_layout()
    fig.savefig("results/heatmap_growth.png")
    return fig