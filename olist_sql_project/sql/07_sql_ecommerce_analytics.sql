USE olist;

/* 01. 리뷰 점수 1점/5점 비율 */
SELECT 
    SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*),0) AS score_1_pct,
    SUM(CASE WHEN review_score = 5 THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*),0) AS score_5_pct
FROM reviews;

/* 02. 월별 신규 고객 수 */
WITH first_order AS (
    SELECT 
        customer_unique_id, 
        MIN(order_purchase_timestamp) AS first_order
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY customer_unique_id
)
SELECT 
    DATE_FORMAT(first_order, '%Y-%m') AS month,
    COUNT(customer_unique_id) AS new_customers
FROM first_order
GROUP BY month;

/* 03. 주문 대비 결제 건수 이상치 탐지 (10건 이상) */
SELECT 
    o.order_id, 
    COUNT(*) AS payment_count
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id
HAVING payment_count > 10;

/* 04. 고객별 총/평균/최대 구매액, 구매 횟수 */
WITH order_payment AS (
    SELECT 
        o.order_id,
        c.customer_unique_id,
        SUM(p.payment_value) AS order_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY o.order_id, c.customer_unique_id
)
SELECT
    customer_unique_id,
    COUNT(order_id)        AS total_orders,
    SUM(order_total)       AS total_payment,
    AVG(order_total)       AS avg_payment,
    MAX(order_total)       AS max_payment
FROM order_payment
GROUP BY customer_unique_id;

/* 05. 주문별 총 결제액, 총 상품 수, 평균 가격 */
WITH payment_agg AS (
    SELECT order_id, SUM(payment_value) AS total_payment
    FROM payments
    GROUP BY order_id
),
item_agg AS (
    SELECT 
        order_id,
        COUNT(order_item_id) AS item_count,
        AVG(price) AS avg_price
    FROM order_items
    GROUP BY order_id
)
SELECT
    o.order_id,
    p.total_payment,
    i.item_count,
    i.avg_price
FROM orders o
LEFT JOIN payment_agg p ON o.order_id = p.order_id
LEFT JOIN item_agg i ON o.order_id = i.order_id;

/* 06. 고객별 평균 결제 금액 상위 10명 */
WITH order_payment AS (
    SELECT 
        c.customer_unique_id,
        o.order_purchase_timestamp,
        SUM(p.payment_value) AS order_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id, o.order_id, o.order_purchase_timestamp
),
ranked_orders AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY customer_unique_id 
               ORDER BY order_purchase_timestamp DESC
           ) AS rn
    FROM order_payment
)
SELECT
    customer_unique_id,
    AVG(order_total) AS avg_last_3_payment
FROM ranked_orders
WHERE rn <= 3
GROUP BY customer_unique_id;

/* 07. 특정 상품 구매자 중 최고 결제액 고객 */
SELECT 
    c.customer_unique_id,
    SUM(p.payment_value) AS total_payment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments p ON o.order_id = p.order_id
WHERE oi.product_id = 'b0b4b...'
GROUP BY c.customer_unique_id
ORDER BY total_payment DESC
LIMIT 1;

/* 08. 고객별 최근 3회 구매 평균 금액 */
WITH ranked_orders AS (
    SELECT 
        c.customer_unique_id,
        p.payment_value,
        ROW_NUMBER() OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp DESC) AS rn
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
)
SELECT 
    customer_unique_id,
    AVG(payment_value) AS avg_last_3_payment
FROM ranked_orders
WHERE rn <= 3
GROUP BY customer_unique_id;

/* 09. 고객별 최근 6개월 매출 추적 */
SELECT 
    c.customer_unique_id,
    SUM(p.payment_value) AS last_6m_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= '2018-01-01'
GROUP BY c.customer_unique_id;

/* 10. 고객별 RFM 점수 (Recency, Frequency, Monetary) */
WITH last_purchase AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(p.payment_value) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT *,
       DATEDIFF(CURDATE(), last_order) AS recency
FROM last_purchase;

