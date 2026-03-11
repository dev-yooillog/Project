import argparse
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from data_loader import load_data, get_country, get_top_n
from analysis    import growth_summary, policy_impact, wave_comparison
from visualization import (plot_country_overview, plot_compare_countries,
                            plot_policy_impact, plot_wave_detection,
                            plot_heatmap_growth)
plt.rcParams["font.family"] = "Malgun Gothic"

DEFAULT_COUNTRIES = ["Korea, South", "US", "Germany", "Japan", "France"]

def run_eda(df, countries):
    for c in countries:
        plot_country_overview(df, c)
        plt.close()
    plot_compare_countries(df, countries)
    plt.close()
    plot_heatmap_growth(df, countries)
    plt.close()
    print("저장 완료")


def run_analysis(df, countries):
    for c in countries:
        print(f"\n[{c}] 성장률 요약")
        print(growth_summary(df, c).tail(4).to_string(index=False))

        print(f"\n[{c}] 정책 영향")
        impact = policy_impact(df, c)
        if not impact.empty:
            print(impact.to_string(index=False))
        plot_policy_impact(df, c)
        plt.close()
        plot_wave_detection(df, c)
        plt.close()

    print("\n[파동 비교]")
    print(wave_comparison(df, countries).to_string(index=False))


def run_seir(df, countries):
    from models.seir_model import fit_seir
    POPULATION = {"Korea, South": 51_700_000, "US": 331_000_000,
                  "Germany": 83_200_000, "Japan": 125_700_000,
                  "France": 67_400_000}
    for c in countries:
        series = get_country(df, c)["confirmed"].values
        N = POPULATION.get(c, 50_000_000)
        result = fit_seir(series, N)
        print(f"  {c}: β={result['beta']}  γ={result['gamma']}  R0={result['R0']}")


def run_arima(df, countries):
    print("\n▶ ARIMA 모델")
    from models.arima_model import fit_arima, predict_arima, evaluate_arima
    for c in countries:
        series = get_country(df, c).set_index("date")["new_confirmed"]
        metrics = evaluate_arima(series)
        print(f"  {c}: {metrics}")


def run_lstm(df, countries):
    from models.lstm_model import train_lstm, predict_lstm, evaluate_lstm
    for c in countries:
        c_df = get_country(df, c)
        model, scaler, _ = train_lstm(c_df, epochs=30)
        metrics = evaluate_lstm(model, scaler, c_df)
        print(f"  {c}: {metrics}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="all",
                        choices=["all", "eda", "analysis", "seir", "arima", "lstm"])
    args = parser.parse_args()
    countries = ["Korea, South", "US", "Germany", "Japan", "France"]

    df = load_data()
    print(f"국가 {len(countries)}개: {countries}")

    if args.model in ("all", "eda"):       run_eda(df, countries)
    if args.model in ("all", "analysis"):  run_analysis(df, countries)
    if args.model in ("all", "seir"):      run_seir(df, countries)
    if args.model in ("all", "arima"):     run_arima(df, countries)
    if args.model in ("all", "lstm"):      run_lstm(df, countries)

    print("\n완료!")