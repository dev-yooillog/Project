SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

/* =====================================================
   02_load.sql
   - Olist 데이터 적재 (재실행 가능 / 검증 포함)
   ===================================================== */

USE olist;

/* -----------------------------------------------------
   0. 사전 설정
----------------------------------------------------- */
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

/* -----------------------------------------------------
   1. 재실행 대비: 기존 데이터 초기화
----------------------------------------------------- */
TRUNCATE TABLE customers;
TRUNCATE TABLE orders;
TRUNCATE TABLE order_items;
TRUNCATE TABLE payments;
TRUNCATE TABLE reviews;
TRUNCATE TABLE products;
TRUNCATE TABLE sellers;
TRUNCATE TABLE product_category_translation;
TRUNCATE TABLE geolocation;

/* -----------------------------------------------------
   2. customers
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

/* -----------------------------------------------------
   3. orders
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, 
 @order_purchase_timestamp, 
 @order_approved_at, 
 @order_delivered_carrier_date, 
 @order_delivered_customer_date, 
 @order_estimated_delivery_date)
SET 
order_purchase_timestamp        = NULLIF(@order_purchase_timestamp, ''),
order_approved_at               = NULLIF(@order_approved_at, ''),
order_delivered_carrier_date    = NULLIF(@order_delivered_carrier_date, ''),
order_delivered_customer_date   = NULLIF(@order_delivered_customer_date, ''),
order_estimated_delivery_date   = NULLIF(@order_estimated_delivery_date, '');

/* -----------------------------------------------------
   4. order_items
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, order_item_id, product_id, seller_id, @shipping_limit_date, price, freight_value)
SET 
shipping_limit_date = NULLIF(@shipping_limit_date, '');

/* -----------------------------------------------------
   5. payments
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, payment_sequential, payment_type, payment_installments, payment_value);

/* -----------------------------------------------------
   6. reviews
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(review_id, order_id, review_score, review_comment_title, review_comment_message,
 @review_creation_date, @review_answer_timestamp)
SET 
review_creation_date   = NULLIF(@review_creation_date, ''),
review_answer_timestamp = NULLIF(@review_answer_timestamp, '');

/* -----------------------------------------------------
   7. products
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_category_name, product_name_length, product_description_length,
 product_photos_qty, @product_weight_g, @product_length_cm, @product_height_cm, @product_width_cm)
SET 
product_weight_g  = NULLIF(@product_weight_g, ''),
product_length_cm = NULLIF(@product_length_cm, ''),
product_height_cm = NULLIF(@product_height_cm, ''),
product_width_cm  = NULLIF(@product_width_cm, '');

/* -----------------------------------------------------
   8. sellers
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(seller_id, seller_zip_code_prefix, seller_city, seller_state);

/* -----------------------------------------------------
   9. product_category_translation
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE product_category_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_category_name, product_category_name_english);

/* -----------------------------------------------------
   10. geolocation
----------------------------------------------------- */
LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
 geolocation_city, geolocation_state);

/* -----------------------------------------------------
   11. 적재 결과 검증 (Row Count)
----------------------------------------------------- */
SELECT 'customers' AS table_name, COUNT(*) AS row_cnt FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'product_category_translation', COUNT(*) FROM product_category_translation
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation;

/* -----------------------------------------------------
   12. 설정 복구
----------------------------------------------------- */
SET FOREIGN_KEY_CHECKS = 1;
