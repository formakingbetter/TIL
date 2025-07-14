SELECT 
	tablename,
	indexname,
	idexdef
FROM pg_indexes
WHERE tablename IN('large_orders','large_customers');

ANALYZE large_orders;
ANALYZE large_customers;
-- 실제 운영에서는 x(캐시 날리기)
SELECT pg_stat_reset();

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE customer_id='CUST-25000.'; -- 145.545ms

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE amount BETWEEN 800000 AND 1000000; -- 46296/192.534ms

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE  --14310/132.375ms
	region='서울' AND amount > 500000 AND order_date >='2024-07-08';
EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE region = '서울'
ORDER BY amount DESC -- 39823 / 157.941ms
LIMIT 100;

CREATE INDEX idx_orders_customer_id ON large_orders(customer_id);
CREATE INDEX idx_orders_amount ON large_orders(amount);
CREATE INDEX idx_orders_region ON large_orders(region);

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE amount BETWEEN 800000 AND 1000000;

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE region='서울'; -- 100ms

CREATE INDEX idx_orders_region_amount ON large_orders(region,amount);

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE region='서울' AND amount>800000; -- 262.239ms

CREATE INDEX idx_orders_id_order_date ON large_orders(customer_id, order_date);

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE customer_id='CUST-25000.'
	AND order_date>='2024-07-01'
ORDER BY order_date DESC;

-- 복합 인덱스 순서의 중요도

CREATE INDEX idx_orders_region_amount ON large_orders(region,amount);
CREATE INDEX idx_orders_amount_region ON large_orders(amount, region);

-- Index 순서 가이드라인

-- 고유값 비율
SELECT 
	COUNT(DISTINCT region) AS 고유지역수,
	COUNT(*) AS 전체행수,
	ROUND(COUNT(DISTINCT region) * 100.0 / COUNT(*), 2) AS 선택도
FROM large_orders;


SELECT 
	COUNT(DISTINCT amount) AS 고유금액수,
	COUNT(*) AS 전체행수
FROM large_orders;

SELECT
	COUNT(DISTINCT customer_id) AS 고유고객수,
	COUNT(*) AS 전체행수
FROM large_orders;