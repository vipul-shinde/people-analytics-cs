# 5. Exercises

## Calculate the the average salary for the following segments

1. Years of tenure: you can calculate tenure = current date - hire date in years

```sql
WITH base_cte AS (
SELECT
  ROUND((CURRENT_DATE - hire_date)::NUMERIC/365) AS tenure,
  amount AS salary
FROM current_join_table
)

SELECT 
  tenure,
  ROUND(AVG(salary), 2) AS average_salary
FROM base_cte
GROUP BY 1
ORDER BY 1 DESC;
```

*Output:*

| tenure | average_salary |
|--------|----------------|
| 19     | 79298.54       |
| 18     | 78559.00       |
| 17     | 77134.85       |
| 16     | 75437.58       |
| 15     | 73875.03       |
| 14     | 72803.44       |
| 13     | 71070.20       |
| 12     | 69453.19       |
| 11     | 68069.39       |
| 10     | 66637.56       |
| 9      | 64980.37       |
| 8      | 63405.89       |
| 7      | 62129.51       |
| 6      | 60349.20       |
| 5      | 59244.69       |
| 4      | 58303.63       |

2. Title

```sql
SELECT
  title,
  ROUND(AVG(amount), 2) AS average_salary
FROM current_join_table
GROUP BY 1
ORDER BY average_salary DESC;
```

*Output:*

| title              | average_salary |
|--------------------|----------------|
| Senior Staff       | 80706.50       |
| Manager            | 77723.67       |
| Senior Engineer    | 70823.44       |
| Technique Leader   | 67506.59       |
| Staff              | 67330.67       |
| Engineer           | 59602.74       |
| Assistant Engineer | 57317.57       |

3. Department

```sql
SELECT
  dept_name,
  ROUND(AVG(amount), 2) AS average_salary
FROM current_join_table
GROUP BY 1
ORDER BY average_salary DESC;
```

*Output:*

| dept_name          | average_salary |
|--------------------|----------------|
| Sales              | 88852.97       |
| Marketing          | 80058.85       |
| Finance            | 78559.94       |
| Research           | 67913.37       |
| Production         | 67843.30       |
| Development        | 67657.92       |
| Customer Service   | 67285.23       |
| Quality Management | 65441.99       |
| Human Resources    | 63921.90       |

4. Gender

```sql
SELECT
  gender,
  ROUND(AVG(amount), 2) AS average_salary
FROM current_join_table
GROUP BY 1
ORDER BY average_salary DESC;
```

*Output:*

| gender | average_salary |
|--------|----------------|
| M      | 72044.66       |
| F      | 71963.57       |

5. What is the average salary of someone in the Production department?

```sql
SELECT
  dept_name,
  ROUND(AVG(amount), 2) AS average_salary
FROM current_join_table
WHERE dept_name = 'Production'
GROUP BY 1
ORDER BY average_salary DESC;
```

*Output:*

| dept_name  | average_salary |
|------------|----------------|
| Production | 67843.30       |

6. Which position has the highest average salary?

```sql
SELECT
  title,
  ROUND(AVG(amount), 2) AS average_salary
FROM current_join_table
GROUP BY 1
ORDER BY average_salary DESC
LIMIT 1;
```

*Output:*

| title              | average_salary |
|--------------------|----------------|
| Senior Staff       | 80706.50       |

7. Which department has the lowest average salary?

```sql
SELECT
  dept_name,
  ROUND(AVG(amount), 2) AS average_salary
FROM current_join_table
GROUP BY 1
ORDER BY average_salary
LIMIT 1;
```

*Output:*

| department         | average_salary |
|--------------------|----------------|
| Human Resources    |  63921.90      |

