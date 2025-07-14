--pg-08-windows.sql
-- window 함수->OVER() 구문
SELECT AVG(amount) FROM orders;

SELECT
	AVG(amount)
FROM orders
GROUP BY customer_id;

SELECT 
	order_id,
	customer_id,
	amount,
	AVG(amount) OVER() AS 전체평균
FROM orders
LIMIT 10;

-- ROW_NUMBER() ->줄세우기 [ROW_NUMBER() OVER(ORDER BY 정렬기준)]
-- 주문 금액이 높은 순서로
SELECT 
	order_id,
	customer_id,
	amount,
	ROW_NUMBER() OVER (ORDER BY amount DESC) as 호구번호
FROM orders
ORDER BY amount
LIMIT 20 OFFSET 40;

-- 주문 날짜가 최신인 순서대로 번호 매기기
SELECT 
	order_id,
	customer_id,
	amount,
	order_date,
	ROW_NUMBER() OVER(ORDER BY order_date DESC) as 최신주문순서,
	RANK() OVER (ORDER BY order_date DESC) as 랭크,
	DENSE_RANK() OVER(ORDER BY order_date DESC) AS 덴스랭크
FROM orders
ORDER BY 최신주문순서
LIMIT 20;
-- 각 지역에서 매출 1위 고객 => ROW_NUMBER() 로 숫자를 매기고, 이 컬럼의 값이 1인 사람
-- [지역, 고객이름, 총구매액]
-- CTE
--1. 지역-사람별 "매출 데이터" 생성 [지역, 고객 id, 이름, 해당 고객의 총 매출]
--2. "매출데이터"에 새로운 열(ROW_NUMBER) 추가
WITH july_sales AS(
	SELECT 
		customer_id,
		SUM(amount) AS 월구매액,
		ROW_NUMBER()
	FROM orders
	WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31'
	GROUP BY customer_id
),
ranking AS(
	SELECT
		customer_id,
		월구매액,
		ROW_NUMBER() OVER(ORDER BY 월구매액) AS 순위
	FROM july_sales
)
SELECT * FROM july_sales;