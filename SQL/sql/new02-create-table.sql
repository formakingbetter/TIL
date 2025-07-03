CREATE DATABASE practice;
USE practice;
CREATE TABLE members(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT(current_date())
);
DESC members;