-- p02.sql

-- practice db이동
USE practice;
DESC userinfo;

INSERT INTO userinfo (nickname, phone) values ('bob','01053525423');
INSERT INTO userinfo (nickname, phone) values ('bib','01043525423');
INSERT INTO userinfo (nickname, phone) values ('gib','01053557423');
INSERT INTO userinfo (nickname, phone) values ('kil','01055325423');
INSERT INTO userinfo (nickname, phone) values ('gil','01052525423');
SELECT * FROM userinfo;
SELECT * FROM userinfo WHERE nickname='bob';
UPDATE userinfo SET phone='01099998888' WHERE nickname='bob';
DELETE FROM userinfo WHERE nickname='bob';