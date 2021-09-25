-- 4.1 Current Analysis

-- 1. What is the full name of the employee with the highest salary?

SELECT 
  employee_name,
  salary
FROM mv_employees.current_employee_snapshot
ORDER BY salary DESC
LIMIT 1;

-- 2. How many current employees have the equal longest tenure years in their current title?

SELECT 
  title_tenure_years,
  COUNT(*) AS total_count
FROM mv_employees.current_employee_snapshot
GROUP BY 1
ORDER BY 1 DESC
LIMIT 5;

-- 3. Which department has the least number of current employees?

SELECT 
  department,
  COUNT(*) AS total_count
FROM mv_employees.current_employee_snapshot
GROUP BY 1
ORDER BY 2
LIMIT 5;

-- 4. What is the largest difference between minimum and maximum salary values for all current employees?

with min_max_salary AS (
SELECT 
  MIN(salary) AS minimum_salary,
  MAX(salary) AS maximum_salary
FROM mv_employees.current_employee_snapshot
)

SELECT 
  maximum_salary - minimum_salary AS range_value
FROM min_max_salary;

-- 5. How many male employees are above the overall average salary value for the `Production` department?

WITH production_employees AS (
SELECT 
  employee_id,
  salary,
  gender,
  AVG(salary) OVER () AS avg_salary
FROM mv_employees.current_employee_snapshot
WHERE department = 'Production'
)

SELECT 
  SUM(CASE 
        WHEN salary > avg_salary THEN 1
        ELSE 0 
        END
  ) AS total_count
FROM production_employees
WHERE gender = 'M';

-- 6. Which title has the highest average salary for male employees?

SELECT
  title,
  ROUND(AVG(salary), 2) AS avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 7. Which department has the highest average salary for female employees?

SELECT
  department,
  ROUND(AVG(salary), 2) AS avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'F'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 8. Which department has the most female employees?

SELECT
  department,
  COUNT(*) AS female_count
FROM mv_employees.current_employee_snapshot
WHERE gender = 'F'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 9. What is the gender ratio in the department which has the highest average male salary and what is the average male salary value rounded to the nearest integer?

-- Highest Average salary category for male employees

SELECT
  department,
  ROUND(AVG(salary)) AS avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Ratio Count of Male to Female Employees

SELECT
  SUM (CASE
        WHEN gender = 'F' THEN 1
        ELSE 0
        END
  ) AS female_count,
    SUM (CASE
        WHEN gender = 'M' THEN 1
        ELSE 0
        END
  ) AS male_count
FROM mv_employees.current_employee_snapshot
WHERE department = 'Sales';

-- 10. HR Analytica want to change the average salary increase percentage value to 2 decimal places - what should the new value be for males for the company level dashboard?

SELECT
  ROUND(AVG(salary_percentage_change), 2) AS avg_salary_percentage_change
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M';

-- 11. How many current employees have the equal longest overall time in their current department (not in years)?

SELECT 
  CURRENT_DATE - from_date AS tenure,
  COUNT(DISTINCT employee_id) AS total_employees
FROM mv_employees.department_employee
WHERE to_date = '9999-01-01'
GROUP BY tenure
ORDER BY tenure DESC
LIMIT 1;