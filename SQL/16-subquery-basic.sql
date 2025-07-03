-- 16-subquery-basic.sql
USE lecture;

SELECT
	product_name AS 이름, 
	total_amount AS 판매액,
	FORMAT(ROUND(total_amount - (SELECT AVG(total_amount) FROM sales)),0) AS 평균차이

FROM sales
WHERE total_amount>(SELECT AVG(total_amount) FROM sales);
-- 데이터가 여러개 나오는 경우
SELECT 
*
FROM sales;
-- 데디터가 하나만 나오는 경우
SELECT AVG(quantity) FROM sales;

-- sales 에서 가장 비싼 걸 시킨 주문
SELECT
*
FROM sales
WHERE total_amount=(SELECT MAX(total_amount) FROM sales); 
-- 가장 최근 주문일의 주문데이터
SELECT * FROM sales ORDER BY order_date DESC LIMIT 1;
SELECT 
*
FROM sales
WHERE order_date= (SELECT MAX(order_date) FROM sales);
-- 가장 [주문액수 평균]과 유사한(실제 주문액수의 차이가 적은) 주문데이터 5개 

SELECT AVG(total_amount) FROM sales;

SELECT
	product_id, 
    product_name,
    order_date,
    total_amount,
-- 평균과 주문사이의 차이
	ABS(
    (SELECT AVG(total_amount) FROM sales)
    - 
    total_amount
    ) AS 평균과의차이
FROM sales
ORDER BY 평균과의차이
LIMIT 5;


SELECT 
sales_rep AS 직원명,
DATE_FORMAT(order_date,'%y-%m') AS 월,
FORMAT(MAX(total_amount),0) AS 최대판매액
FROM sales
GROUP by 직원명, 월;