USE olist;

-- 1. 고객 단위 구매 지표

CREATE OR REPLACE VIEW vw_customer_features AS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id)            AS order_cnt,
    SUM(p.payment_value)                  AS total_payment,
    AVG(p.payment_value)                  AS avg_order_value,
    MIN(o.order_purchase_timestamp)       AS first_purchase_dt,
    MAX(o.order_purchase_timestamp)       AS last_purchase_dt
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id;



-- 2. 주문 단위 배송 소요 / 지연 여부

CREATE OR REPLACE VIEW vw_order_delivery AS
SELECT
    order_id,
    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)
        AS delivery_days,
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0
    END AS is_delayed
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;



-- 3. 상품 단위 가격 + 물류 특성

CREATE OR REPLACE VIEW vw_product_features AS
SELECT
    oi.product_id,
    COUNT(*)                    AS sold_cnt,
    AVG(oi.price)               AS avg_price,
    AVG(oi.freight_value)       AS avg_freight,
    AVG(p.product_weight_g)     AS avg_weight
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY oi.product_id;
