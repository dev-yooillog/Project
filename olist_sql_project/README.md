대규모 이커머스 데이터를 기반으로 고객 행동, 매출 구조, 배송 품질을 분석한 SQL 데이터 분석 프로젝트
실무에서 자주 요구되는 비즈니스 지표(RFM, 재구매, 배송 지연 등)를 재현 가능하도록 설계

## Project Overview

- 목적: 이커머스 비즈니스 의사결정에 활용 가능한 핵심 지표 도출
- 범위: 고객 · 주문 · 결제 · 상품 · 리뷰 데이터 통합 분석
- 특징: 실무형 KPI 중심 SQL 분석 시나리오 구현
- 핵심 역량: 조인 설계, 집계 정확도, 윈도우 함수, 비즈니스 지표 도출

## Dataset
Brazil Olist 공개 이커머스 데이터셋 사용

주요 테이블:
- Orders: ~100K+
- Customers: ~90K+
- Order items: ~110K+
- payments
- products
- reviews
- sellers

분석 단위: 고객 / 주문 / 상품 / 카테고리 / 판매자

## Tech Stack
MySQL
Window Functions
Common Table Expressions (CTE)
Data Aggregation
Cohort & RFM Analysis

## Key Analysis Areas
1. Customer Analytics
- 고객별 총 구매액 및 평균 결제액
- 최근 3회 구매 기반 고객 가치 분석
- RFM 지표 산출
- 고객별 평균 주문 간격
- 최근 6개월 매출 추적
- 분석 목적: 고객 세분화 및 LTV 관점 인사이트 확보

2. Revenue & Product Analytics
- 상품별 매출 상위 랭킹
- 카테고리별 월별 매출 추세
- 월별 TOP 카테고리 / 상품
- 판매자별 매출 기여도
- 분석 목적: 매출 드라이버 및 상품 포트폴리오 파악

3. Delivery & Quality Analytics
- 배송 지연률 분석
- 지역별 배송 품질 비교
- 배송 지연 vs 리뷰 점수 관계
- 이상 결제 패턴 탐지
- 분석 목적: 운영 리스크 및 고객 경험 진단

## Key Insights 
- 일부 고객군에서 결제 집중도가 높게 나타남
- 특정 카테고리가 월별 매출 변동성을 주도
- 배송 지연 주문에서 평균 리뷰 점수가 상대적으로 낮음
- 일부 주문에서 비정상적으로 많은 결제 건수 발견

## What This Project Demonstrates
- 대용량 이커머스 데이터 이해 능력
- 정확한 집계 단위 설계 역량
- 실무 지표 중심 SQL 작성 능력
- 분석용 데이터마트 구성 경험

비즈니스 해석 가능한 결과 도출

재현 가능한 분석 파이프라인 구성 능력
