USE practice;
DESC userinfo;
INSERT INTO userinfo(nickname, phone) VALUES
('alice', '0104567890'),
('bob', '0104561234'),
('charlie', '01112345678'),
('david', '01874562131'),
('eric', '01054687913');

SELECT * FROM userinfo;
SELECT * FROM userinfo WHERE id=3;
SELECT * FROM userinfo WHERE nickname='bob';
UPDATE userinfo SET phone='01099998888' WHERE nickname='bob';
DELETE FROM userinfo WHERE id=5;
USE lecture;
ALTER TABLE members ADD COLUMN age INT NOT NULL DEFAULT 20;
ALTER TABLE members ADD COLUMN address VARCHAR(100) DEFAULT '미입력';
DESC  members;

ALTER TABLE members CHANGE COLUMN address juso VARCHAR(100);
ALTER TABLE members MODIFY COLUMN juso VARCHAR(50);