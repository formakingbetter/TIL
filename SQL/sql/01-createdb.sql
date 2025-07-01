-- 01-createdb.sql

-- db 생성
CREATE DATABASE	sample_db; -- 정해진거는 대문자 자기가 정하는 거는 소문자로 작성
-- db 확인
SHOW databases ;
-- db 삭제
DROP DATABASE sample_db;

-- lecture, practice 생성 후 확인
CREATE DATABASE lecture;
CREATE DATABASE practice;
SHOW DATABASES;
-- DB 사용
USE lecture;
