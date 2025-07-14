-- 고객별 누적 구매액 및 등급 산출
-- 각 고객의 누적 구매액을 구하고,
-- 상위 20%는 'VIP', 하위 20%는 'Low', 나머지는 'Normal' 등급을 부여하세요.
WITH customer_sum AS(
	SELECT
		c.customer_id,
		first_name,
		last_name,
		sum(i.total) AS 구매액
	FROM customers c INNER JOIN
	invoices i ON c.customer_id=i.customer_id
	GROUP BY c.customer_id
)
SELECT
	*,
	CASE
		WHEN PERCENT_RANK() OVER(ORDER BY 구매액)>=0.8 THEN 'VIP'
		WHEN PERCENT_RANK() OVER(ORDER BY 구매액)>=0.2 THEN 'LOW'
		ELSE 'NORMAL'
	END AS 등급
FROM customer_sum
ORDER BY 등급 DESC;
