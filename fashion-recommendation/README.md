# Fashion Recommendation System
## PyTorch & TensorFlow 성능 비교 연구

## 프로젝트 개요

#### 목표
- **ResNet50 기반 패션 이미지 임베딩** 시스템 구축
- **TensorFlow vs PyTorch** 프레임워크 성능 비교 분석
- **실시간 상품 추천 대시보드** 개발

####  핵심 성과
| 지표 | 결과 |
|------|------|
| 처리 이미지 수 | **861개** (100% 성공률) |
| 특성 벡터 차원 | **2048차원** 임베딩 |
| 구현 완료 | **Streamlit 대시보드** |
| 분석 완료 | **프레임워크별 심화 분석** |

### 기술 스택
```
딥러닝        : ResNet50, Transfer Learning
프레임워크    : TensorFlow 2.20, PyTorch 2.8
시각화        : Matplotlib, Seaborn, Streamlit
데이터 분석   : Pandas, NumPy, Scikit-learn
```

---

## 🏗️ 시스템 아키텍처
```
원본 데이터 → 전처리 → 특성 추출 → 유사도 계산 → 추천
     ↓          ↓         ↓          ↓         ↓
패션 이미지  데이터    ResNet50    코사인    Top-5
  (861개)    검증    (2048차원)   유사도    추천 결과
           (100% 통과)          (실시간)  (대시보드)
```

### 파이프라인 구성 요소

1. **데이터 전처리**
   - 이미지 존재 여부 검증
   - 경로 유효성 검사 및 필터링
   - 100% 유효한 이미지만 선별

2. **특성 추출**
   - TensorFlow 구현: 38.59초, 22.3개/초
   - PyTorch 구현: 57.29초, 15.0개/초

3. **유사도 계산**
   - 코사인 유사도 계산
   - 실시간 추천 생성

4. **대시보드 시각화**
   - 인터랙티브 상품 선택
   - PCA 기반 임베딩 시각화
   - 성능 비교 지표

---

## 성능 분석
### 프레임워크 비교 결과

| 지표 | TensorFlow | PyTorch | 차이 |
|------|-----------|---------|------|
| **처리 시간** | 38.59초 | 57.29초 | **TF 48% 빠름** |
| **처리 속도** | 22.3개/초 | 15.0개/초 | **1.5배 차이** |
| **배치 크기** | 32 | 16 | 2배 효율성 |
| **성공률** | 100% | 100% | 동일한 안정성 |

### 중요한 발견: 임베딩 비교

#### 특성 분포 차이
- **TensorFlow**: 평균 0.412, 표준편차 0.737, 범위 0~17.11
- **PyTorch**: 평균 0.375, 표준편차 0.410, 범위 0~7.19

#### 상관관계 분석
```
샘플별 상관계수: -0.0303 ~ 0.0303 (평균 ≈ 0.001)
```

**핵심 인사이트**: 동일한 ResNet50 아키텍처라도 **프레임워크별로 완전히 다른 특성 공간**을 생성함!

### 성능 차이 원인 분석

1. **배치 처리**: TF의 큰 배치 크기 (32 vs 16)
2. **전처리 차이**: 서로 다른 정규화 방식
3. **하드웨어 최적화**: TF의 Intel MKL-DNN 활용
4. **구현 세부사항**: Global Average Pooling 방식 차이

---

## 구현 상세

### 핵심 구현

#### TensorFlow 구현
```python
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.resnet50 import preprocess_input

# 모델 초기화
model = ResNet50(weights='imagenet', include_top=False, pooling='avg')

# 특성 추출
features = model.predict(processed_images, batch_size=32)
# 결과: 38.59초, 22.3개/초 처리
```

#### PyTorch 구현
```python
import torch
import torch.nn as nn
from torchvision import models, transforms

class ResNet50FeatureExtractor(nn.Module):
    def __init__(self, original_model):
        super().__init__()
        self.features = nn.Sequential(*list(original_model.children())[:-1])
    
    def forward(self, x):
        x = self.features(x)
        x = torch.flatten(x, 1)
        return x

# 결과: 57.29초, 15.0개/초 처리
```

### 🔧 기술적 해결책

#### 1. 데이터 전처리 및 검증
```python
import os
import pandas as pd

# 이미지 경로 검증
styles['image_path'] = styles['id'].apply(lambda x: f"{x}.jpg")
styles = styles[styles['image_path'].apply(os.path.exists)]
# 결과: 100% 유효한 이미지만 선별
```

#### 2. 메모리 최적화
```python
import gc
import torch

# 배치별 메모리 정리
if batch_idx % 10 == 0:
    torch.cuda.empty_cache()
    gc.collect()
```

#### 3. 견고한 오류 처리
```python
def load_and_preprocess_image(img_path):
    try:
        img = image.load_img(img_path, target_size=(224, 224))
        img_array = image.img_to_array(img)
        return preprocess_input(img_array)
    except Exception as e:
        print(f"이미지 처리 오류: {e}")
        return None
```

#### 4. Streamlit 대시보드
```python
import streamlit as st
from sklearn.metrics.pairwise import cosine_similarity

def get_top_similar(embeddings, index, top_k=5):
    query_vec = embeddings[index].reshape(1, -1)
    similarities = cosine_similarity(query_vec, embeddings)[0]
    similar_indices = similarities.argsort()[-top_k-1:-1][::-1]
    return similar_indices

st.title("패션 추천 시스템")
selected_product = st.selectbox("상품을 선택하세요", product_list)
recommendations = get_top_similar(embeddings, selected_product, top_k=5)
```

---
