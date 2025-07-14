WITH RECURSIVE org_chart AS (
	SELECT
		employee_id,
		employee_name,
		manager_id,
		department,
		1 AS 레벨,
		employee_name::text AS 조직구조
	FROM employees
	WHERE manager_id is NULL
	UNION ALL
	SELECT
		e.employee_id,
		e.employee_name,
		e.manager_id,
		e.department,
		oc.레벨 + 1,
		(oc.조직구조 || '>>' || e.employee_name)::text -- ||은 concate과 같은 역할을 한다.
	FROM employees e
	INNER JOIN org_chart oc ON e.manager_id=oc.employee_id
)
SELECT 
  	*
FROM org_chart
ORDER BY 레벨;
SELECT * FROM calender;
WITH RECURSIVE calender AS(
	SELECT '2024-01-01'::DATE as 날짜
	UNION ALL
	SELECT (날짜 + INTERVAL '1 day') as DATE
	FROM calender
	WHERE 날짜 <'2024-01-31' ::DATE
)
SELECT * FROM calender;

)