WITH monthly_sales AS(
	SELECT
	 	DATE_TRUNC('month',i.invoice_date) AS 월,
	 	SUM(ii.unit_price) AS 매출
	FROM invoices i
	JOIN invoice_items ii ON i.invoice_id=ii.invoice_id
	GROUP BY 월
),
sales_difference AS(
	SELECT
		TO_CHAR(월,'YYYY-MM') AS 년월,
		매출,
		LAG(매출,1) OVER(ORDER BY 월) AS 전월매출
	FROM monthly_sales
)
SELECT
	*,
	CASE 
		WHEN 전월매출 IS NULL THEN NULL
		ELSE ROUND((매출-전월매출)*100/전월매출,2)::TEXT ||'%' 
	END AS 증감률
FROM sales_difference
ORDER BY 년월;
	