import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

st.set_page_config(page_title="Portfolio Analyzer", layout="wide")

st.title("Portfolio Risk-Return Analysis Dashboard")

# ----------------------------
# Load precomputed results
# ----------------------------
summary = pd.read_csv("data/processed/portfolio_summary.csv", index_col=0)
portfolio_values = pd.read_csv(
    "data/processed/portfolio_backtest.csv",
    index_col=0,
    parse_dates=True
)

# ----------------------------
# Portfolio selector
# ----------------------------
portfolio_type = st.selectbox(
    "Select Portfolio",
    summary.index.tolist()
)

# ----------------------------
# Metrics
# ----------------------------
st.subheader("Performance Metrics")

cols = st.columns(4)
metrics = summary.loc[portfolio_type]

cols[0].metric("CAGR", f"{metrics['CAGR']:.2%}")
cols[1].metric("Volatility", f"{metrics['Volatility']:.2%}")
cols[2].metric("Sharpe Ratio", f"{metrics['Sharpe']:.2f}")
cols[3].metric("Max Drawdown", f"{metrics['Max Drawdown']:.2%}")

# ----------------------------
# Cumulative return chart
# ----------------------------
st.subheader("Cumulative Portfolio Value")

fig, ax = plt.subplots(figsize=(10, 4))
ax.plot(portfolio_values.index, portfolio_values[portfolio_type])
ax.set_ylabel("Portfolio Value")
ax.set_xlabel("Date")
ax.grid(True)

st.pyplot(fig)

# ----------------------------
# Interpretation
# ----------------------------
st.subheader("Interpretation")

if portfolio_type == "Forecast":
    st.write(
        "This portfolio incorporates forecasted returns. "
        "Higher expected return is achieved at the cost of increased volatility."
    )
elif portfolio_type == "Historical":
    st.write(
        "This portfolio relies on historical return statistics. "
        "It offers stable risk-adjusted performance."
    )
else:
    st.write(
        "Equal-weight portfolio serves as a neutral benchmark."
    )
