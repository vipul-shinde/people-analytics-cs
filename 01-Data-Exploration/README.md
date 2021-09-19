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
