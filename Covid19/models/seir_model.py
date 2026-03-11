import numpy as np
import pandas as pd
from scipy.integrate import odeint
from scipy.optimize import minimize


def seir_ode(y, t, N, beta, sigma, gamma):
    S, E, I, R = y
    dS = -beta * S * I / N
    dE =  beta * S * I / N - sigma * E
    dI =  sigma * E - gamma * I
    dR =  gamma * I
    return dS, dE, dI, dR


def run_seir(N: int, beta: float, sigma: float, gamma: float,
             days: int, I0: int = 1, E0: int = 0) -> pd.DataFrame:    
    S0 = N - I0 - E0
    R0_val = 0
    y0 = S0, E0, I0, R0_val
    t  = np.linspace(0, days, days)

    sol = odeint(seir_ode, y0, t, args=(N, beta, sigma, gamma))
    df  = pd.DataFrame(sol, columns=["S", "E", "I", "R"])
    df["day"] = t
    df["R0"]  = round(beta / gamma, 3)
    return df


def fit_seir(confirmed: np.ndarray, N: int,
             sigma: float = 1/5.2) -> dict:
    days = len(confirmed)

    def loss(params):
        beta, gamma = params
        if beta <= 0 or gamma <= 0:
            return 1e10
        result = run_seir(N, beta, sigma, gamma, days,
                          I0=max(confirmed[0], 1))
        fitted = result["I"].values
        return np.mean((fitted - confirmed) ** 2)

    res = minimize(loss, x0=[0.3, 0.1],
                   bounds=[(1e-4, 2.0), (1e-4, 1.0)],
                   method="L-BFGS-B")
    beta_opt, gamma_opt = res.x
    fitted_df = run_seir(N, beta_opt, sigma, gamma_opt, days,
                         I0=max(confirmed[0], 1))
    return {
        "beta":     round(beta_opt, 4),
        "gamma":    round(gamma_opt, 4),
        "R0":       round(beta_opt / gamma_opt, 3),
        "fitted_I": fitted_df["I"].values,
    }