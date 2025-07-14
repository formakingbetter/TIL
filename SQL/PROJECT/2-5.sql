-- 각 고객별로 가장 최근 인보이스 정보 출력
SELECT
	i.customer_id,
	i.invoice_id,
    i.invoice_date,
    i.total
FROM invoices i
INNER JOIN (
    SELECT customer_id, MAX(invoice_date) AS max_date
    FROM invoices
    GROUP BY customer_id
) recent ON i.customer_id = recent.customer_id AND i.invoice_date = recent.max_date
ORDER BY i.invoice_date DESC;
