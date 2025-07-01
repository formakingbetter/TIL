-- 10-str-func.sql
USE practice;

-- 길이
SELECT LENGTH('hello sql');
SELECT name, LENGTH(nickname) FROM dt_demo;
SELECT name, CHAR_LENGTH(name) AS 이름길이 FROM dt_demo;

-- 연결
SELECT CONCAT('hello','sql','!!');
SELECT CONCAT(name,'(',score,')') AS info from dt_demo;

-- 대소문자 변환
SELECT name, UPPER(nickname) AS UN,
LOWER(nickname) AS LN
FROM dt_demo;

-- 부분 문자열 추출 (문자열, 시작점, 길이)
SELECT SUBSTRING('HELLO SQL!',2,4);
SELECT LEFT('hello sql!',5);
SELECT 
	description,
    concat(SUBSTRING(description, 1,5),'...') AS intro, 
    CONCAT(	
		LEFT(description,5),'...', RIGHT(description,3)) AS summary
        From dt_demo;
-- 문자열 치환
SELECT REPLACE('A@test.com','test.com','testb.com') as 'email replacing';
SELECT description,
	REPLACE(description, '학생','**') AS secret from dt_demo;
    
select locate ('@','username@gmail.com');
SELECT
	description,
    substring(description,1, locate('학생',description)-1) AS '학생 설명'
    FROM dt_demo;