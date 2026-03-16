# Stock Portfolio Analysis System

미국 주요 기술주 8종목을 대상으로 주가 데이터 수집부터 머신러닝 기반 수익률 예측,
포트폴리오 최적화, 인터랙티브 대시보드까지 전 과정을 구현한 데이터 분석 파이프라인입니다.

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 분석 종목 | AAPL, MSFT, TSLA, NVDA, GOOGL, AMZN, META, SPY |
| 데이터 기간 | 3년 (일별 종가, 752 거래일) |
| 데이터 출처 | Yahoo Finance (yfinance) |
| 최적화 방법 | Monte Carlo 시뮬레이션 (20,000회) |
| 예측 모델 | Lag-5 선형회귀 (scikit-learn) |
| 대시보드 | Streamlit |

---

## 프로젝트 구조
```
├── data/
│   ├── raw/                  # 수집된 원본 주가 데이터
│   └── processed/            # 예측 수익률 등 가공 데이터
├── notebooks/
│   ├── 01_data_collection    # 주가 데이터 수집
│   ├── 02_EDA_analysis       # 탐색적 데이터 분석
│   ├── 03_risk_return_analysis  # 리스크-수익 분석
│   ├── 04_final_report       # 종목별 지표 종합
│   ├── 05_optimization       # 포트폴리오 최적화
│   ├── 06_forecasting        # ML 수익률 예측
│   └── 07_forecast_vs_historical  # 포트폴리오 비교
├── app.py                    # Streamlit 대시보드
└── requirements.txt
```

---

## 분석 파이프라인

1. **데이터 수집** — yfinance API로 3년치 일별 종가 수집 및 저장
2. **EDA** — 가격 추이 시각화, 수익률 분포, 변동성 비교
3. **리스크-수익 분석** — 연간 수익률 · 변동성 · Sharpe Ratio 산출
4. **종합 리포트** — 최우수/최저위험/최고수익 종목 식별
5. **포트폴리오 최적화** — Monte Carlo로 효율적 프론티어 탐색
6. **수익률 예측** — Lag-5 선형회귀 모델로 다음 기간 수익률 예측
7. **비교 분석** — 역사적 기반 vs 예측 기반 포트폴리오 성과 비교

---

## 주요 분석 결과

| 종목 | 연간 수익률 | 연간 변동성 | Sharpe Ratio |
|------|------------|------------|--------------|
| NVDA | 98.7% | 50.2% | **1.93** |
| META | 63.2% | 38.2% | 1.61 |
| GOOGL | 47.0% | 30.3% | 1.49 |
| TSLA | 65.7% | 60.1% | 1.06 |
| SPY | 22.1% | 15.4% | 1.31 |

- **최고 Sharpe Ratio**: NVDA (1.93)
- **최저 변동성**: SPY (15.4%)
- **ML 예측 상향 종목**: GOOGL (47.0% → 98.7%)

---

## 실행 방법
```bash
# 패키지 설치
pip install -r requirements.txt

# 데이터 수집 (notebooks/01 실행 후)

# 대시보드 실행
streamlit run app.py
```

---

## 기술 스택

`Python` `pandas` `numpy` `yfinance` `scikit-learn` `matplotlib` `seaborn` `Streamlit`
