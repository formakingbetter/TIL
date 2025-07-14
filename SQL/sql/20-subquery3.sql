-- 20-subquery3.sql

USE lecture;
-- 각 고객의 주문정보 [cid,cname,ctype, 총주문횟수, 총주문금액, 최근 주문일]
SELECT 
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(*) AS 총주문횟수,
    AVG(total_amount) AS 총주문금액,
	MAX(order_date) AS '최근 주문일'
FROM customers c
INNER JOIN sales s ON s.customer_id=c.customer_id
GROUP BY c.customer_id,c.customer_name,c.customer_type;

-- 각 카테고리 평균매출중에서 50만원 이상
SELECT 
    category AS 카테고리,
    ROUND(AVG(total_amount), 0) AS 평균매출
FROM sales
GROUP BY category
HAVING AVG(total_amount) >= 500000;
-- 인라인 뷰(View) => 내가 만든 테이블
SELECT *
FROM (
	SELECT
		category,
        AVG(total_amount) AS 평균매출액
        FROM sales GROUP BY category
) AS category_summary
WHERE 평균매출액 >=500000;
-- category_summary
-- 1. 카테고리별 매출 분석 후 필터링
-- 카테고리명, 주문건수, 총매출, 평균매출 [0 <= 평균매출 < 400000 <=중단가 <800000 < 고단가]

SELECT 
	category,
    주문건수,
    총매출,
    평균매출,
	CASE
		WHEN 평균매출>=800000 THEN '고단가'
        WHEN 평균매출>=400000 THEN '중단가'
		ELSE '저단가'
	END AS 단가구분
FROM (SELECT
	category,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출,
    ROUND(AVG(total_amount), 0) AS 평균매출
FROM sales
GROUP BY category) AS c_a;


SELECT
	CASE 
		WHEN AVG(total_amount)>800000 THEN '고단가'
        WHEN AVG(total_amount) >=400000 THEN '중단가'
        ELSE '저단가'
    END AS 평균매출표
FROM
(SELECT category,
	AVG(total_amount) AS '평균매출'
FROM sales
GROUP BY category);
SELECT  
  CASE     
    WHEN AVG(평균매출) > 800000 THEN '고단가'
    WHEN AVG(평균매출) >= 400000 THEN '중단가'
    ELSE '저단가'
  END AS 평균매출표  
FROM  
  (
    SELECT 
      category,   
      AVG(total_amount) AS 평균매출
    FROM sales  
    GROUP BY category
  ) AS category_avg;  -- ★ 별칭 추가됨

-- 영업사원별 성과 등급 분류
-- 총매출[0 <C <= 100000 < B < 3000000 <= A < 5000000 <= S]
-- 주문건수
SELECT
	영업사원,
    총매출액,
    주문건수,
    평균주문액,
    CASE 
		when 총매출액>=5000000 THEN 'S'
        WHEN 총매출액>=3000000 THEN 'A'
        WHEN 총매출액>=1000000 THEN 'B'
        ELSE 'C'
	END AS 총매출,
    CASE
		WHEN 주문건수>=30 THEN 'A'
        WHEN 주문건수 >=15 THEN 'B'
        WHEN 주문건수 >=0 THEN 'C'
    END AS 주문건수
	

FROM 
(SELECT
	coalesce(sales_rep,'확인불가') AS 영업사원,
    SUM(total_amount) AS 총매출액,
    COUNT(*) AS 주문건수,
    ROUND(avg(total_amount),0) AS 평균주문액
FROM sales
GROUP BY 영업사원) AS s_c 
ORDER BY 총매출액 DESC;