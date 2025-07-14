-- 모든 고객 목록 조회

-- 고객의 customer_id, first_name, last_name, country를 조회하고, customer_id 오름차순으로 정렬하세요.
-- 모든 앨범과 해당 아티스트 이름 출력
SELECT 
	customer_id, 
	first_name,
	last_name,
	country
from customers
ORDER BY customer_id;

-- 각 앨범의 title과 해당 아티스트의 name을 출력하고, 앨범 제목 기준 오름차순 정렬하세요.
-- 트랙(곡)별 단가와 재생 시간 조회
SELECT
	al.title,
	ar.name,
	tr.unit_price,
	tr.milliseconds
FROM albums al
JOIN artists ar ON ar.artist_id=al.artist_id
JOIN tracks tr ON tr.album_id=al.album_id;
ORDER BY title ASC;
-- tracks 테이블에서 각 곡의 name, unit_price, milliseconds를 조회하세요.
-- 5분(300,000 milliseconds) 이상인 곡만 출력하세요.

WITH tracks_name AS (SELECT 
	name,
	unit_price,
	milliseconds
FROM tracks)
SELECT *
FROM tracks_name
WHERE milliseconds >=300000;
-- 국가별 고객 수 집계
-- 각 국가(country)별로 고객 수를 집계하고, 고객 수가 많은 순서대로 정렬하세요.
SELECT 
	country,
	count(customer_id) AS 고객수
FROM customers
GROUP BY country
ORDER BY 고객수 DESC;
-- 각 장르별 트랙 수 집계
-- 각 장르(genres.name)별로 트랙 수를 집계하고, 트랙 수 내림차순으로 정렬하세요.
SELECT
	name,
	count(name) AS 트랙수
FROM genres 
GROUP BY name
ORDER BY 트랙수 DESC;
select * from genres;

