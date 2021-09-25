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

