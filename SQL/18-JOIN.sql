-- 18-JOIN.sql
-- 고객정보+주문정보
USE lecture;
SELECT 
	*,
    (
    SELECT customer_name FROM customers  c
    WHERE c.customer_id=s.customer_id) AS 주문고객이름
FROM sales s;

-- JOIN
select * from sales;
SELECT 
	c.customer_name,
    c.customer_type
FROM customers c
INNER JOIN sales s ON c.customer_id=s.customer_id
WHERE s.total_amount >=500000
ORDER BY s.total_amount DESC;


-- 모든 고객의 구매 현황 분석(구매를 하지 않았어도 분석)
SELECT 
	*
FROM customers c
-- LEFT JOIN-> 왼쪽 테이블(c) 의 모든 데이터와 매칭되는 오른쪽 데이터 | 매칭되는 오른쪽 데이터(없어도 등장)
LEFT JOIN sales s on c.customer_id=s.customer_id;
SELECT
*
FROM customers c;
-- LEFT JOIN -> 왼쪽 테이블의 모든 데이터와 +매칭되는 오른쪽 데이터| 매칭되는 오른쪽 데이터 (없어도 등장)
SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(*) AS 주문회수,
    SUM(s.total_amount) AS 총구매액
    -- 주문 횟수
FROM customers c 
LEFT JOIN sales s ON c.customer_id= s.customer_id
-- WHERE s.id IS NULL; -> 한번도 주문 안한 사람 나온다. 
GROUP BY c.customer_id, c.customer_name, c.customer_type;
SELECT 
	c.customer_id,
    COUNT(*) AS 주문수량,
    SUM(total_amount) AS 총구매량
FROM sales
GROUP BY customer_id;

SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id)  AS 구매건수,
    -- coalesce(첫번째 값, 10)-> 첫번쨰 값이 Null인 경우, 10을 쓴다. 
    COALESCE(SUM(s.total_amount),0) AS 총구매액, 
    COALESCE(ROUND(AVG(s.total_amount)),0) AS 평균구매액,
    CASE
		WHEN COUNT(s.id)>=5 THEN '충성고객'
        WHEN COUNT(s.id)>=3 THEN '일반고객'
        WHEN COUNT(s.id)=0 THEN '잠재고객'
        ELSE '신규고객'
	END AS 활성도
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP BY c.customer_id;

SELECT c.customer_id,
       count(s.id) AS 구매건수
FROM sales s
LEFT JOIN customers c ON c.customer_id=s.customer_id
GROUP BY c.customer_id;