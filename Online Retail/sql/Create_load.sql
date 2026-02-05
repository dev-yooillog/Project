# online_retail
-- CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 테이블 생성
DROP TABLE IF EXISTS online_retail;
CREATE TABLE online_retail (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,3),
    CustomerID INT,
    Country VARCHAR(100),
    TotalPrice DECIMAL(10,2),
    IsCancelled TINYINT
);

SHOW TABLES LIKE 'online_retail';
DESCRIBE online_retail;

-- 기본 확인
SELECT COUNT(*) FROM online_retail;
SELECT COUNT(*) AS total_records FROM online_retail;
SELECT * FROM online_retail LIMIT 10;

