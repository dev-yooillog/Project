USE target_ecommerce;

-- 전체 유저 수
SELECT COUNT(*) AS total_users 
FROM user_metrics;

-- 이탈 위험 유저의 수와 비율
SELECT COUNT(*) AS total_users,
    SUM(churn_flag) AS churn_users,
    ROUND(SUM(churn_flag) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM user_metrics;

-- 평균 전환율
SELECT ROUND(AVG(conversion_rate), 4) AS avg_cvr
FROM user_metrics
WHERE conversion_rate IS NOT NULL;

-- 구매 수 Top 10 유저
SELECT user_id, click_count, purchase_count, conversion_rate
FROM user_metrics
ORDER BY purchase_count DESC
LIMIT 10;

-- 전환율 Top 10 유저 (클릭 3회 이상)
SELECT user_id, click_count, purchase_count, conversion_rate
FROM user_metrics
WHERE click_count >= 3
ORDER BY conversion_rate DESC
LIMIT 10;

-- 전환율 구간별 유저 수
SELECT
    CASE
        WHEN conversion_rate = 0    THEN '0%'
        WHEN conversion_rate < 0.1  THEN '0~10%'
        WHEN conversion_rate < 0.3  THEN '10~30%'
        WHEN conversion_rate < 0.5  THEN '30~50%'
        WHEN conversion_rate < 0.7  THEN '50~70%'
        ELSE                             '70~100%'
    END         AS cvr_bucket,
    COUNT(*)    AS user_count
FROM user_metrics
GROUP BY cvr_bucket
ORDER BY user_count DESC;

--  Reporting Dataset
SELECT 
    user_id,
    click_count,
    purchase_count,
    ROUND(conversion_rate, 4)   AS conversion_rate,
    churn_flag,
    CASE
        WHEN purchase_count = 0 AND click_count = 0  THEN 'Inactive'
        WHEN purchase_count = 0 AND click_count > 0  THEN 'Churn Risk'
        WHEN purchase_count >= 2                     THEN 'High Value'
        ELSE                                              'Normal'
    END                         AS user_segment
FROM user_metrics
ORDER BY purchase_count DESC;


