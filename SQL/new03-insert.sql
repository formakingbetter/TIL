DROP TABLE members;
CREATE TABLE members(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT(current_date())
);
DESC members;
USE practice;
INSERT INTO members(name, email) VALUES
('이민규','lee@a.com'),
('김주택','kim@b.com');
SELECT * FROM members WHERE id=1;
