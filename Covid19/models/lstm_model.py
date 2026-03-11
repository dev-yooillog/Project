import tensorflow as tf
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler

FEATURES = ["new_confirmed", "new_deaths", "ma7_confirmed"]
WINDOW   = 30
HORIZON  = 30

def make_sequences(data: np.ndarray, window: int, horizon: int):
    X, y = [], []
    for i in range(len(data) - window - horizon + 1):
        X.append(data[i : i + window])
        y.append(data[i + window : i + window + horizon, 0])
    return np.array(X), np.array(y)

def build_model(input_shape: tuple):
    model = tf.keras.Sequential([
        tf.keras.layers.LSTM(64, return_sequences=True, input_shape=input_shape),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.LSTM(32),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(HORIZON),
    ])
    model.compile(optimizer="adam", loss="mse")
    return model

def train_lstm(df_country: pd.DataFrame, epochs: int = 50, batch_size: int = 16):
    data   = df_country[FEATURES].fillna(0).values
    scaler = MinMaxScaler()
    scaled = scaler.fit_transform(data)

    X, y = make_sequences(scaled, WINDOW, HORIZON)
    split = int(len(X) * 0.85)
    X_train, X_test = X[:split], X[split:]
    y_train, y_test = y[:split], y[split:]

    model = build_model((WINDOW, len(FEATURES)))
    es    = tf.keras.callbacks.EarlyStopping(patience=8, restore_best_weights=True)

    history = model.fit(
        X_train, y_train,
        validation_data=(X_test, y_test),
        epochs=epochs, batch_size=batch_size,
        callbacks=[es], verbose=1,
    )
    return model, scaler, history

def predict_lstm(model, scaler, df_country: pd.DataFrame) -> np.ndarray:
    data   = df_country[FEATURES].fillna(0).values[-WINDOW:]
    scaled = scaler.transform(data)
    X_pred = scaled.reshape(1, WINDOW, len(FEATURES))

    pred_scaled = model.predict(X_pred, verbose=0)[0]

    dummy = np.zeros((HORIZON, len(FEATURES)))
    dummy[:, 0] = pred_scaled
    return scaler.inverse_transform(dummy)[:, 0].clip(min=0)

def evaluate_lstm(model, scaler, df_country: pd.DataFrame) -> dict:
    actual = df_country["new_confirmed"].values[-HORIZON:]
    pred   = predict_lstm(model, scaler, df_country.iloc[:-HORIZON])
    mae    = np.mean(np.abs(pred - actual))
    mape   = np.mean(np.abs((pred - actual) / (actual + 1))) * 100
    return {"MAE": round(mae, 1), "MAPE(%)": round(mape, 2)}