# 4. Business Questions

To complete this HR Analytics case study - there is a total of 3 different quizzes broken down by analytical focus areas:

1. Current Analysis
2. Employee Churn
3. Management Analysis

## 4.1 Current Analysis

### 1. What is the full name of the employee with the highest salary?

```sql
SELECT 
  employee_name,
  salary
FROM mv_employees.current_employee_snapshot
ORDER BY salary DESC
LIMIT 1;
```

*Output:*

| employee_name  | salary |
|----------------|--------|
| Tokuyasu Pesch | 158220 |

### 2. How many current employees have the equal longest tenure years in their current title?

```sql
SELECT 
  title_tenure_years,
  COUNT(*) AS total_count
FROM mv_employees.current_employee_snapshot
GROUP BY 1
ORDER BY 1 DESC
LIMIT 5;
```

*Output:*

| title_tenure_years | total_count |
|--------------------|-------------|
| 18                 | 3505        |
| 17                 | 3823        |
| 16                 | 3781        |
| 15                 | 3919        |
| 14                 | 3886        |

### 3. Which department has the least number of current employees?

```sql
SELECT 
  department,
  COUNT(*) AS total_count
FROM mv_employees.current_employee_snapshot
GROUP BY 1
ORDER BY 2
LIMIT 5;
```

*Output:*

| department         | total_count |
|--------------------|-------------|
| Finance            | 12437       |
| Human Resources    | 12898       |
| Quality Management | 14546       |
| Marketing          | 14842       |
| Research           | 15441       |

### 4. What is the largest difference between minimum and maximum salary values for all current employees?

```sql
with min_max_salary AS (
SELECT 
  MIN(salary) AS minimum_salary,
  MAX(salary) AS maximum_salary
FROM mv_employees.current_employee_snapshot
)

SELECT 
  maximum_salary - minimum_salary AS range_value
FROM min_max_salary;
```

*Output:*

| range_value |
|-------------|
| 119597      |

### 5. How many male employees are above the overall average salary value for the `Production` department?

```sql
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
```

*Output:*

| total_count |
|-------------|
| 14999       |

### 6. Which title has the highest average salary for male employees?

```sql
SELECT
  title,
  ROUND(AVG(salary), 2) AS avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

*Output:*

| title            | avg_salary |
|------------------|------------|
| Senior Staff     | 80735.48   |
| Manager          | 79350.60   |
| Senior Engineer  | 70869.91   |
| Technique Leader | 67599.67   |
| Staff            | 67362.18   |

### 7. Which department has the highest average salary for female employees?

```sql
SELECT
  department,
  ROUND(AVG(salary), 2) AS avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'F'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

*Output:*

| department | avg_salary |
|------------|------------|
| Sales      | 88835.96   |
| Marketing  | 79699.77   |
| Finance    | 78747.42   |
| Research   | 68011.86   |
| Production | 67728.11   |

### 8. Which department has the most female employees?

```sql
SELECT
  department,
  COUNT(*) AS female_count
FROM mv_employees.current_employee_snapshot
WHERE gender = 'F'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

*Output:*

| department       | female_count |
|------------------|--------------|
| Development      | 24533        |
| Production       | 21393        |
| Sales            | 14999        |
| Customer Service | 7007         |
| Research         | 6181         |

### 9. What is the gender ratio in the department which has the highest average male salary and what is the average male salary value rounded to the nearest integer?

> Highest Average salary category for male employees

```sql
SELECT
  department,
  ROUND(AVG(salary)) AS avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

*Output:*

| department | avg_salary |
|------------|------------|
| Sales      | 88864      |

> Ratio Count of Male to Female Employees

```sql
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
```

*Output:*

| female_count | male_count |
|--------------|------------|
| 14999        | 22702      |

### 10. HR Analytica want to change the average salary increase percentage value to 2 decimal places - what should the new value be for males for the company level dashboard?

```sql
SELECT
  ROUND(AVG(salary_percentage_change), 2) AS avg_salary_percentage_change
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M';
```

*Output:*

| avg_salary_percentage_change |
|------------------------------|
| 3.02                         |

### 11. How many current employees have the equal longest overall time in their current department (not in years)?

