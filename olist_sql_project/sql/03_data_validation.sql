/* =====================================================
   03_validate.sql
   - 데이터 품질 검증 (중복 / 결측 / 이상치 / 무결성)
   ===================================================== */

USE olist;

-- =========================================
-- 1. customers
-- =========================================
-- 중복 customer_id
SELECT customer_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_id
HAVING cnt > 1;

-- 결측값 확인
SELECT 
    SUM(customer_id IS NULL) AS customer_id_null,
    SUM(customer_unique_id IS NULL) AS customer_unique_id_null,
    SUM(customer_zip_code_prefix IS NULL) AS zip_null,
    SUM(customer_city IS NULL) AS city_null,
    SUM(customer_state IS NULL) AS state_null
FROM customers;

-- =========================================
-- 2. orders
-- =========================================
-- 중복 order_id
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING cnt > 1;

-- 결측값 확인
SELECT 
    SUM(order_id IS NULL) AS order_id_null,
    SUM(customer_id IS NULL) AS customer_id_null,
    SUM(order_status IS NULL) AS status_null,
    SUM(order_purchase_timestamp IS NULL) AS purchase_null,
    SUM(order_approved_at IS NULL) AS approved_null,
    SUM(order_delivered_carrier_date IS NULL) AS carrier_null,
    SUM(order_delivered_customer_date IS NULL) AS delivered_null,
    SUM(order_estimated_delivery_date IS NULL) AS estimated_null
FROM orders;

-- 이상치: 구매일이 예상 배송일보다 늦은 경우
SELECT *
FROM orders
WHERE order_purchase_timestamp > order_estimated_delivery_date;

-- =========================================
-- 3. order_items
-- =========================================
-- 중복 (order_id, order_item_id)
SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_id, order_item_id
HAVING cnt > 1;

-- 결측값 확인
SELECT 
    SUM(order_id IS NULL) AS order_id_null,
    SUM(order_item_id IS NULL) AS item_id_null,
    SUM(product_id IS NULL) AS product_null,
    SUM(seller_id IS NULL) AS seller_null,
    SUM(price IS NULL) AS price_null,
    SUM(freight_value IS NULL) AS freight_null
FROM order_items;

-- =========================================
-- 4. payments
-- =========================================
-- order_id별 결제 건수 이상치 (10건 이상)
SELECT order_id, COUNT(*) AS cnt
FROM payments
GROUP BY order_id
HAVING cnt > 10;

-- 결측값 확인
SELECT 
    SUM(payment_sequential IS NULL) AS seq_null,
    SUM(payment_type IS NULL) AS type_null,
    SUM(payment_installments IS NULL) AS installments_null,
    SUM(payment_value IS NULL) AS value_null
FROM payments;

-- =========================================
-- 5. reviews
-- =========================================
-- 중복 review_id
SELECT review_id, COUNT(*) AS cnt
FROM reviews
GROUP BY review_id
HAVING cnt > 1;

-- 결측값 확인
SELECT 
    SUM(review_score IS NULL) AS score_null,
    SUM(review_creation_date IS NULL) AS creation_null,
    SUM(review_answer_timestamp IS NULL) AS answer_null
FROM reviews;

-- 이상치: 리뷰 점수 범위
SELECT DISTINCT review_score
FROM reviews
WHERE review_score NOT BETWEEN 1 AND 5;

-- =========================================
-- 6. products
-- =========================================
-- 중복 product_id
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING cnt > 1;

-- 결측값 확인
SELECT 
    SUM(product_name_length IS NULL) AS name_len_null,
    SUM(product_description_length IS NULL) AS desc_len_null,
    SUM(product_photos_qty IS NULL) AS photo_null,
    SUM(product_weight_g IS NULL) AS weight_null,
    SUM(product_length_cm IS NULL) AS length_null,
    SUM(product_height_cm IS NULL) AS height_null,
    SUM(product_width_cm IS NULL) AS width_null
FROM products;

-- =========================================
-- 7. sellers
-- =========================================
-- 중복 seller_id
SELECT seller_id, COUNT(*) AS cnt
FROM sellers
GROUP BY seller_id
HAVING cnt > 1;

-- 결측값 확인
SELECT 
    SUM(seller_zip_code_prefix IS NULL) AS zip_null,
    SUM(seller_city IS NULL) AS city_null,
    SUM(seller_state IS NULL) AS state_null
FROM sellers;

-- =========================================
-- 8. geolocation
-- =========================================
-- 우편번호별 좌표 개수 이상치
SELECT geolocation_zip_code_prefix, COUNT(*) AS cnt
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING cnt > 10;

-- 결측값 확인
SELECT 
    SUM(geolocation_lat IS NULL) AS lat_null,
    SUM(geolocation_lng IS NULL) AS lng_null
FROM geolocation;

-- =========================================
-- 9. product_category_translation
-- =========================================
-- 중복 카테고리
SELECT product_category_name, COUNT(*) AS cnt
FROM product_category_translation
GROUP BY product_category_name
HAVING cnt > 1;

-- 결측값 확인
SELECT 
    SUM(product_category_name_english IS NULL) AS eng_null
FROM product_category_translation;

-- =========================================
-- 10. FK 무결성 점검
-- =========================================
-- orders → customers
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- order_items → orders
SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- =========================================
-- 11. 검증 요약 (핵심 지표)
-- =========================================
SELECT
    (SELECT COUNT(*) FROM customers) AS customers_cnt,
    (SELECT COUNT(*) FROM orders) AS orders_cnt,
    (SELECT COUNT(*) FROM order_items) AS order_items_cnt,
    (SELECT COUNT(*) FROM payments) AS payments_cnt,
    (SELECT COUNT(*) FROM reviews) AS reviews_cnt;
