import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings("ignore")

try:
    import pmdarima as pm
except ImportError:
    raise ImportError("pip install pmdarima")

def fit_arima(series: pd.Series, seasonal: bool = False):
    model = pm.auto_arima(
        series,
        seasonal=seasonal,
        m=7 if seasonal else 1,
        stepwise=True,
        information_criterion="aic",
        error_action="ignore",
        suppress_warnings=True,
    )
    print(f"선택된 order: {model.order}  |  AIC: {model.aic():.1f}")
    return model

def predict_arima(model, steps: int = 14) -> pd.DataFrame:
    forecast, conf_int = model.predict(n_periods=steps, return_conf_int=True)
    return pd.DataFrame({
        "forecast":  forecast.clip(lower=0),          
        "lower_95":  conf_int[:, 0].clip(min=0), 
        "upper_95":  conf_int[:, 1],
    })

def evaluate_arima(series: pd.Series, test_size: int = 14) -> dict:
    train = series.iloc[:-test_size]
    test  = series.iloc[-test_size:]

    model = fit_arima(train)
    pred  = predict_arima(model, steps=test_size)["forecast"].values

    mae  = np.mean(np.abs(pred - test.values))
    rmse = np.sqrt(np.mean((pred - test.values) ** 2))
    return {"MAE": round(mae, 1), "RMSE": round(rmse, 1),
            "order": model.order, "AIC": round(model.aic(), 1)}