USE practice;
DESC members;
-- 0. 칼럼 추가하기
ALTER TABLE members ADD COLUMN address INT NOT NULL;
-- 1. 칼럼 바꾸기
ALTER TABLE members CHANGE COLUMN address juso VARCHAR(30);
-- 2. 칼럼 수정
ALTER TABLE members MODIFY COLUMN juso VARCHAR(50);
-- 3. 칼럼 삭제
ALTER TABLE members DROP COLUMN age; 
-- add, change, modify, drop

-- 1.컬럼 이름 + 데이터 타입 수정
ALTER TABLE members CHANGE COLUMN address juso VARCHAR(100);
-- 2.컬럼 데이터 타입 수정
ALTER TABLE members MODIFY COLUMN juso VARCHAR(70);
-- 3.칼럼 삭제
ALTER TABLE members DROP COLUMN age;
desc members;

