-- p09.sql
USE practice;
DROP TABLE sales;
DROP TABLE products;
DROP TABLE customers;
CREATE TABLE sales AS SELECT * FROM lecture.sales;
CREATE TABLE products AS SELECT * FROM lecture.products;
CREATE TABLE customers AS SELECT * FROM lecture.customers;
SELECT
	'1. sales' AS 구분,
	COUNT(*) AS 행수 
FROM sales
UNION
SELECT 
	'2. customers' AS 구분,
    COUNT(*) AS 행수
FROM customers;

-- 주문 거래액이 가장 높은 고객명, 상품명, 주문금액을 가져와 주세요
SELECT 
	customer_name AS 고객명,
	product_name AS 상품명,
    total_amount AS 주문금액
FROM sales s
INNER JOIN customers c ON c.customer_id=s.customer_id
ORDER BY total_amount DESC
LIMIT 10;
-- 고객 유형별 [고객유형, 주문건수, 평균주문금액]을 평균주문금액 높은순으로 정렬해서 보여주기
SELECT 
	customer_type AS '고객유형',
    count(DISTINCT s.id) AS '주문건수',
    FORMAT(AVG(total_amount),0) AS '평균주문금액'
    
FROM sales s 
INNER JOIN customers c ON c.customer_id=s.customer_id
GROUP BY customer_type
ORDER BY 평균주문금액 DESC;
-- 문제 1: 모든 고객의 이름과 구매한 ㅅ아품명 조회
SELECT
	DISTINCT customer_name AS 고객의이름,
    product_name AS 상품명
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id;
-- 문제2. 고객 정보와 주문 정보를 모두 포함한 상세 조회
SELECT
	c.customer_id,
	c.customer_name AS 고객명,
    coalesce(s.product_name,'🙀🙀') AS 상품명
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
ORDER BY c.customer_name;

SELECT
	c.customer_name AS 고객명,
    c.customer_type AS 고객유형,
    c.join_date AS 가입일,
    c.;
-- 문제3. VIP 고객들의 구매 내역만 조회
SELECT
	*
FROM customers c
INNER JOIN sales s ON c.customer_id=s.customer_id
WHERE customer_type='VIP';
-- 문제 4. 50만원 이상 주문한 기업 고객들 
SELECT
	customer_name,
    customer_type,
    total_amount
FROM customers c
INNER JOIN sales s ON c.customer_id=s.customer_id
WHERE customer_type='기업' AND total_amount >500000;
-- 문제 5: 2024년 하반기 전자제품 구매 내역A
SELECT
	*
FROM customers c
INNER JOIN sales s ON c.customer_id=s.customer_id
WHERE order_date BETWEEN '2024-07-01'AND '2024-12-31' AND category='전자제품';
-- 문제 6: 고객별 주문 통계(INNER JOIN)
SELECT 
	customer_name AS 고객명,
    customer_type AS 유형,
    count(*) AS 주문횟수,
    SUM(total_amount) AS 총구매,
    AVG(total_amount) AS 평균구매,
    MAX(join_date) AS 최근구매일
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP BY  고객명,유형;
-- 문제 7: 모든 고객의 주문 통계(LEFT JOIN) -주문 없는 고객도 포함
SELECT
 customer_name AS 고객명,
 COUNT(*) AS 주문건수 
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP BY customer_name;
-- 문제 8: 카테고리별 고객 유형 분석
SELECT
	category AS 카테고리,
    customer_type AS 유형,
    count(c.id) AS 주문건수
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP BY category,customer_type; 
-- 문제9: 고객별 등급 분석
SELECT 
	c.customer_id, c.customer_name,c.customer_type,
    count(s.id) AS 구매횟수,
    coalesce(SUM(s.total_amount),0) AS 총구매액,
    CASE
		WHEN COUNT(s.id)=0 THEN '잠재고객'
        WHEN COUNT(s.id)>=10 THEN '플래티넘'
        WHEN COUNT(s.id)>=5 THEN '골드'
        WHEN COUNT(s.id) >=3 THEN '실버'
        ELSE '브론즈'
    END AS 활동등급,
    CASE
		WHEN COALESCE(SUM(s.total_amount),0) >=500000 THEN 'VIP+'
        WHEN COALESCE(SUM(s.total_amount),0) >=200000 THEN 'VIP'
        WHEN COALESCE(SUM(s.total_amount),0) >=100000 THEN '우수'
        WHEN COALESCE(SUM(s.total_amount),0) > 0 THEN '일반'
        ELSE '신규'
    
    END AS 구매등급
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY customer_id,customer_name,customer_type;

SELECT
	customer_name,
    customer_type,
    total_amount
FROM customers c
INNER JOIN sales s ON c.customer_id=s.customer_id
WHERE customer_type='기업' AND total_amount >500000;
-- 문제 10: 활성 고객 분석
-- 고객상태(최종구매일) [NULL(구매없음) | 활성고객 <= 30 < 관심고객 <= 90 관심고객 < 휴면고객]별로
-- 고객수, 총주문건수, 총매출액, 평균주문금액 분석SELECT * FROM 

SELECT 
	c.customer_id,
    c.customer_name AS 이름,
    COUNT(s.id) AS 총주문건수,
    coalesce((total_amount),0) AS 총매출액,
    COALESCE(ROUND(AVG(total_amount)),0) AS 평균주문금액
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP BY c.customer_id, c.customer_name
;
SELECT
	고객상태,
    COUNT(*) AS 고객수,
    SUM(총주문건수) AS 상태별총주문건수,
	SUM(총매출액) AS 상태별총매출액,
    ROUND(AVG(평균주문금액)) AS 상태별평균주문금액
FROM(
SELECT
    c.customer_id AS 고객상태,
    c.customer_name AS 이름,
    COUNT(s.id) AS 총주문건수,
    COALESCE(SUM(s.total_amount), 0) AS 총매출액,
    COALESCE(ROUND(AVG(s.total_amount)), 0) AS 평균주문금액
FROM
    customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id) AS ANALYSIS
GROUP BY
    c.customer_id, c.customer_name;



