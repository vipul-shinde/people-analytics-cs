-- 4.3 Management Analysis

-- 1. How many managers are there currently in the company?

SELECT 
  COUNT(DISTINCT employee_id) AS total_manager_count
FROM mv_employees.department_manager
WHERE to_date = '9999-01-01';

-- 2. How many employees have ever been a manager?

SELECT 
  COUNT(DISTINCT employee_id) AS total_manager_count
FROM mv_employees.title
WHERE title = 'Manager';

-- 3. On average - how long did it take for an employee to first become a manager from their the date they were originally hired in days?

WITH base_cte AS (
SELECT 
  employee_id,
  MIN(from_date) AS earliest_appointment_date
FROM mv_employees.title
WHERE title = 'Manager'
GROUP BY 1
)

SELECT 
  ROUND(AVG(t1.earliest_appointment_date - t2.hire_date)) AS avg_number_of_days
FROM base_cte AS t1
INNER JOIN mv_employees.employee AS t2
  ON t1.employee_id = t2.id;

-- 4. What was the most common titles that managers had just before before they became a manager?

WITH lag_title_cte AS (
SELECT 
  employee_id,
  from_date,
  title,
  LAG(title) OVER (
    PARTITION BY employee_id
    ORDER BY from_date
  ) AS previous_title
  FROM mv_employees.title
)

SELECT
  previous_title,
  COUNT(*) AS total_count
FROM lag_title_cte
WHERE title = 'Manager'
AND previous_title IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 5. How many managers were first hired by the company as a manager?

WITH lag_title_cte AS (
SELECT 
  employee_id,
  from_date,
  title,
  LAG(title) OVER (
    PARTITION BY employee_id
    ORDER BY from_date
  ) AS previous_title
  FROM mv_employees.title
)

SELECT
  COUNT(*) AS total_count
FROM lag_title_cte
WHERE title = 'Manager'
AND previous_title IS NULL;

-- 6. On average - how much more do current managers make on average compared to all other employees rounded to the nearest dollar?

WITH current_managers_cte AS (
SELECT 
  AVG(salary) AS avg_manager_salary
FROM mv_employees.current_employee_snapshot
WHERE title = 'Manager'
),

current_employees_cte AS (
SELECT 
  AVG(salary) AS avg_employee_salary
FROM mv_employees.current_employee_snapshot
WHERE title != 'Manager'
)

SELECT
  ROUND(t1.avg_manager_salary - t2.avg_employee_salary) AS difference_salary
FROM current_managers_cte AS t1
CROSS JOIN current_employees_cte AS t2;

-- 7. Which current manager has the most employees in their department?

SELECT
  manager,
  department,
  COUNT(*) AS employee_count
FROM mv_employees.current_employee_snapshot
GROUP BY
  manager,
  department
ORDER BY employee_count DESC
LIMIT 1;

-- 8. What is the difference in employee count between the 3rd and 4th ranking departments by size?

WITH dept_count_cte AS (
SELECT
  department,
  COUNT(*) AS employee_count,
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS dept_rank
FROM mv_employees.current_employee_snapshot
GROUP BY department
)

SELECT *
FROM (
SELECT
  department,
  dept_rank,
  employee_count,
  LEAD(employee_count) OVER (ORDER BY dept_rank) AS next_lowest_count,
  employee_count - LEAD(employee_count) OVER (
    ORDER BY dept_rank
  ) AS difference_count
FROM dept_count_cte
) AS subquery
WHERE dept_rank = 3;