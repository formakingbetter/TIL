-- 24-many-to-many.sql
USE lecture;

DROP TABLE IF EXISTS students_courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

CREATE TABLE students (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(20)
);

CREATE TABLE courses (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50),
  classroom VARCHAR(20)  
);

-- 중간테이블 (Junction Table)  students:courses = M : N
CREATE TABLE students_courses (
  student_id INT,
  course_id INT,

  grade VARCHAR(5),
  PRIMARY KEY (student_id, course_id),  -- 복합 PK
  FOREIGN KEY(student_id) REFERENCES students(id),
  FOREIGN KEY(course_id) REFERENCES courses(id)
);

-- 데이터 삽입
INSERT INTO students VALUES
(1, '김학생'),
(2, '이학생' ),
(3, '박학생');

INSERT INTO courses VALUES
(1, 'MySQL 데이터베이스', 'A관 101호'),
(2, 'PostgreSQL 고급', 'B관 203호'),
(3, '데이터 분석', 'A관 704호');

INSERT INTO students_courses VALUES
(1, 1, 'A'),  -- 김학생이 MySQL 수강
(1, 2,'B+'), -- 김학생이 PostgreSQL 수강
(2, 1, 'A-'), -- 이학생이 MySQL 수강
(2, 3, 'B'),  -- 이학생이 데이터분석 수강
(3, 2, 'A+'), -- 박학생이 PostgreSQL 수강
(3, 3, 'A');  -- 박학생이 데이터분석 수강

-- 학생별 수강 과목
SELECT *FROM students;
SELECT * FROM courses;
Select * FROM students_courses;

SELECT s.name, GROUP_CONCAT(c.name) FROM 
students s INNER JOIN students_courses sc
ON s.id=sc.student_id
INNER JOIN courses c ON sc.course_id=c.id
GROUP BY s.id,s.name;
-- 과목별 수강 학생
--
SELECT 
	course_id, c.name, c.classroom,
    COUNT(s.id) AS 수강인원,
    GROUP_CONCAT(s.name) AS 수강학생들,
    ROUND(AVG(CASE
    WHEN sc.grade='A+' THEN 4.3
    WHEN sc.grade='A' THEN 4.0
    WHEN sc.grade='A-' THEN 3.7
    WHEN sc.grade='B+' THEN 3.3
    WHEN sc.grade='B' THEN 3.0
    END),2) AS 평균학점
FROM students s
INNER JOIN students_courses sc ON s.id=sc.student_id
INNER JOIN courses c ON sc.course_id=c.id
GROUP BY course_id,classroom;


SELECT 