```sql
SELECT 
  CURRENT_DATE - from_date AS tenure,
  COUNT(DISTINCT employee_id) AS total_employees
FROM mv_employees.department_employee
WHERE to_date = '9999-01-01'
GROUP BY tenure
ORDER BY tenure DESC
LIMIT 1;
```

*Output:*

| tenure | total_employees |
|--------|-----------------|
| 6842   | 9               |

## 4.2 Employee Churn

### 1. How many employees have left the company?

```sql
SELECT 
  COUNT(*) AS churned_employees
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01';
```

*Output:*

| churned_employees |
|-------------------|
| 59910             |

### 2. What percentage of churn employees were male?

```sql
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
```

*Output:*

| gender | churned_employees | total_percentage |
|--------|-------------------|------------------|
| M      | 35864             | 60               |

### 3. Which title had the most churn?

```sql
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
```

*Output:*

| title    | churn_employees_count |
|----------|-----------------------|
| Engineer | 16320                 |

### 4. Which department had the most churn?

```sql
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
```

*Output:*

| department  | churn_employees_count |
|-------------|-----------------------|
| Development | 15578                 |

### 5. Which year had the most churn?

```sql
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
```

*Output:*

| year | churn_employees_count |
|------|-----------------------|
| 2018 | 7610                  |

### 6. What was the average salary for each employee who has left the company rounded to the nearest integer?

```sql
SELECT
  ROUND(AVG(salary)) AS avg_salary
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01';
```

*Output:*

| avg_salary |
|------------|
| 61577      |

### 7. What was the median total company tenure for each churn employee just before they left?

```sql
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY company_tenure_years) AS median_company_tenure
FROM mv_employees.historic_employee_records
WHERE 
  event_order = 1
  AND expiry_date <> '9999-01-01';
```

*Output:*

| median_company_tenure |
|-----------------------|
| 14                    |

### 8. On average, how many different titles did each churn employee hold rounded to 1 decimal place?

```sql
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
```

*Output:*

| avg_title |
|-----------|
| 1.2       |

### 9. What was the average last pay increase for churn employees?

```sql
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
```

*Output:*

| avg_pay_increase   |
|--------------------|
| 2250.6593375214165 |

### 10. How many of churn employees had a pay decrease event in their last 5 events?

```sql
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
```

*Output:*

| churn_pay_decrease_count |
|--------------------------|
| 14328                    |

## 4.3 Management Analysis

### 1. How many managers are there currently in the company?

```sql
SELECT 
  COUNT(DISTINCT employee_id) AS total_manager_count
FROM mv_employees.department_manager
WHERE to_date = '9999-01-01';
```

*Output:*

| total_manager_count |
|---------------------|
| 9                   |

### 2. How many employees have ever been a manager?

```sql
SELECT 
  COUNT(DISTINCT employee_id) AS total_manager_count
FROM mv_employees.title
WHERE title = 'Manager';
```

*Output:*

| total_manager_count |
|---------------------|
| 24                  |

### 3. On average - how long did it take for an employee to first become a manager from their the date they were originally hired in days?

```sql
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
```

*Output:*

| avg_number_of_days |
|--------------------|
| 909                |

### 4. What was the most common titles that managers had just before before they became a manager?

```sql
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
```

*Output:*

| previous_title   | total_count |
|------------------|-------------|
| Senior Staff     | 7           |
| Technique Leader | 4           |
| Senior Engineer  | 3           |
| Staff            | 1           |

### 5. How many managers were first hired by the company as a manager?

```sql
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
```

*Output:*

| total_count |
|-------------|
| 9           |

### 6. On average - how much more do current managers make on average compared to all other employees rounded to the nearest dollar?

```sql
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
```

*Output:*

| difference_salary |
|-------------------|
| 5712              |

### 7. Which current manager has the most employees in their department?

```sql
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
```

*Output:*

| manager       | department  | employee_count |
|---------------|-------------|----------------|
| Leon DasSarma | Development | 61386          |

### 8. What is the difference in employee count between the 3rd and 4th ranking departments by size?

```sql
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
```

*Output:*

| department | dept_rank | employee_count | next_lowest_count | difference_count |
|------------|-----------|----------------|-------------------|------------------|
| Sales      | 3         | 37701          | 17569             | 20132            |

# Thank you!