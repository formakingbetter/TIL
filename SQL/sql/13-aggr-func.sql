-- 13-aggr-func.sql
USE lecture;
SELECT * FROM sales;
-- COUNT
SELECT COUNT(id) AS 매출건수
FROM sales;

-- 적당한 데이터량
SELECT COUNT(customer_id)
FROM sales;
-- 서울매출만 더하기
SELECT
	FORMAT(SUM(total_amount),0) AS 서울매출
FROM sales
WHERE region='서울';
-- AVG(평균)
SELECT
	COUNT(*) AS 총주문건수,
    COUNT(DISTINCT customer_id) AS 고객수,
    COUNT( DISTINCT product_name) AS 제품수
FROM sales;
SELECT * FROM sales;
-- SUM (총합)
SELECT 
	-- 천단위, 찍기
	FORMAT(SUM(total_amount),0) AS 총매출,
    SUM(quantity) AS 총판매수량
from SALES;

SELECT 
	FORMAT(SUM(IF(region='서울',total_amount,0)),0) AS 서울매출,
    FORMAT(SUM(
    IF(
		category='전자제품',total_amount,0
    )
    ),0) AS '전자제품 판매량'
    
FROM sales;
-- AVG(평균)
SELECT 
		AVG(total_amount) AS 평균매출액,
        AVG(quantity) as 평균판매수량,
        ROUND(AVG(unit_price)) AS 평균단가
FROM sales;

-- min/max SELECT
	FORMAT(MIN(total_amount),0)  AS 최소매출액,
    MAX(total_amount) AS 최대매출액,
    MIN(order_date) AS '첫주문일',
    MAX(order_date) AS '마지막 주문일'
FROM sales;

SELECT