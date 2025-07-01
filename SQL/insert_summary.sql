CREATE TABLE sample (
		name VARCHAR(30),
        age INT
);

-- 테이블 삭제
DROP TABLE sample;
-- 테이블 확인
SHOW TABLES;

CREATE TABLE members(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT(CURRENT_DATE)
);

SHOW TABLES;
-- members 테이블을 상세히 확인
DESC members;
DROP DATABASE lecture;
DROP DATABASE practice;
CREATE DATABASE lecture;
USE lecture;
DESCRIBE members;
INSERT INTO members(name) VALUES ('유태영');
INSERT INTO members(name,email) VALUES
('이민규','mk@amail.com'),
('김재석','kim@a.com');
