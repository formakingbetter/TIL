DROP VIEW customer_summary;
CREATE VIEW customer_summary AS
SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount),0) AS 총구매액,
    COALESCE(AVG(s.total_amount),0) AS 평균주문액,
    COALESCE(MAX(s.order_date),'주문없음') AS 최근주문일
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name, c.customer_type;

SELECT * FROM customer_summary;
CREATE VIEW category_performance AS
SELECT
    s.category,
    COUNT(*) AS 총주문건수,
    SUM(s.total_amount) AS 총매출액,
    AVG(s.total_amount) AS 평균주문금액,
    COUNT(DISTINCT s.customer_id) AS 구매고객수,
    COUNT(DISTINCT s.product_name) AS 판매상품수,
    ROUND(SUM(s.total_amount) * 100.0 / (SELECT SUM(total_amount) FROM sales), 2) AS 매출비중
FROM sales s
GROUP BY s.category;
SELECT * FROM category_performance;
Copy-- 카테고리별 + 고객유형별 통합 분석
SELECT
    '카테고리별' AS 분석유형,
    category AS 구분,
    COUNT(*) AS 건수,
    SUM(total_amount) AS 총액
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY category

UNION ALL

SELECT
    '고객유형별' AS 분석유형,
    customer_type AS 구분,
    COUNT(*) AS 건수,
    SUM(total_amount) AS 총액
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY customer_type

ORDER BY 분석유형, 총액 DESC;