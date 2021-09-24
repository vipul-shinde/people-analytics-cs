# 3. Problem Solving

## 3.1 Current Employee Snapshot

```sql
DROP VIEW IF EXISTS mv_employees.current_employee_snapshot;
CREATE VIEW mv_employees.current_employee_snapshot AS (
WITH lag_cte AS (
SELECT * FROM (
  SELECT 
    employee_id,
    to_date,
    LAG(amount) OVER (
      PARTITION BY employee_id
      ORDER BY from_date
    ) AS previous_salary
  FROM mv_employees.salary
) AS all_salaries 
WHERE to_date = '9999-01-01'  
),

-- combine all elements in a join cte
cte_joined_data AS (
SELECT
  employee.id AS employee_id,
  employee.gender,
  employee.hire_date,
  title.title,
  salary.amount AS salary,
  lag_cte.previous_salary,
  department.dept_name AS department,
  title.from_date AS title_from_date,
  department_employee.from_date AS department_from_date
FROM mv_employees.employee
INNER JOIN mv_employees.title
  ON employee.id = title.employee_id
INNER JOIN mv_employees.salary
  ON employee.id = salary.employee_id
INNER JOIN lag_cte
  ON employee.id = lag_cte.employee_id
INNER JOIN mv_employees.department_employee
  ON employee.id = department_employee.employee_id
INNER JOIN mv_employees.department
  ON department_employee.department_id = department.id
WHERE 
  salary.to_date = '9999-01-01'
  AND title.to_date = '9999-01-01'
  AND department_employee.to_date = '9999-01-01'
),

-- perform all the calculations
final_output AS (
SELECT
  employee_id,
  gender,
  title,
  salary,
  department,
  -- calculate salary percent change
  ROUND(
    100 * (salary - previous_salary)::NUMERIC / previous_salary,
    2 ) AS salary_percentage_change,
  -- tenures
  DATE_PART('year', now()) - 
    DATE_PART('year', hire_date) AS company_tenure_years,
  DATE_PART('year', now()) - 
    DATE_PART('year', title_from_date) AS title_tenure_years,
  DATE_PART('year', now()) - 
    DATE_PART('year', department_from_date) AS department_tenure_years
FROM cte_joined_data
)
SELECT * FROM final_output
);
```

Let's take a look at sample data from the above created view.

```sql
SELECT *
FROM mv_employees.current_employee_snapshot
LIMIT 5;
```

*Output:*

| employee_id | gender | title           | salary | department      | salary_percentage_change | company_tenure_years | title_tenure_years | department_tenure_years |
|-------------|--------|-----------------|--------|-----------------|--------------------------|----------------------|--------------------|-------------------------|
| 10001       | M      | Senior Engineer | 88958  | Development     | 4.54                     | 17                   | 17                 | 17                      |
| 10002       | F      | Staff           | 72527  | Sales           | 0.78                     | 18                   | 7                  | 7                       |
| 10003       | M      | Senior Engineer | 43311  | Production      | -0.89                    | 17                   | 8                  | 8                       |
| 10004       | M      | Senior Engineer | 74057  | Production      | 4.75                     | 17                   | 8                  | 17                      |
| 10005       | M      | Senior Staff    | 94692  | Human Resources | 3.54                     | 14                   | 7                  | 14                      |

## 3.2 Dashboard Aggregation Views

### 3.2.1 Company Level

```sql
-- company level aggregation view
DROP VIEW IF EXISTS mv_employees.company_level_dashboard;
CREATE VIEW mv_employees.company_level_dashboard AS
SELECT
  gender,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()) AS employee_percentage,
  ROUND(AVG(company_tenure_years)) AS company_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY gender;
```

```sql
SELECT *
FROM mv_employees.company_level_dashboard;
```

*Output:*

| gender | employee_count | employee_percentage | company_tenure | avg_salary | avg_salary_percentage_change | min_salary | max_salary | median_salary | inter_quartile_range | stddev_salary |
|--------|----------------|---------------------|----------------|------------|------------------------------|------------|------------|---------------|----------------------|---------------|
| M      | 144114         | 60                  | 13             | 72045      | 3                            | 38623      | 158220     | 69830         | 23624                | 17363         |
| F      | 96010          | 40                  | 13             | 71964      | 3                            | 38936      | 152710     | 69764         | 23326                | 17230         |

### 3.2.2 Department Level

```sql
-- department level aggregation view
DROP VIEW IF EXISTS mv_employees.department_level_dashboard;
CREATE VIEW mv_employees.department_level_dashboard AS
SELECT
  gender,
  department,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY department
  )) AS employee_percentage,
  ROUND(AVG(department_tenure_years)) AS department_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, department;
```

```sql
SELECT *
FROM mv_employees.department_level_dashboard
LIMIT 5;
```

*Output:*

| gender | department       | employee_count | employee_percentage | department_tenure | avg_salary | avg_salary_percentage_change | min_salary | max_salary | median_salary | inter_quartile_range | stddev_salary |
|--------|------------------|----------------|---------------------|-------------------|------------|------------------------------|------------|------------|---------------|----------------------|---------------|
| M      | Customer Service | 10562          | 60                  | 9                 | 67203      | 3                            | 39373      | 143950     | 65100         | 20097                | 15921         |
| F      | Customer Service | 7007           | 40                  | 9                 | 67409      | 3                            | 39812      | 144866     | 65198         | 20450                | 15979         |
| M      | Development      | 36853          | 60                  | 11                | 67713      | 3                            | 39036      | 140784     | 66526         | 19664                | 14267         |
| F      | Development      | 24533          | 40                  | 11                | 67576      | 3                            | 39469      | 144434     | 66355         | 19309                | 14149         |
| M      | Finance          | 7423           | 60                  | 11                | 78433      | 3                            | 39012      | 142395     | 77526         | 24078                | 17242         |

### 3.2.3 Title Level

```sql
-- title level aggregation view
DROP VIEW IF EXISTS mv_employees.title_level_dashboard;
CREATE VIEW mv_employees.title_level_dashboard AS
SELECT
  gender,
  title,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY title
  )) AS employee_percentage,
  ROUND(AVG(title_tenure_years)) AS title_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, title;
```

```sql
SELECT *
FROM mv_employees.title_level_dashboard
LIMIT 5;
```

*Output:*

| gender | title              | employee_count | employee_percentage | title_tenure | avg_salary | avg_salary_percentage_change | min_salary | max_salary | median_salary | inter_quartile_range | stddev_salary |
|--------|--------------------|----------------|---------------------|--------------|------------|------------------------------|------------|------------|---------------|----------------------|---------------|
| M      | Assistant Engineer | 2148           | 60                  | 6            | 57198      | 4                            | 39827      | 117636     | 54384         | 14972                | 11152         |
| F      | Assistant Engineer | 1440           | 40                  | 6            | 57496      | 4                            | 39469      | 106340     | 55234         | 14679                | 10805         |
| M      | Engineer           | 18571          | 60                  | 6            | 59593      | 4                            | 38942      | 130939     | 56941         | 17311                | 12416         |
| F      | Engineer           | 12412          | 40                  | 6            | 59617      | 4                            | 39519      | 115444     | 57220         | 17223                | 12211         |
| M      | Manager            | 5              | 56                  | 9            | 79351      | 2                            | 56654      | 106491     | 72876         | 43242                | 23615         |

