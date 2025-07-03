USE practice;
CREATE TABLE sales AS SELECT * FROM lecture.sales;
CREATE TABLE products AS SELECT * FROM lecture.products;
CREATE TABLE customers AS SELECT * FROM lecture.customers;
-- 다닝ㄹ값 서브쿼리
-- 평균 이상 매출 주문들(성과가 좋은 주문들)
SELECT * 
FROM sales
WHERE total_amount >=(SELECT AVG(total_amount) FROM sales);
-- 최고 매출 지역의 모든 주문들
SELECT *
FROM sales
WHERE region in (SELECT region FROM 
(SELECT region FROM sales GROUP BY region 
ORDER BY MAX(total_amount) ASC 
limit 2 )AS QRQ)

;
SELECT region,SUM(total_amount)
FROM sales
GROUP BY region
ORDER BY SUM(total_amount) DESC;
SELECT * 
FROM sales
WHERE region in (SELECT region FROM sales WHERE SUM(total_amount)

-- 각 카테고리에서 [카테고리별 평균] 보다 높은 주문들
SELECT *
FROM sales
WHERE category IN
(SELECT DISTINCT category AS 카테고리
FROM sales
WHERE total_amount > (SELECT AVG(total_amount) FROM sales));

-- 여러 데이터 서브쿼리
-- 1. 기업 고객들의 모든 주문 내역
SElECT customer_id FROM customers;
SELECT 
* 
FROM sales
WHERE customer_id in(SElECT customer_id FROM customers);
-- 2. 재고 부족 제품의 매출 내역
SELECT * 
FROM
sales
WHERE product_name IN (SELECT product_name FROM products
WHERE stock_quantity<50);

-- 2-3. 상위 3개 매출 지역의 주문들
SELECT * 
FROM sales 
WHERE region IN (
    SELECT region FROM (
        SELECT region 
        FROM sales 
        ORDER BY total_amount DESC 
        LIMIT 3
    ) AS top_regions
);
-- 4. 상반기(24-01-01 ~ 24-06-30) 에 주문한 고객들의 하반기(0701~1231) 주문 내역
SELECT *
FROM sales
WHERE customer_id IN(SELECT 
DISTINCT customer_id
FROM sales
WHERE order_date IN
(SELECT order_date
FROM sales
WHERE order_date BETWEEN '2024-01-01' AND '2024-06-30'))
AND order_date BETWEEN '2024-07-01' AND '2024-12-31'
ORDER BY order_date ASC;