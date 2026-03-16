# 🦠 COVID-19 Pandemic Spread Forecast

> Johns Hopkins CSSE 데이터 기반 5개국 감염 확산 분석 및 머신러닝 예측 프로젝트

---

## 📌 프로젝트 개요

Johns Hopkins CSSE COVID-19 글로벌 데이터셋(2020.01.22 ~ 2023.03.09, 190+개국)을 활용하여
한국·미국·독일·일본·프랑스 5개국의 감염 확산 패턴을 분석하고,
**SEIR / ARIMA / LSTM** 3가지 모델로 단기 예측을 수행한 포트폴리오 프로젝트입니다.

---

## 🗂️ 프로젝트 구조

```
Covid19/
├── data/
│   ├── time_series_covid19_confirmed_global.csv
│   ├── time_series_covid19_deaths_global.csv
│   └── time_series_covid19_recovered_global.csv
├── models/
│   ├── seir_model.py       # SEIR ODE + 파라미터 최적화
│   ├── arima_model.py      # Auto-ARIMA 14일 예측
│   └── lstm_model.py       # 다변량 LSTM 30일 예측
├── results/                # 그래프 자동 저장
├── data_loader.py          # CSV 로딩 및 전처리
├── analysis.py             # 성장률·정책·파동 분석
├── visualization.py        # 시각화 모듈
├── main.py                 # 전체 파이프라인
└── requirements.txt
```

---

## ⚙️ 설치 및 실행

### 요구사항

- Python 3.10+
- Windows: 한글 폰트 Malgun Gothic 기본 포함

### 패키지 설치

```bash
pip install -r requirements.txt
```

### 실행

```bash
# 전체 파이프라인 실행
python main.py

# 단계별 실행
python main.py --model eda        # EDA 시각화
python main.py --model analysis   # 성장률·정책·파동 분석
python main.py --model seir       # SEIR 모델
python main.py --model arima      # ARIMA 예측
python main.py --model lstm       # LSTM 예측
```

---

## 📊 분석 항목

| 항목 | 설명 |
|------|------|
| EDA 대시보드 | 누적 확진자, 신규 확진자, 사망자, CFR 4패널 |
| 정책 영향 분석 | 봉쇄·거리두기 전후 성장률 변화량(change_pct) |
| 파동 감지 | `scipy.signal.find_peaks` 기반 감염 파동 자동 감지 |
| SEIR 모델 | β·γ 파라미터 추정, 기초감염재생산수 R₀ 계산 |
| ARIMA | Auto-ARIMA 자동 order 선택, 14일 예측 |
| LSTM | 다변량 입력(확진·사망·성장률), EarlyStopping, 30일 예측 |

---

## 📈 모델 성과

### ARIMA (14일 예측)

| 국가 | MAE | RMSE | Order |
|------|----:|-----:|-------|
| France | 1,436 | 1,760 | (5,1,2) |
| Korea, South | 3,047 | 4,912 | (5,1,4) |
| Japan | 3,770 | 4,447 | (5,1,4) |
| Germany | 8,189 | 9,675 | (5,1,2) |
| US | 14,910 | 16,538 | (5,1,2) |

### LSTM (30일 예측)

| 국가 | MAE | MAPE |
|------|----:|-----:|
| Japan | 4,738 | **44.7%** |
| Germany | 8,569 | — |
| Korea, South | 16,430 | — |
| France | 9,194 | — |
| US | 30,753 | — |

> **참고**: MAPE가 비정상적으로 높은 경우는 예측 기간 내 확진자가 0에 수렴하여 분모가 매우 작아지는 데이터 특성에 기인합니다.

---

## 🔍 주요 인사이트

- **한국**: 2020~2021년 K-방역 기간 확진자 거의 0에 수렴 → 2022년 오미크론 유입 후 폭발적 확산 (W3 피크: 일 40만 건)
- **미국**: Stay-at-home 권고 직후 성장률 **-19.2%p** 감소로 정책 즉각 효과 확인, 21개 파동으로 가장 복잡한 패턴
- **독일**: 1차 봉쇄령 **-12.5%p** 효과, 2·3차 봉쇄는 효과 미미
- **프랑스**: 초기 CFR 20%+ → 검사 부족으로 인한 과소집계 반영, 14개 파동
- **일본**: 2021년까지 상대적 억제 성공, LSTM MAPE 44.7%로 5개국 중 예측 정확도 최고

---

## 🛠️ 트러블슈팅

| 문제 | 원인 | 해결 |
|------|------|------|
| `'Korea, South'` 파싱 오류 | argparse 쉼표 split으로 국가명 분리 | `countries` 리스트 코드 내 직접 지정 |
| `clip() got an unexpected keyword argument 'min'` | pandas Series에 `clip(min=)` 사용 | `clip(lower=0)` 으로 수정 |
| `positive() got an unexpected keyword argument 'lower'` | numpy 배열에 `clip(lower=)` 사용 | `clip(min=0)` 으로 수정 |
| `build_model` 중복 정의 | tf.keras 스타일과 from import 스타일 공존 | `tf.keras` 명시적 스타일로 단일화 |
| 한글 폰트 깨짐 | matplotlib 기본 폰트 DejaVu Sans | `plt.rcParams["font.family"] = "Malgun Gothic"` |

---

## 📦 주요 라이브러리

```
pandas
numpy
matplotlib
scipy
pmdarima
tensorflow
scikit-learn
```

---

## 📁 데이터 출처

- **Johns Hopkins CSSE** COVID-19 Data Repository
- 기간: 2020-01-22 ~ 2023-03-09
- 원본: [github.com/CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19)
