-- 03-insert.sql

USE lecture;
DESC members;

-- 데이터 입력 (Create)
INSERT INTO members (name, email) VALUES ('이민규','mk.lee.0807@gmail.com');
INSERT INTO members (name, email) VALUES ('김재석','kim1@a.com');
-- 여러줄, (col1,col2) 순서 잘 맞추기!
INSERT INTO members(email,name) VALUES 
('lee@a.com','이재필'),
('park@a.com','박지수');

-- 데이터 전체 확인, 조회(Read)
SELECT * FROM members;
-- 단일 데이터 조회 (* -> 모든 컬럼)
SELECT * FROM members WHERE id=1;



