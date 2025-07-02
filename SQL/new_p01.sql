CREATE DATABASE practice;
USE practice;
CREATE TABLE userinfo(
	id INT AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(20) NOT NULL,
	phone VARCHAR(11) UNIQUE,
    reg_date DATE DEFAULT(current_date())
);

