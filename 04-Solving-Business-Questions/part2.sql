-- 4.2 Employee Churn

-- 1. How many employees have left the company?

SELECT 
  COUNT(*) AS churned_employees
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01';

-- 2. What percentage of churn employees were male?

WITH churn_cte AS (
SELECT
  gender,
  COUNT(*) AS churned_employees,
  ROUND (
    100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()
  ) AS total_percentage
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01'
GROUP BY gender
)

SELECT *
FROM churn_cte
WHERE gender = 'M';

-- 3. Which title had the most churn?

SELECT
  title,
  COUNT(*) AS churn_employees_count
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 4. Which department had the most churn?

SELECT
  department,
  COUNT(*) AS churn_employees_count
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 5. Which year had the most churn?

SELECT
  DATE_PART('year', expiry_date) AS year,
  COUNT(*) AS churn_employees_count
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 6. What was the average salary for each employee who has left the company rounded to the nearest integer?

SELECT
  ROUND(AVG(salary)) AS avg_salary
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01';

-- 7. What was the median total company tenure for each churn employee just before they left?

SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY company_tenure_years) AS median_company_tenure
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01';


-- 8. On average, how many different titles did each churn employee hold rounded to 1 decimal place?

WITH churned_employees AS (
SELECT
  employee_id
FROM mv_employees.historic_employee_records
WHERE
  event_order = 1
  AND expiry_date <> '9999-01-01'
),

title_count_cte AS (
SELECT
  employee_id,
  COUNT(DISTINCT title) AS total_title_count
FROM mv_employees.historic_employee_records
WHERE EXISTS (
  SELECT 1
  FROM churned_employees
  WHERE historic_employee_records.employee_id = churned_employees.employee_id
)
GROUP BY employee_id
)

SELECT
  ROUND(AVG(total_title_count), 1) AS avg_title
FROM title_count_cte;

-- 9. What was the average last pay increase for churn employees?

WITH last_pay_increase_cte AS (
SELECT
  employee_id,
  salary_amount_change AS pay_increase
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01'
) 

SELECT
  AVG(pay_increase) AS avg_pay_increase
FROM last_pay_increase_cte
WHERE pay_increase > 0;

-- 10. How many of churn employees had a pay decrease event in their last 5 events?

WITH pay_decrease_cte AS (
SELECT *
FROM (
SELECT 
  employee_id,
  SUM(
  CASE WHEN event_name = 'Salary Decrease' THEN 1
  ELSE 0
  END
  ) AS salary_decrease_count
FROM mv_employees.historic_employee_records
WHERE 
  event_order <= 5
GROUP BY employee_id
) AS subquery
WHERE salary_decrease_count > 0
),

churned_employees AS (
SELECT 
  employee_id
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01'
)

SELECT 
  COUNT(*) AS churn_pay_decrease_count
FROM pay_decrease_cte
WHERE EXISTS (
  SELECT 1
  FROM churned_employees
  WHERE pay_decrease_cte.employee_id = churned_employees.employee_id
);
