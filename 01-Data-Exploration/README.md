# 1. Data Exploration

## 1.1 employee table

Let's first take a look at the ```employee``` table which contains all the details of the employees working in the company. Also, we have been notified that the date fields in our HR analytics schema have been entered incorrectly due to a mistake by an intern. We will try to rectify that later after we have done exploring the dataset.

```sql
SELECT *
FROM employees.employee
LIMIT 5;
```

*Output:*

| id    | birth_date | first_name | last_name | gender | hire_date  |
|-------|------------|------------|-----------|--------|------------|
| 10001 | 1953-09-02 | Georgi     | Facello   | M      | 1986-06-26 |
| 10002 | 1964-06-02 | Bezalel    | Simmel    | F      | 1985-11-21 |
| 10003 | 1959-12-03 | Parto      | Bamford   | M      | 1986-08-28 |
| 10004 | 1954-05-01 | Chirstian  | Koblick   | M      | 1986-12-01 |
| 10005 | 1955-01-21 | Kyoichi    | Maliniak  | M      | 1989-09-12 |

Let's also quickly check the total number of distinct ```employee_id``` present in the ```employee``` table.

```sql
SELECT 
  COUNT(DISTINCT id) AS total_employees
FROM employees.employee;
```

*Output:*

| total_employees |
|-----------------|
| 300024          |

Whoa! That's a lot of employees that have worked or are working currently in the company.

## 1.2 title table

The ```title``` table contains all the records or the position/title held by each employee throughout their tenure in this company.

```sql
SELECT *
FROM employees.title
LIMIT 5;
```

*Output:*

| employee_id | title           | from_date  | to_date    |
|-------------|-----------------|------------|------------|
| 10001       | Senior Engineer | 1986-06-26 | 9999-01-01 |
| 10002       | Staff           | 1996-08-03 | 9999-01-01 |
| 10003       | Senior Engineer | 1995-12-03 | 9999-01-01 |
| 10004       | Engineer        | 1986-12-01 | 1995-12-01 |
| 10004       | Senior Engineer | 1995-12-01 | 9999-01-01 |

Now, if an employee has worked for a longer tenure, it is possible that he/she might have been promoted. This concludes that there will be multiple records for a particular ```employee_id``` in the ```title``` suggesting there is a one-to-many relationship. Lets check if it's true.

```sql
SELECT *
FROM employees.title
WHERE employee_id = 10005
ORDER BY from_date;
```

*Output:*

| employee_id | title        | from_date  | to_date    |
|-------------|--------------|------------|------------|
| 10005       | Staff        | 1989-09-12 | 1996-09-12 |
| 10005       | Senior Staff | 1996-09-12 | 9999-01-01 |

As we can see, there are multiple records for one ```employee_id``` in the ```title``` table. Also, it can be seen that there is a many-to-one relationship between ```title``` and the ```employee``` tables.

## 1.3 salary table

The ```salary``` table contains the details of all the different salaries an employee had throughout their tenure in the company. Let's take a look at the salary details for the ```employee_id = 10005```.

```sql
SELECT *
FROM employees.salary
WHERE employee_id = 10005
ORDER BY from_date;
```

*Output:*

| employee_id | amount | from_date  | to_date    |
|-------------|--------|------------|------------|
| 10005       | 78228  | 1989-09-12 | 1990-09-12 |
| 10005       | 82621  | 1990-09-12 | 1991-09-12 |
| 10005       | 83735  | 1991-09-12 | 1992-09-11 |
| 10005       | 85572  | 1992-09-11 | 1993-09-11 |
| 10005       | 85076  | 1993-09-11 | 1994-09-11 |
| 10005       | 86050  | 1994-09-11 | 1995-09-11 |
| 10005       | 88448  | 1995-09-11 | 1996-09-10 |
| 10005       | 88063  | 1996-09-10 | 1997-09-10 |
| 10005       | 89724  | 1997-09-10 | 1998-09-10 |
| 10005       | 90392  | 1998-09-10 | 1999-09-10 |
| 10005       | 90531  | 1999-09-10 | 2000-09-09 |
| 10005       | 91453  | 2000-09-09 | 2001-09-09 |
| 10005       | 94692  | 2001-09-09 | 9999-01-01 |

In the last row, we see an arbitrary value of ```to_date``` = 9999-01-01 which we checkout further later on.

## 1.4 department table

Next is the ```department``` table in which we got the names of all the departments referring to the ```department_id```/```id```.

