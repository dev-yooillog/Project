-- 전체 앱 수와 평균 평점 확인
SELECT 
    COUNT(*) AS total_apps,
    ROUND(AVG(Rating), 2) AS avg_rating
FROM apps;

-- 카테고리별 앱 수 및 평균 평점
SELECT 
    Category,
    COUNT(*) AS num_apps,
    ROUND(AVG(Rating), 2) AS avg_rating
FROM apps
GROUP BY Category
ORDER BY num_apps DESC;

-- 다운로드 수 상위 10개 앱
SELECT App,Category,Installs,Rating
FROM apps
ORDER BY Installs DESC
LIMIT 10;

-- 유료 앱과 무료 앱 평균 평점 비교
SELECT
    Type,
    COUNT(*) AS num_apps,
    ROUND(AVG(Rating), 2) AS avg_rating,
    ROUND(AVG(Price), 2) AS avg_price
FROM apps
GROUP BY Type;

-- 카테고리별 평균 다운로드 수
SELECT
    Category,
    ROUND(AVG(Installs)) AS avg_installs
FROM apps
GROUP BY Category
ORDER BY avg_installs DESC;

-- 리뷰 데이터 기반 감성 분석 요약
SELECT
    Sentiment,
    COUNT(*) AS num_reviews,
    ROUND(AVG(Sentiment_Polarity), 2) AS avg_polarity,
    ROUND(AVG(Sentiment_Subjectivity), 2) AS avg_subjectivity
FROM reviews
GROUP BY Sentiment;

-- 앱별 리뷰 수와 평균 감성 점수
SELECT
    r.App,
    COUNT(*) AS num_reviews,
    ROUND(AVG(r.Sentiment_Polarity), 2) AS avg_polarity,
    ROUND(AVG(r.Sentiment_Subjectivity), 2) AS avg_subjectivity
FROM reviews r
GROUP BY r.App
ORDER BY num_reviews DESC
LIMIT 10;

-- Genre별 유료/무료 앱 비율
SELECT 
    Genres,
    Type,
    COUNT(*) AS num_apps,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY Genres), 2) AS pct
FROM apps
GROUP BY Genres, Type
ORDER BY Genres, Type;

-- 리뷰 수 대비 평균 평점
SELECT 
    App,Reviews,
    ROUND(Rating, 2) AS avg_rating,
    ROUND(Rating * 1.0 / Reviews, 4) AS rating_per_review
FROM apps
ORDER BY rating_per_review DESC
LIMIT 10;

-- 최근 업데이트 앱과 평점 상관관계
SELECT 
    App,
    Rating,
    `Last Updated`
FROM apps
WHERE `Last Updated` IS NOT NULL
ORDER BY `Last Updated` DESC
LIMIT 10;