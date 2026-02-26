-- basic SQL Questions 

USE olist;

/* 01. 전체 고객 수 조회 */
SELECT COUNT(*) AS total_customers
FROM customers;

/* 02. 특정 도시('São Paulo') 고객 수 조회 */
SELECT COUNT(*) AS city_customers
FROM customers
WHERE customer_city = 'São Paulo';

/* 03. 배송 완료(delivered) 주문 수 조회 */
SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';

/* 04. 전체 주문 금액 합계 */
SELECT SUM(payment_value) AS total_payment
FROM payments;

/* 05. 고객별 총 결제 금액 */
SELECT c.customer_unique_id, SUM(p.payment_value) AS total_payment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id;

/* 06. 고객별 마지막 구매일 */
SELECT c.customer_unique_id, MAX(o.order_purchase_timestamp) AS last_purchase
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;

/* 07. 상품별 평균 가격 */
SELECT oi.product_id, AVG(oi.price) AS avg_price
FROM order_items oi
GROUP BY oi.product_id;

/* 08. 주문별 아이템 수 */
SELECT order_id, COUNT(*) AS item_count
FROM order_items
GROUP BY order_id;

/* 09. 특정 기간 주문 수 (2020-01-01 ~ 2020-12-31) */
SELECT COUNT(*) AS orders_2020
FROM orders
WHERE order_purchase_timestamp >= '2020-01-01'
AND order_purchase_timestamp < '2021-01-01';

-- WHERE order_purchase_timestamp BETWEEN '2020-01-01' AND '2020-12-31';
-- DATETIME이면 2020-12-31 23:59:59가 포함 안 될 수도 있음

/* 10. 리뷰 점수 평균 */
SELECT AVG(review_score) AS avg_review_score
FROM reviews;

/* 11. 배송 완료 주문 중 결제 평균 금액 */
SELECT AVG(order_total) AS avg_delivered_payment
FROM (
    SELECT o.order_id,
           SUM(p.payment_value) AS order_total
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
) t;

/* 12. 특정 고객('c8a5d...') 주문 수 조회 */
SELECT COUNT(*) AS order_count
FROM orders
WHERE customer_id = 'c8a5d2f...'; -- 고객 ID 예시

/* 13. 주문 상태별 주문 수 */
SELECT order_status, COUNT(*) AS cnt
FROM orders
GROUP BY order_status;

/* 14. 고객별 주문 수 내림차순 정렬 */
SELECT c.customer_unique_id, COUNT(o.order_id) AS order_cnt
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY order_cnt DESC;

/* 15. 특정 상품 판매 수 */
SELECT COUNT(*) AS sold_count
FROM order_items
WHERE product_id = 'b0b4b...'; 

/* 16. 특정 결제 유형('credit_card') 총 결제액 */
SELECT SUM(payment_value) AS total_credit_payment
FROM payments
WHERE payment_type = 'credit_card';

/* 17. 고객별 평균 결제 금액 */
SELECT c.customer_unique_id,
       AVG(p.payment_value) AS avg_payment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id;

/* 18. 주문별 결제 총액 */
SELECT o.order_id, SUM(p.payment_value) AS total_order_payment
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id;

/* 19. 고객별 첫 구매일 */
SELECT c.customer_unique_id, MIN(o.order_purchase_timestamp) AS first_purchase
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;

/* 20. 상품별 총 판매 금액 */
SELECT oi.product_id, SUM(oi.price + oi.freight_value) AS total_sales
FROM order_items oi
GROUP BY oi.product_id;

/* 21. 고객별 총 구매 횟수 */
SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;

/* 22. 특정 고객이 구매한 상품 목록 */
SELECT DISTINCT oi.product_id
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = 'c8a5d2f...';

/* 23. 주문별 평균 배송비 */
SELECT o.order_id, AVG(oi.freight_value) AS avg_freight
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

/* 24. 고객별 총 배송비 */
SELECT c.customer_unique_id, SUM(oi.freight_value) AS total_freight
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id;

/* 25. 상품별 평균 배송비 */
SELECT product_id, AVG(freight_value) AS avg_freight
FROM order_items
GROUP BY product_id;

/* 26. 특정 카테고리 상품 수 */
SELECT COUNT(*) AS category_count
FROM products
WHERE product_category_name = 'cama_mesa_banho';

/* 27. 주문 상태가 delivered인 주문 중 특정 고객 주문 수 */
SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE customer_id = 'c8a5d2f...' AND order_status = 'delivered';

/* 28. 리뷰 작성된 주문 수 */
SELECT COUNT(DISTINCT order_id) AS reviewed_orders
FROM reviews;

/* 29. 고객별 리뷰 점수 평균 */
SELECT c.customer_unique_id, AVG(r.review_score) AS avg_review
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN reviews r ON o.order_id = r.order_id
GROUP BY c.customer_unique_id;

/* 30. 주문별 총 상품 수 및 총 금액 */
SELECT o.order_id, COUNT(oi.order_item_id) AS item_count, SUM(oi.price + oi.freight_value)
 AS total_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;