```sql
SELECT *
FROM employees.department
LIMIT 5;
```

*Output:*

| id   | dept_name        |
|------|------------------|
| d009 | Customer Service |
| d005 | Development      |
| d002 | Finance          |
| d003 | Human Resources  |
| d001 | Marketing        |

## 1.5 department_employee table

This table keeps track of all the ```department_id``` associated with an employee throughout their tenure in the company. Here also, we can see the slow changing dimensions (SCD) which means there will be some expired records of employees in the table when someone has changed their department.

```sql
SELECT *
FROM employees.department_employee
LIMIT 5;
```

*Output:*

| employee_id | department_id | from_date  | to_date    |
|-------------|---------------|------------|------------|
| 10001       | d005          | 1986-06-26 | 9999-01-01 |
| 10002       | d007          | 1996-08-03 | 9999-01-01 |
| 10003       | d004          | 1995-12-03 | 9999-01-01 |
| 10004       | d004          | 1986-12-01 | 9999-01-01 |
| 10005       | d003          | 1989-09-12 | 9999-01-01 |

Now, let's take a look a few unique records that have multiple department records.

```sql
SELECT 
  employee_id,
  COUNT(*) AS department_count
FROM employees.department_employee
GROUP BY employee_id
ORDER BY department_count DESC
LIMIT 5;
```

*Output:*

| employee_id | department_count |
|-------------|------------------|
| 10029       | 2                |
| 10040       | 2                |
| 10010       | 2                |
| 10018       | 2                |
| 10050       | 2                |

```sql
SELECT *
FROM employees.department_employee
WHERE employee_id = 10029
ORDER BY from_date;
```

*Output:*

| employee_id | department_id | from_date  | to_date    |
|-------------|---------------|------------|------------|
| 10029       | d004          | 1991-09-18 | 1999-07-08 |
| 10029       | d006          | 1999-07-08 | 9999-01-01 |

## 1.6 department_manager table

This table gives us details about who was the manager for each department and for what period of time. Let's take a look at a sample example and list out the managers for the department ```d002```.

```sql
SELECT *
FROM employees.department_manager
WHERE department_id = 'd002'
ORDER BY from_date;
```

*Output:*

| employee_id | department_id | from_date  | to_date    |
|-------------|---------------|------------|------------|
| 110085      | d002          | 1985-01-01 | 1989-12-17 |
| 110114      | d002          | 1989-12-17 | 9999-01-01 |

## 1.7 Create a materialized view with updated values

As said earlier, there was a mistake done by one of the intern while filling the dates column values. Also, we are not allowed to make any changes to the base database tables. Hence, we will create a materialized view along with the updated values and also set the indexes for faster querying.

```sql
DROP SCHEMA IF EXISTS mv_employees CASCADE;
CREATE SCHEMA mv_employees;

-- department
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department;
CREATE MATERIALIZED VIEW mv_employees.department AS
SELECT * FROM employees.department;


-- department employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_employee;
CREATE MATERIALIZED VIEW mv_employees.department_employee AS
SELECT
  employee_id,
  department_id,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.department_employee;

-- department manager
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_manager;
CREATE MATERIALIZED VIEW mv_employees.department_manager AS
SELECT
  employee_id,
  department_id,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.department_manager;

-- employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.employee;
CREATE MATERIALIZED VIEW mv_employees.employee AS
SELECT
  id,
  (birth_date + interval '18 years')::DATE AS birth_date,
  first_name,
  last_name,
  gender,
  (hire_date + interval '18 years')::DATE AS hire_date
FROM employees.employee;

-- salary
DROP MATERIALIZED VIEW IF EXISTS mv_employees.salary;
CREATE MATERIALIZED VIEW mv_employees.salary AS
SELECT
  employee_id,
  amount,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.salary;

-- title
DROP MATERIALIZED VIEW IF EXISTS mv_employees.title;
CREATE MATERIALIZED VIEW mv_employees.title AS
SELECT
  employee_id,
  title,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.title;

-- Index Creation
-- NOTE: we do not name the indexes as they will be given randomly upon creation!
CREATE UNIQUE INDEX ON mv_employees.employee USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department_employee USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_employee USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (dept_name);
CREATE UNIQUE INDEX ON mv_employees.department_manager USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_manager USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.salary USING btree (employee_id, from_date);
CREATE UNIQUE INDEX ON mv_employees.title USING btree (employee_id, title, from_date);
```

Now, we will move on to the table join implementation part after which we can start the problem solving.