/* 11. 고객별 평균 배송일과 지연 주문 수 */
SELECT 
    c.customer_unique_id,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS avg_delivery_days,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS delayed_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id;

/* 12. 배송 지연률 높은 상위 10 고객 */
SELECT 
    c.customer_unique_id,
    ROUND(
        SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS delayed_pct
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY delayed_pct DESC
LIMIT 10;

/* 13. 지역별 주문 수 대비 지연율 */
SELECT 
    c.customer_state,
    COUNT(o.order_id) AS total_orders,
    ROUND(
        SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)
        * 100.0 / COUNT(o.order_id),
        2
    ) AS delayed_pct
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state;

/* 14. 고객별 최근 구매 상품 TOP 1 */
WITH ranked AS (
    SELECT
        c.customer_unique_id,
        oi.product_id,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp DESC, o.order_id DESC
        ) AS rn
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
)
SELECT customer_unique_id, product_id
FROM ranked
WHERE rn = 1;

/* 15. 고객별 평균 주문 간격(일) */
WITH ordered AS (
    SELECT 
        c.customer_unique_id,
        o.order_purchase_timestamp,
        LEAD(o.order_purchase_timestamp) OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS next_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
)
SELECT 
    customer_unique_id,
    AVG(DATEDIFF(next_order, order_purchase_timestamp)) AS avg_gap_days
FROM ordered
WHERE next_order IS NOT NULL
GROUP BY customer_unique_id;

/* 16. 고객별 결제 유형 비중 */
SELECT 
    c.customer_unique_id,
    p.payment_type,
    SUM(p.payment_value)/SUM(SUM(p.payment_value)) OVER(PARTITION BY c.customer_unique_id) AS payment_ratio
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id, p.payment_type;

/* 17. 상품별 판매 상위 5 상품 추출 */
SELECT 
    product_id,
    SUM(price) AS total_sales
FROM order_items
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 5;

/* 18. 카테고리별 가장 많이 팔린 상품 */
SELECT 
    p.product_category_name,
    oi.product_id,
    COUNT(*) AS sold_count
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name, oi.product_id
ORDER BY p.product_category_name, sold_count DESC;

/* 19. 상품별 리뷰 점수와 판매량 상관관계 */
SELECT 
    oi.product_id,
    AVG(r.review_score) AS avg_review,
    COUNT(oi.order_id) AS sold_count
FROM order_items oi
JOIN reviews r ON oi.order_id = r.order_id
GROUP BY oi.product_id;

/* 20. 판매자별 평균 배송 기간과 총 매출 */
SELECT 
    s.seller_id,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS avg_delivery_days,
    SUM(oi.price) AS total_sales
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id;

/* 21. 판매자별 판매 카테고리 수 */
SELECT 
    s.seller_id,
    COUNT(DISTINCT p.product_category_name) AS category_count
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY s.seller_id;

/* 22. 판매자별 총 판매액 대비 상품 수 */
SELECT 
    s.seller_id,
    SUM(oi.price) AS total_sales,
    COUNT(DISTINCT oi.product_id) AS unique_products
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id;

/* 23. 월별 매출 TOP 3 카테고리 */
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        p.product_category_name,
        SUM(oi.price) AS total_sales
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY month, p.product_category_name
)
SELECT month, product_category_name, total_sales
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY month ORDER BY total_sales DESC) AS rn
    FROM monthly_sales
) t
WHERE rn <= 3;

/* 24. 상품별 월별 매출 상위 3 상품 */
WITH monthly_product_sales AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        oi.product_id,
        SUM(oi.price) AS total_sales
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY month, oi.product_id
)
SELECT month, product_id, total_sales
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY month ORDER BY total_sales DESC) AS rn
    FROM monthly_product_sales
) t
WHERE rn <= 3;

/* 25. 고객별 가장 많이 구매한 상품 */
SELECT 
    customer_unique_id, 
    product_id, 
    COUNT(*) AS cnt
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY customer_unique_id, product_id
ORDER BY customer_unique_id, cnt DESC;
