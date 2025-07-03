-- 14-group-by.sql
USE lecture;
SELECT 
	category AS 카테고리,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출,
    AVG(total_amount) AS 평균매출
FROM sales
GROUP BY category
ORDER BY 총매출 DESC;

-- 지역별 평균매출
SELECT 
	region AS 지역,
    COUNT(*) AS 주문건수,
    FORMAT(AVG(total_amount),0) AS 평균매출
FROM sales
GROUP BY region;

-- 다중 Grouping
SELECT 
	region AS 지역,
    category AS 카테고리,
    COUNT(*) AS 주문건수,
    FORMAT(SUM(total_amount),0) AS 총매출액,
    ROUND(AVG(total_amount)) AS 평균매출액
FROM sales
GROUP BY region, category
ORDER BY 지역, 총매출액 DESC;

-- 영업사원(sales_rep)별 성과ALTER

SELECT 
	DATE_FORMAT(order_date,'%Y-%m') AS 월,
	sales_rep,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 월매출액,
    ROUND(AVG(total_amount)) AS 월평균매출액
FROM sales	
GROUP BY sales_rep, DATE_FORMAT(order_date,'%Y-%m')
ORDER BY 월, 월매출액 DESC;
--
SELECT
	DATE_FORMAT(order_date,'%Y-%m') as 월,
    COUNT(*) AS 주문건수
FROM sales
GROUP BY 월;
-- 지역별 주문 건수
SELECT region, COUNT(*) AS 주문건수
FROM sales
GROUP BY region;

SELECT region, count(*) as 주문건수
FROM sales
GROUP BY region;

-- 월별 매출 트렌드
SELECT
	date_format(order_date,'%Y-%m') as 월,
    count(*) AS 주문건수,
    SUM(total_amount) AS 월매출액,
    COUNT(DISTINCT customer_id) AS 월활성고객수
FROM sales
GROUP BY 월;
--
SELECT 
	DAYNAME(order_date) AS 요일,
    DAYOFWEEK(order_date) AS 요일번호,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출액,
    ROUND(AVG(total_amount)) AS 평균주문액
FROM sales
GROUP BY 요일,요일번호
ORDER BY 총매출액 DESC;