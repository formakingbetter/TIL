SELECT *
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
WHERE id is NULL;

SELECT 
	c.customer_id,
    c.customer_name,
    c.customer_type,
    c.join_date,
    count(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount),0) AS 총구매액,
    COALESCE(AVG(s.total_amount),0) AS 평균주문액,
    COALESCE(MAX(s.order_date),'주문없음')
FROM customers c
lEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP BY
	c.customer_id,
    c.customer_name,
    c.customer_type,
    c.join_date ;
SELECT 
  category,
  AVG(total_amount) AS 평균매출액
FROM sales GROUP BY category
HAVING 평균매출액 > 500000;

FROM
(SELECT category,
	AVG(total_amount) AS 평균매출액
FROM sales group by category) AS category_summary
WHERE 평균매충
;