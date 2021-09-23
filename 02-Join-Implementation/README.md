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

## 2.1 Current Data Join

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

## 2.2 Historic Data Join

```sql
DROP TABLE IF EXISTS historic_join_table;
CREATE TEMP TABLE historic_join_table AS (
WITH join_data AS (
SELECT
  employee.id AS employee_id,
  employee.birth_date,
  CONCAT_WS(' ', employee.first_name, employee.last_name) AS employee_name,
  employee.gender,
  employee.hire_date,
  title.title,
  salary.amount AS salary,
  department.dept_name AS department,
  CONCAT_WS(' ', manager.first_name, manager.last_name) AS manager,
  GREATEST(
    title.from_date,
    salary.from_date,
    department_employee.from_date,
    department_manager.from_date
  ) AS effective_date,
  LEAST(
    title.to_date,
    salary.to_date,
    department_employee.to_date,
    department_manager.to_date    
  ) AS expiry_date
FROM mv_employees.employee
INNER JOIN mv_employees.title
  ON employee.id = title.employee_id
INNER JOIN mv_employees.salary
  ON employee.id = salary.employee_id
INNER JOIN mv_employees.department_employee
  ON employee.id = department_employee.employee_id
INNER JOIN mv_employees.department
  ON department_employee.department_id = department.id
INNER JOIN mv_employees.department_manager
  ON department.id = department_manager.department_id
-- joining again to get the manager name from the employee table
INNER JOIN mv_employees.employee AS manager
  ON department_manager.employee_id = manager.id
)

SELECT
  employee_id,
  birth_date,
  employee_name,
  gender,
  hire_date,
  title,
  LAG(title) OVER w AS previous_title,
  salary,
  LAG(salary) OVER w AS previous_salary,
  department,
  LAG(department) OVER w AS previous_department,
  manager,
  LAG(manager) OVER w AS previous_manager,
  effective_date,
  expiry_date
FROM join_data
WHERE effective_date <= expiry_date
WINDOW
  w AS (PARTITION BY employee_id ORDER BY effective_date)
);
```

Let's check sample historic data for one of the employees when ```employee_id = 11669```

```sql
SELECT *
FROM historic_join_table
WHERE employee_id = 11669;
```

*Output:*

| employee_id | birth_date               | employee_name | gender | hire_date                | title           | previous_title | salary | previous_salary | department       | previous_department | manager         | previous_manager | effective_date           | expiry_date              |
|-------------|--------------------------|---------------|--------|--------------------------|-----------------|----------------|--------|-----------------|------------------|---------------------|-----------------|------------------|--------------------------|--------------------------|
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Engineer        | null           | 41183  | null            | Production       | null                | Oscar Ghazalie  | null             | 2015-05-12T00:00:00.000Z | 2016-05-12T00:00:00.000Z |
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Engineer        | Engineer       | 43577  | 41183           | Production       | Production          | Oscar Ghazalie  | Oscar Ghazalie   | 2016-05-12T00:00:00.000Z | 2017-05-12T00:00:00.000Z |
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Engineer        | Engineer       | 43930  | 43577           | Production       | Production          | Oscar Ghazalie  | Oscar Ghazalie   | 2017-05-12T00:00:00.000Z | 2018-05-11T00:00:00.000Z |
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Engineer        | Engineer       | 43681  | 43930           | Production       | Production          | Oscar Ghazalie  | Oscar Ghazalie   | 2018-05-11T00:00:00.000Z | 2019-05-11T00:00:00.000Z |
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Engineer        | Engineer       | 47046  | 43681           | Production       | Production          | Oscar Ghazalie  | Oscar Ghazalie   | 2019-05-11T00:00:00.000Z | 2019-06-12T00:00:00.000Z |
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Engineer        | Engineer       | 47046  | 47046           | Customer Service | Production          | Yuchang Weedman | Oscar Ghazalie   | 2019-06-12T00:00:00.000Z | 2020-05-11T00:00:00.000Z |
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Engineer        | Engineer       | 47373  | 47046           | Customer Service | Customer Service    | Yuchang Weedman | Yuchang Weedman  | 2020-05-11T00:00:00.000Z | 2020-05-12T00:00:00.000Z |
| 11669       | 1975-03-03T00:00:00.000Z | Leah Anguita  | M      | 2004-04-07T00:00:00.000Z | Senior Engineer | Engineer       | 47373  | 47373           | Customer Service | Customer Service    | Yuchang Weedman | Yuchang Weedman  | 2020-05-12T00:00:00.000Z | 9999-01-01T00:00:00.000Z |

Now, lets move to the problem solving part to fullfil all the requirements required by the People Analytics team for our two dashboards.