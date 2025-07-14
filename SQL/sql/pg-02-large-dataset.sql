-- pg-02-large-dataset.sql
-- 숫자 생성
SELECT generate_series(1,10);

-- 날짜 생성
SELECT generate_series(
	'2024-01-01'::date,
	'2024-12-31'::date,
	'1 day'::interval
);

-- 시간
SELECT generate_series(
	'2024-01-01 00:00:00'::timestamp,
	'2024-01-01 23:59:59'::timestamp,
	'1hour'::interval
);
--