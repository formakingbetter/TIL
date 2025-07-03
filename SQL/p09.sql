USE lecture;
SELECT *
FROM customers c
INNER JOIN sales s on c.customer_id=s.customer_id; 
-- 모든 고객의 구매 현황 분석
-- LEFT JOIN
SELECT 
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 구매건수,
    coalesce(SUM(s.total_amount),0) AS 총구매액,
    coalesce(SUM(s.total_amount),0) AS 평균구매액,
CASE
	WHEN count(s.id)>=5 THEN '충성고객'
    WHEN count(s.id)>=3 THEN '일반고객'
    WHEN count(s.id)=0 THEN '잠재고객'
    ELSE '신규고객'
END AS '충성도'
FROM customers c
INNER JOIN sales s ON c.customer_id=s.customer_id
GROUP BY c.customer_id
