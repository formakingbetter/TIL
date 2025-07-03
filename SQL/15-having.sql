-- 15-having.sql
USE lecture;

SELECT
	category,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출액
FROM sales
WHERE total_amount >= 100000 -- 원본 데이터에 필터를 걸고, -- GROUPING
GROUP BY category;

SELECT
	category,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출액
FROM sales
-- WHERE total_amount >= 100000 -- 원본 데이터에 필터를 걸고, -- GROUPING
GROUP BY category
HAVING 총매출액 >=POWER(10,6); -- 피벗테이블에 필터 추가

-- 활성 고객 지역 찾기(주문 건수 >=10, 고객수 >=5)
SELECT 
	region AS 지역,
    COUNT(*) AS 주문건수,
    COUNT(DISTINCT customer_id) AS 고객수,
    SUM(total_amount) AS 총매출액,
    ROUND(AVG(total_amount),0) AS 평균주문액
FROM sales
GROUP BY region
HAVING 주문건수>=20 AND 고객수>=15;

SELECT * FROM sales;
SELECT 
	sales_rep AS 영업사원,
    COUNT(*) AS '사원별 판매수',
    COUNT(DISTINCT customer_id) AS '사원별 고객수',
    SUM(total_amount) AS '사원별총매출액',
	TIMESTAMPDIFF(MONTH,order_date,curdate()) AS 활동개월수
    
FROM sales
GROUP BY 영업사원;
-- 
SELECT
    sales_rep AS 영업사원,
    COUNT(*) AS 사원별판매건수,
    COUNT(DISTINCT customer_id) AS 사원별고객수,
    SUM(total_amount) AS 사원별총매출,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) + 1 AS 활동개월수,
    ROUND(SUM(total_amount) / (TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) + 1), 0) AS 월평균매출
FROM sales
GROUP BY sales_rep
HAVING 월평균매출 >= 500000
ORDER BY 월평균매출 DESC;





