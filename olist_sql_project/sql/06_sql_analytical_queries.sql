USE olist;

-- 카테고리 1: 고객/주문 분석
-- 01. 결제 건수별 주문 수
SELECT payment_count, COUNT(*) AS order_count
FROM (
    SELECT o.order_id,
           COUNT(p.payment_sequential) AS payment_count
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY o.order_id
) t
GROUP BY payment_count;

-- 02. 주문 상태별 평균 배송 지연일
SELECT o.order_status,
       AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delay_days
FROM orders o
WHERE o.order_status='delivered'
GROUP BY o.order_status;

-- 03. 고객별 결제 단일 평균 금액
SELECT c.customer_unique_id,
       AVG(p.payment_value) AS avg_single_payment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id;

-- 04. 지역별 평균 주문 금액
SELECT c.customer_state,
       AVG(p.payment_value) AS avg_payment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_state;

-- 05. 리뷰 점수별 평균 결제 금액
SELECT r.review_score,
       AVG(p.payment_value) AS avg_payment
FROM reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY r.review_score;

-- 06. 고객별 재구매율 (2회 이상 구매한 고객 비율)
SELECT ROUND(SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS repurchase_rate
FROM (
    SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) t;

-- 07. 고객별 주문 주기 평균 (일 단위)
SELECT customer_unique_id,
       AVG(DATEDIFF(next_purchase, order_purchase_timestamp)) AS avg_gap_days
FROM (
    SELECT c.customer_unique_id,
           o.order_purchase_timestamp,
           LEAD(o.order_purchase_timestamp) OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS next_purchase
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
) t
WHERE next_purchase IS NOT NULL
GROUP BY customer_unique_id;

-- 08. 고객별 결제 유형별 총 결제 금액
SELECT c.customer_unique_id,
       p.payment_type,
       SUM(p.payment_value) AS total_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id, p.payment_type;

-- 09. 월별 신규 고객 수
WITH first_order AS (
    SELECT c.customer_unique_id,
           MIN(o.order_purchase_timestamp) AS first_purchase
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT DATE_FORMAT(first_purchase, '%Y-%m') AS month,
       COUNT(*) AS new_customers
FROM first_order
GROUP BY month;

-- 10. 월별 고객 평균 결제 금액
SELECT DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
       AVG(p.payment_value) AS avg_payment
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY month;

-- 11. 고객별 구매 금액 대비 리뷰 점수 평균
SELECT c.customer_unique_id,
       SUM(p.payment_value) AS total_payment,
       AVG(r.review_score) AS avg_review
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
JOIN reviews r ON o.order_id = r.order_id
GROUP BY c.customer_unique_id;

-- 12. 고객별 결제 유형 다양성
SELECT o.order_id,
       COUNT(DISTINCT p.payment_type) AS payment_type_count
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id;

-- 13. 월별 신규 고객 대비 재구매 고객 비율
WITH first_order AS (
    SELECT c.customer_unique_id,
           MIN(o.order_purchase_timestamp) AS first_purchase
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
       ROUND(SUM(CASE WHEN first_order.first_purchase < o.order_purchase_timestamp THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS repeat_rate
FROM orders o
JOIN first_order ON first_order.customer_unique_id = o.customer_id
GROUP BY month;

-- 카테고리 2: 상품/판매/배송 분석
-- 14. 판매자별 평균 상품 가격
SELECT s.seller_id,
       AVG(oi.price) AS avg_price
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id;

-- 15. 상품별 구매자 수
SELECT oi.product_id,
       COUNT(DISTINCT o.customer_id) AS buyer_count
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY oi.product_id;

-- 16. 특정 카테고리 상품 판매 상위 5
SELECT oi.product_id,
       SUM(oi.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name = 'beleza_saude'
GROUP BY oi.product_id
ORDER BY total_sales DESC
LIMIT 5;

-- 17. 상위 5개 매출 상품 카테고리
SELECT p.product_category_name,
       SUM(oi.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC
LIMIT 5;

-- 18. 주문별 상품 다양성 (상품 카테고리 수)
SELECT o.order_id,
       COUNT(DISTINCT p.product_category_name) AS category_count
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id;

-- 19. 상품 무게 대비 배송비 상관 분석
SELECT oi.product_id,
       AVG(oi.freight_value) AS avg_freight,
       AVG(p.product_weight_g) AS avg_weight
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id;

-- 20. 판매자별 평균 배송 지연일
SELECT s.seller_id,
       AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS avg_delay_days
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY s.seller_id;

-- 21. 상품별 리뷰 점수 표준편차
SELECT oi.product_id,
       STDDEV(r.review_score) AS review_std
FROM order_items oi
JOIN reviews r ON oi.order_id = r.order_id
GROUP BY oi.product_id;

-- 22. 배송 지연 주문 비율 (%) 지역별
SELECT customer_state,
       ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS delayed_pct
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status='delivered'
GROUP BY customer_state;

-- 23. 월별 매출 합계 및 누적 매출
SELECT DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
       SUM(p.payment_value) AS monthly_sales,
       SUM(SUM(p.payment_value)) OVER(ORDER BY DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m')) AS cumulative_sales
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY month;

-- 24. 주문별 상품 수와 총 결제 금액
SELECT o.order_id,
       COUNT(oi.order_item_id) AS item_count,
       SUM(oi.price) AS total_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- 25. 상품별 평균 판매 가격
SELECT oi.product_id,
       AVG(oi.price) AS avg_selling_price
FROM order_items oi
GROUP BY oi.product_id;

-- 26. 카테고리별 매출 성장률
WITH monthly_sales AS (
    SELECT p.product_category_name,
           DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS ym,
           SUM(oi.price) AS sales
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY p.product_category_name, ym
)
SELECT a.product_category_name, a.ym,
       ROUND((a.sales - b.sales)/b.sales*100,2) AS growth_rate
FROM monthly_sales a
LEFT JOIN monthly_sales b
ON a.product_category_name = b.product_category_name
AND DATE_FORMAT(DATE_ADD(a.ym, INTERVAL -1 MONTH), '%Y-%m') = b.ym;
