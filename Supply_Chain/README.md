# Supply Chain Logistics Delay Prediction

> 스마트 물류 데이터를 활용한 배송 지연 이진 분류 모델 개발 및 주요 지연 요인 분석

---

## 프로젝트 개요

스마트 물류 데이터셋(smart_logistics_dataset.csv)을 기반으로 배송 지연 여부를 예측합니다. Logistic Regression, Random Forest, XGBoost 세 가지 모델을 비교하고, 최적 모델을 선정하여 물류 지연의 핵심 요인을 도출합니다.

---

## 데이터

| 항목 | 내용 |
|------|------|
| 파일 | smart_logistics_dataset.csv |
| 레코드 수 | 1,000건 |
| 피처 수 | 16개 |
| 타겟 변수 | Logistics_Delay (0: 정상, 1: 지연) |
| 클래스 비율 | 정상 43.4% / 지연 56.6% |

**주요 컬럼**

| 컬럼명 | 설명 |
|--------|------|
| `Timestamp` | 기록 시각 |
| `Asset_ID` | 트럭 식별자 (Truck_1 ~ Truck_10) |
| `Latitude` / `Longitude` | GPS 좌표 |
| `Inventory_Level` | 재고 수준 |
| `Shipment_Status` | 배송 상태 (Delayed / In Transit / Delivered) |
| `Temperature` | 온도 |
| `Humidity` | 습도 |
| `Traffic_Status` | 교통 상태 (Detour / Heavy / Clear) |
| `Waiting_Time` | 대기 시간 |
| `User_Transaction_Amount` | 거래 금액 |
| `User_Purchase_Frequency` | 구매 빈도 |
| `Asset_Utilization` | 자산 활용률 |
| `Demand_Forecast` | 수요 예측값 |
| `Logistics_Delay_Reason` | 지연 원인 (Weather / Traffic / Mechanical Failure) |
| `Logistics_Delay` | 타겟 (0: 정상, 1: 지연) |

---

## 분석 파이프라인

```
데이터 로드 및 탐색 (EDA)
    ↓
전처리 (결측값 처리, 범주형 인코딩)
    ↓
피처 선택 및 타겟 변수 설정
    ↓
데이터 분할 (훈련 70% / 테스트 30%) 및 표준화
    ↓
3개 모델 학습 및 비교 (LR / RF / XGBoost)
    ↓
최적 모델 선정 및 특성 중요도 분석
    ↓
예측 결과 저장
```

---

## 모델 비교 결과

| 모델 | 정확도 | ROC-AUC | 정밀도 | 재현율 |
|------|--------|---------|--------|--------|
| Logistic Regression | 50.0% | 0.451 | 54.2% | 75.3% |
| Random Forest | 72.7% | 0.797 | 79.7% | 69.4% |
| **XGBoost** | **74.0%** | **0.810** | **81.1%** | **70.6%** |

**최종 선택 모델: XGBoost** (ROC-AUC 기준 최고 성능)

---

## 주요 지연 요인 분석 (XGBoost 특성 중요도)

| 순위 | 피처 | 중요도 |
|------|------|--------|
| 1 | Traffic_Status_encoded | 57.2% |
| 2 | Asset_Utilization | 4.8% |
| 3 | Humidity | 4.8% |
| 4 | Temperature | 4.8% |
| 5 | Inventory_Level | 4.4% |

교통 상태(Traffic_Status)가 배송 지연의 가장 지배적인 요인으로, 전체 중요도의 57.2%를 차지합니다.

---

## 기술 스택

- **언어**: Python 3.x
- **데이터 처리**: pandas, numpy
- **시각화**: matplotlib, seaborn
- **머신러닝**: scikit-learn (LogisticRegression, RandomForestClassifier, StandardScaler), xgboost (XGBClassifier)

---

## 파일 구조

```
.
├── data/
│   └── smart_logistics_dataset.csv
├── output/
│   ├── 01_eda_analysis.png          # EDA 시각화
│   ├── 02_model_comparison.png      # 모델 비교 (ROC Curve, 성능 막대)
│   ├── 03_feature_importance.png    # 특성 중요도 및 누적 기여도
│   └── predictions.csv             # 예측 결과 (prediction / probability / actual / correct)
└── analysis.ipynb                  # 메인 분석 노트북
```

---

## 실행 방법

```bash
# 의존성 설치
pip install pandas numpy matplotlib seaborn scikit-learn xgboost

# Jupyter Notebook 실행
jupyter notebook analysis.ipynb
```

> **주의**: `matplotlib` 한글 폰트로 `Malgun Gothic`을 사용합니다. Windows 환경 외에서는 별도 폰트 설정이 필요할 수 있습니다.

---

## 주요 인사이트

- 교통 상태(Detour, Heavy, Clear)가 배송 지연 예측에 가장 큰 영향을 미침
- 자산 활용률(Asset_Utilization), 기온(Temperature), 습도(Humidity) 등 환경 요인이 그 다음 순위를 차지
- XGBoost는 Random Forest 대비 정확도와 ROC-AUC 모두 소폭 우수하며, Logistic Regression 대비 현저한 성능 개선
