# Korean Movie Sentiment Analysis

> 한국어 영화 리뷰 데이터를 활용한 감성 분석 프로젝트  
> Baseline 모델(TF-IDF + Logistic Regression) 기반 분석과 TF-IDF feature 시각화 포함

---

## 1. 프로젝트 개요
- 영화 리뷰 데이터를 기반으로 **긍정/부정 감성 분류** 수행
- Baseline 모델: **TF-IDF 벡터화 + Logistic Regression**
- 목표: 데이터 전처리, 모델 학습, 평가, TF-IDF feature 분석 및 시각화

---

## 2. 폴더 구조
korean-movie-sentiment-analysis/
├── data/
│ ├── ratings_train.txt
│ └── ratings_test.txt
├── notebooks/
│ └── 03_modeling.ipynb
├── src/
│ ├── baseline_model.py
│ ├── preprocess.py
│ ├── transformer_model.py
│ ├── utils.py
│ ├── config.py
│ └── init.py
├── results/
│ ├── train_preprocessed.csv # 전처리 완료 데이터
│ ├── tfidf_features.csv # TF-IDF 단어와 회귀 계수
│ └── ... # 시각화 이미지 (선택)
└── README.md

---

## 3. 데이터
- `ratings_train.txt`, `ratings_test.txt` (TSV 형식)
- 컬럼:  
  - `document`: 영화 리뷰 텍스트  
  - `label`: 리뷰 감성 (0 = 부정, 1 = 긍정)

---

## 4. 분석 흐름
1. **데이터 전처리**
   - 불필요 기호 제거, 소문자화, 공백 정리
   - `preprocess.py` 모듈 사용
2. **Train/Validation Split**
   - 80:20 비율
   - `config.py`에서 TEST_SIZE, RANDOM_STATE 설정
3. **Baseline 모델 학습**
   - TF-IDF 벡터화 + Logistic Regression
   - `baseline_model.py`에서 train_baseline() 함수 사용
4. **성능 평가**
   - Confusion Matrix, Classification Report
   - Sample prediction 확인
5. **TF-IDF feature 분석**
   - 상위 단어 확인 → 모델이 중요하게 보는 단어 시각화
6. **CSV 결과 생성**
   - `train_preprocessed.csv`, `tfidf_features.csv` → Tableau, Excel 등 시각화용

---

## 5. 결과
- **Baseline Validation Accuracy:** 약 0.84
- **Confusion Matrix:** 긍정/부정 균형 확인 가능
- **TF-IDF Top Features:** 모델이 감성 판단에 중요하게 사용하는 단어 확인 가능
- **Sample Predictions:** 새로운 리뷰 예측 가능

---

## 6. Tableau 시각화 가이드
### train_preprocessed.csv
- 라벨 분포: Bar Chart / Pie Chart (`label`, `COUNT(document)`)
- 문서 길이: Histogram (`LEN(document)`)

### tfidf_features.csv
- Top 20~30 TF-IDF 단어: Horizontal Bar Chart (`word`, `abs_coef`)
- 색상으로 Coefficient 양/음 구분: 긍정(양수), 부정(음수)

---

## 7. 확장 포인트
- Stopword 제거, 형태소 분석 적용 → 성능 개선
- n-gram 범위 확장 (2-gram, 3-gram) → 문맥 정보 반영
- 다른 모델 적용: SVM, RandomForest, Naive Bayes
- Transformer 모델 적용 (KoBERT, BERT) → 문맥 이해력 강화
- 하이퍼파라미터 튜닝 (max_features, max_iter 등) → 성능 최적화
