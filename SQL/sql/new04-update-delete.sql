SELECT *FROM members;
INSERT INTO members (name) values ('익명');
-- Update(데이터 수정)
UPDATE 	members SET name='홍길동', email='hong@a.com' WHERE id=1;

DELETE FROM members WHERE id=2;

SELECT * FROM members;