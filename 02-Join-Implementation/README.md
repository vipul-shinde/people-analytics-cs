# 2. Join Implementation

Let's take a look at the tables distinct employee_id based on the ```to_date``` column.

First, let's check out the total count in the ```employee``` and ```department``` as they don't have any SCD values present in them. Also, the ```employee``` table should contain 1 row for each ```employee_id``` and should not contain any duplicates.

```sql
WITH base_cte AS (
SELECT
  id,
  COUNT(*) AS row_count
FROM mv_employees.employee
GROUP BY 1
)

SELECT 
  row_count,
  COUNT(*) AS total_count
FROM base_cte
GROUP BY row_count
ORDER BY total_count DESC;
```

*Output:*

| row_count | total_count |
|-----------|-------------|
| 1         | 300024      |

This confirms that there is just 1 unique row for each ```id``` in the ```employee``` table.

Now, let's check out the ```department``` table.

```sql
SELECT *
FROM mv_employees.department;
```

*Output:*

| id   | dept_name          |
|------|--------------------|
| d009 | Customer Service   |
| d005 | Development        |
| d002 | Finance            |
| d003 | Human Resources    |
| d001 | Marketing          |
| d004 | Production         |
| d006 | Quality Management |
| d008 | Research           |
| d007 | Sales              |

So, only 9 values present in this table. No need to check for anything else. Let's move on to the tables containing SCD values.

- title table

```sql
SELECT 
  to_date,
  COUNT(*) AS total_employees,
  COUNT(DISTINCT employee_id) AS employee_count
FROM mv_employees.title
GROUP BY 1
ORDER BY 1 DESC
LIMIT 5;
```

*Output:*

| to_date    | total_employees | employee_count |
|------------|-----------------|----------------|
| 9999-01-01 | 240124          | 240124         |
| 2020-08-01 | 40              | 40             |
| 2020-07-31 | 65              | 65             |
| 2020-07-30 | 53              | 53             |
| 2020-07-29 | 52              | 52             |

But, our total employee count was ```300024``` which means many employees have churned throughout the years. 

- salary table

```sql
SELECT 
  to_date,
  COUNT(*) AS total_employees,
  COUNT(DISTINCT employee_id) AS employee_count
FROM mv_employees.salary
GROUP BY 1
ORDER BY 1 DESC
LIMIT 5;
```

*Output:*

| to_date    | total_employees | employee_count |
|------------|-----------------|----------------|
| 9999-01-01 | 240124          | 240124         |
| 2020-08-01 | 686             | 686            |
| 2020-07-31 | 641             | 641            |
| 2020-07-30 | 673             | 673            |
| 2020-07-29 | 679             | 679            |

- department_employee table

```sql
SELECT 
  to_date,
  COUNT(*) AS total_employees,
  COUNT(DISTINCT employee_id) AS employee_count
FROM mv_employees.department_employee
GROUP BY 1
ORDER BY 1 DESC
LIMIT 5;
```

*Output:*

| to_date    | total_employees | employee_count |
|------------|-----------------|----------------|
| 9999-01-01 | 240124          | 240124         |
| 2020-08-01 | 20              | 20             |
| 2020-07-31 | 28              | 28             |
| 2020-07-30 | 32              | 32             |
| 2020-07-29 | 27              | 27             |

As, we can see we got similar number of unique ```employee_id``` present in all the SCD tables when it comes to current employees. Let's begin the joining based on the primary_key and foreign_key as seen in the data exploration part.

```sql
DROP TABLE IF EXISTS current_join_table;
CREATE TEMP TABLE current_join_table AS
SELECT
  employee.id,
  employee.birth_date,
  employee.first_name,
  employee.last_name,
  employee.gender,
  employee.hire_date,
  title.title,
  title.from_date AS title_from_date,
  title.to_date AS title_to_date,
  salary.amount,
  salary.from_date AS salary_from_date,
  salary.to_date AS salary_to_date,
  department_employee.department_id,
  department_employee.from_date AS dept_from_date,
  department_employee.to_date AS dept_to_date,
  department.dept_name
FROM mv_employees.employee
INNER JOIN mv_employees.title
  ON employee.id = title.employee_id
INNER JOIN mv_employees.salary
  ON employee.id = salary.employee_id
INNER JOIN mv_employees.department_employee
  ON employee.id = department_employee.employee_id
INNER JOIN mv_employees.department
  ON department_employee.department_id = department.id
-- Filter out the records only for the current employees
WHERE salary.to_date = '9999-01-01'
  AND title.to_date = '9999-01-01'
  AND department_employee.to_date = '9999-01-01';
```

Let's now take a look at the total number of values we have in our ```current_join_table```.

```sql
SELECT
  COUNT(*) AS row_count
FROM current_join_table;
```

*Output:*

| row_count |
|-----------|
| 240124    |

