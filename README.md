# Data Analysis Portfolio

데이터 분석 학습 및 실무 경험을 정리한 포트폴리오 저장소입니다.
Python, SQL을 활용한 ETL 파이프라인, 머신러닝, 딥러닝, 통계 분석 프로젝트를 포함합니다.

---

## Projects

| 프로젝트 | 설명 | 주요 기술 |
|----------|------|-----------|
| [Ad](#ad) | 광고 클릭 예측 (Accuracy 96.5%, AUC 0.993) | Python, scikit-learn |
| [Covid19](#covid19) | 5개국 코로나19 확산 분석 및 예측 | Python, ARIMA, LSTM |
| [Game](#game) | 보드게임 추천 시스템 + 모델 경량화 | Python, PyTorch |
| [Netflix](#netflix) | 콘텐츠 전략 분석 및 추천 시스템 | Python, NetworkX |
| [Online Retail](#online-retail) | 온라인 리테일 고객 행동 분석 | Python, MySQL |
| [Restaurant Consumption Trends Analysis](#restaurant-consumption-trends-analysis) | 전국 음식점 소비 트렌드 RFM 클러스터링 | Python, scikit-learn |
| [Supply Chain](#supply-chain) | 물류 배송 지연 예측 (AUC 0.810) | Python, XGBoost |
| [User Mobile App Interaction Data](#user-mobile-app-interaction-data) | 모바일 앱 리텐션·코호트·퍼널 분석 | Python |
| [citibike-demand-analysis](#citibike-demand-analysis) | 뉴욕 Citi Bike 수요 예측 (MAE 75% 개선) | Python, LightGBM |
| [classicmodels](#classicmodels) | MySQL classicmodels 비즈니스 SQL 분석 | MySQL |
| [eCommerce](#ecommerce) | 3% SKU로 29% 매출 창출 RFM 분석 | Python, scikit-learn |
| [fashion-recommendation](#fashion-recommendation) | ResNet50 패션 추천 (TF vs PyTorch 비교) | Python, TensorFlow, PyTorch |
| [googleplay-trend-monitor](#googleplay-trend-monitor) | Google Play 앱·리뷰 ETL 파이프라인 | Python, SQLite |
| [korean-movie-sentiment-analysis](#korean-movie-sentiment-analysis) | 한국 영화 리뷰 감성 분석 | Python, NLP |
| [olist_sql_project](#olist_sql_project) | 브라질 이커머스 Olist SQL 분석 | MySQL |
| [stock_price_prediction](#stock_price_prediction) | 미국 기술주 8종목 포트폴리오 분석 및 예측 | Python, Streamlit |
| [따릉이](#따릉이) | 서울시 공공자전거 이용 패턴 분석 ETL | Python, MySQL |

---

## Ad

> 사용자 행동 데이터(1,000건) 기반 광고 클릭 여부를 예측하는 이진 분류 모델을 개발합니다.

- 7개 모델 비교 → **Random Forest 최종 선정 (Accuracy 96.5%, AUC 0.993)**
- 9개 파생변수 생성 (Engagement_Score, Ad_Affinity_Score 등), GridSearchCV 540개 조합 탐색
- 고효율 세그먼트 발굴: 40세 이상 & 저체류 시간 고객 클릭률 98.4%

**Stack** `Python 3.10` `scikit-learn` `pandas` `scipy`

---

## Covid19

> Johns Hopkins CSSE 데이터(2020~2023) 기반 한국·미국·독일·일본·프랑스 5개국 감염 확산 분석 및 예측 프로젝트입니다.

- SEIR 모델로 기초감염재생산수(R₀) 추정
- Auto-ARIMA 14일 예측, 다변량 LSTM 30일 예측
- 봉쇄 정책 전후 성장률 변화 정량 분석 (미국: -19.2%p)

**Stack** `Python 3.10` `pmdarima` `tensorflow` `scipy`

---

## Game

> 1,894만 개 보드게임 평점 데이터를 활용한 딥러닝 추천 시스템과 모델 경량화 연구입니다.

- PyTorch NCF로 Baseline 대비 **RMSE 7.43% 개선** (1.1960 → 1.1071)
- 2-bit 양자화로 모델 크기 **93.4% 감소** (25.97 MB → 1.72 MB)
- SQL 기반 사용자 세그먼테이션 (Power / Active / Regular / Casual)

**Stack** `Python 3.10` `PyTorch` `scikit-learn` `SQLite`

---

## Netflix

> Netflix 8,807개 콘텐츠 데이터를 분석하고 TF-IDF 기반 추천 시스템을 구축합니다.

- TV 프로그램 비율 증가 추세 분석 (2021년 33.7%, 2024년 38.8% 예측)
- 배우-감독 협업 네트워크 분석 (NetworkX Degree/Betweenness Centrality)
- TF-IDF + 코사인 유사도 기반 콘텐츠 추천 (동일 장르 매칭률 80%+)

**Stack** `Python 3.10` `scikit-learn` `NetworkX` `matplotlib`

---

## Online Retail

> UCI Online Retail 데이터를 Python으로 전처리하고 MySQL에 적재하여 고객 구매 행동을 분석합니다.

- 결측치 처리, IsCancelled 파생변수, TotalPrice 생성 후 MySQL 적재
- 고객별·국가별 매출, 월별 추이, 시간대별 구매량, 반복 구매 세그먼트 분석

**Stack** `Python 3.10` `pandas` `MySQL` `SQLAlchemy`

---

## Restaurant Consumption Trends Analysis

> 공공데이터(KC_618) 기반 전국 음식점 소비 트렌드를 분석하고 RFM 프레임워크와 K-Means 클러스터링으로 지역을 유형화합니다.

- 2021~2024년 시군구 단위 326,826건 분석
- **포화형 소도시** vs **성장형 대도시** 2개 클러스터 도출 (Silhouette Score 0.595)
- 클러스터별 LTV 추정 및 투자 우선순위 산출 (경기도 화성시 1위)

**Stack** `Python 3.10` `scikit-learn` `pandas`

---

## Supply Chain

> 스마트 물류 데이터를 기반으로 배송 지연 여부를 예측하는 이진 분류 모델을 개발합니다.

- Logistic Regression / Random Forest / XGBoost 비교 → **XGBoost 최종 선정 (AUC 0.810)**
- 교통 상태(Traffic_Status)가 지연 예측의 핵심 변수 (중요도 57.2%)

**Stack** `Python 3.10` `scikit-learn` `xgboost`

---

## User Mobile App Interaction Data

> 60,471명의 모바일 앱 사용자 인터랙션 데이터를 분석하여 이탈 지점과 리텐션 개선 전략을 도출합니다.

- D1 리텐션 3.0% — 심각한 온보딩 문제 발견
- 퍼널 분석으로 첫 클릭 단계에서 **85% 이탈** 확인
- 주별 코호트 분석, 사용자 세그먼테이션 (Light / Medium / Heavy User)

**Stack** `Python 3.10` `pandas` `scipy` `plotly`

---

## citibike-demand-analysis

> 뉴욕 Citi Bike 2025년 4~9월 28,206,527건 이용 데이터를 분석하고 시간별 수요를 예측합니다.

- **LightGBM이 Baseline 대비 MAE 75%, RMSE 74% 개선** (MAE 1,627 → 404)
- Prophet 대비 LightGBM 우수 확인, Lag·Rolling 피처가 핵심 예측 변수
- 스테이션별 순유입/유출 분석으로 자전거 재배치 우선순위 도출

**Stack** `Python 3.10` `LightGBM` `Prophet` `pandas` `pyarrow`

---

## classicmodels

> MySQL 예제 DB(classicmodels)를 활용하여 고객·매출·수익성 비즈니스 지표를 SQL로 분석합니다.

- RFM 세그먼테이션 (VIP / Loyal / At Risk / Regular)
- 코호트 분석: 첫 구매 시점별 재구매 패턴 추적
- 파레토 법칙 검증, 윈도우 함수 기반 국가별 랭킹, Funnel 분석

**Stack** `MySQL` `SQL`

---

## eCommerce

> 인도 이커머스 기업의 Amazon·국제 판매 데이터(148,012건)를 분석하여 수익성 최적화 전략을 도출합니다.

- 전체 7,113개 SKU 중 **3%(211개)가 29% 매출** 창출
- K-Means 클러스터링으로 SKU 세분화 (Silhouette Score 0.7624)
- 배송 완료율 격차 해소 및 휴면 상품 정리 전략 수립

**Stack** `Python 3.10` `scikit-learn` `pandas`

---

## fashion-recommendation

> ResNet50 기반 패션 이미지 임베딩 추천 시스템을 구축하고 TensorFlow와 PyTorch 성능을 비교합니다.

- 861개 이미지 100% 처리, 2048차원 임베딩 생성
- **TensorFlow가 PyTorch 대비 48% 빠른 처리 속도** (22.3 vs 15.0 개/초)
- 동일 아키텍처라도 프레임워크별 완전히 다른 특성 공간 생성 확인
- Streamlit 실시간 추천 대시보드 구현

**Stack** `Python 3.10` `TensorFlow` `PyTorch` `Streamlit`

---

## googleplay-trend-monitor

> Google Play 스토어 앱·리뷰 데이터를 수집·정제하고 SQLite에 적재하는 ETL 파이프라인을 구축합니다.

- 앱 및 리뷰 데이터 정제 (Size 단위 통일, Installs 변환, 감성 결측 처리)
- `apps`, `reviews` 테이블 SQLite 적재 및 데이터 품질 검증

**Stack** `Python 3.10` `pandas` `SQLite`

---

## korean-movie-sentiment-analysis

> 한국 영화 리뷰 텍스트를 기반으로 긍정/부정 감성을 분류하는 Baseline 모델을 구축합니다.

- TF-IDF 벡터화 + Logistic Regression → **Validation Accuracy 0.84**
- TF-IDF feature 분석으로 감성 판단 주요 단어 시각화
- Tableau 연계용 결과 CSV 생성 (`train_preprocessed.csv`, `tfidf_features.csv`)

**Stack** `Python 3.10` `scikit-learn` `NLP`

---

## olist_sql_project

> 브라질 이커머스 플랫폼 Olist 데이터(주문 100K+)를 SQL로 분석하여 고객·매출·배송 품질 지표를 도출합니다.

- RFM 지표 산출, 최근 6개월 매출 추적, 고객별 평균 주문 간격 분석
- 카테고리별 월별 매출 추세, 판매자별 매출 기여도 분석
- 배송 지연 vs 리뷰 점수 관계 분석, 이상 결제 패턴 탐지

**Stack** `MySQL` `SQL`

---

## stock_price_prediction

> 미국 기술주 8종목(AAPL, MSFT, TSLA, NVDA 등)의 주가 데이터를 분석하고 포트폴리오를 최적화합니다.

- Monte Carlo 시뮬레이션(20,000회)으로 효율적 프론티어 탐색
- Lag-5 선형회귀로 수익률 예측, 역사적 vs 예측 기반 포트폴리오 비교
- NVDA 최고 Sharpe Ratio 1.93, Streamlit 인터랙티브 대시보드

**Stack** `Python 3.10` `scikit-learn` `yfinance` `Streamlit`

---

## 따릉이

> 서울시 공공자전거 따릉이 2023~2025년 이용 데이터를 전처리하고 MySQL에 적재하여 이용 패턴을 분석합니다.

- 월별 KPI, 성별·연령대별 이용 패턴, 대여소 성과, 탄소 절감 효과 분석
- 파생 변수 생성: `distance_km`, `speed_kmh`, `day_type`
- BI 연계용 View(`v_bike_usage_bi`) 생성

**Stack** `Python 3.10` `MySQL` `SQL` `SQLAlchemy`

---

## Tech Stack

| 분야 | 도구 |
|------|------|
| Language | Python 3.10, SQL |
| ML / DL | scikit-learn, XGBoost, LightGBM, PyTorch, TensorFlow |
| Data Processing | pandas, numpy, scipy |
| Visualization | matplotlib, seaborn, plotly, Streamlit |
| NLP | TF-IDF, Logistic Regression |
| Database | MySQL, SQLite |
| ETL | SQLAlchemy, pymysql |
| Time Series | Prophet, ARIMA, LSTM |
