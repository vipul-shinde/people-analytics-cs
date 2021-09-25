[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)]()
[![forthebadge](images/badges/uses-postgresql.svg)]()
[![forthebadge](https://forthebadge.com/images/badges/made-with-markdown.svg)]()

<h1 align="center">HR Analytics Case Study - Serious SQL 🚀</h1>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]()
  [![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)]() 
  [![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)]()
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

</div>

---

<p align="center"> This is a people analytics case study from the <a href="https://www.datawithdanny.com/">Serious SQL</a> course by Danny Ma. The HR analytica team have asked us to construct datasets to answer basic reporting questions and also feed their bespoke People Analytics dashboards.
    <br> 
</p>

## 📝 Table of Contents

- [🧐 About](#about)
- [🎯 Getting Started](#getting_started)
- [📊 Data Exploration](#data-exploration)
- [🧲 Join Implementation](#join-implementation)
- [✨ Final Solution](#final-solution)
- [🚀 Business Questions](#business-questions)
- [🎨 Contributing](#contributing)
- [🌟 Support](#support)

## 🧐 About <a name = "about"></a> 

People Analytics or HR Analytics is an increasingly popular focus area for data professionals. Many business and people decisions which were traditionally based off senior management gut feels and intuition are starting to become more data-driven.

In this SQL case study - We’ve have been asked specifically to generate database views that HR Analytica team can use for 2 key dashboards, reporting solutions and ad-hoc analytics requests.

## 🎯 Getting Started <a name = "getting_started"></a>

The following insights must be generated for the 2 dashboards requested by HR Analytica:

### 1️⃣ People Analytics Dashboard

#### 1.1 Company Level Insights
<details>
<summary>Click to View</summary>
<br>

- Total number of employees
- Average company tenure in years
- Gender ratios
- Average payrise percentage and amount

</details>

#### 1.2 Department Level Insights

<details>
<summary>Click to View</summary>
<br>

- Number of employees in each department
- Current department manager tenure in years
- Gender ratios
- Average payrise percentage and amount

</details>

#### 1.3 Title Level Insights

<details>
<summary>Click to View</summary>
<br>

- Number of employees with each title
- Minimum, average, standard deviation of salaries
- Average total company tenure
- Gender ratios
- Average payrise percentage and amount

</details>

The People Analytics dashboard that we need to power data to is shown as below: 

<p align="center">
    <img src="images\current_employee_analysis.png" alt="people-analytics-dashboard" width="400px">
</p>

<p align="center"> <u>Source: <a href="https://www.datawithdanny.com/">Serious SQL</a></u>
    <br> 
</p>

### 2️⃣ Employee Deep Dive

#### 2.1 Individual Employee Deep Dive

<details>
<summary>Click to view</summary>
<br>

- See all the various employment history ordered by effective date including salary, department, manager and title changes
- Calculate previous historic payrise percentages and value changes
- Calculate the previous position and department history in months with start and end dates
- Compare an employee’s current salary, total company tenure, department, position and gender to the average benchmarks for their current position

</details>

The Deep Dive data dashboard is shown as below:

<p align="center">
    <img src="images\employee_deep_dive.png" alt="deep-dive-dashboard" width="400px">
</p>

<p align="center"> <u>Source: <a href="https://www.datawithdanny.com/">Serious SQL</a></u>
    <br> 
</p>

## 📊 Data Exploration <a name = "data-exploration"></a>

We start by doing the data exploration. There are 6 tables in total viz. ```employee```, ```title```, ```salary```, ```department```, ```department_employee``` & ```department_manager```. The ERD diagram of the same is as follows.

<p align="center">
    <img src="images\erd.png" alt="erd">
</p>

<p align="center"> <u>Source: <a href="www.datawithdanny.com">Serious SQL</a></u>
    <br> 
</p>

Additionally - we’ve been notified about the presence of date issues with our datasets where there were data-entry issues related to all DATE related fields. I have fixed that in this section.

### Click to view 👇:

[![forthebadge](images/badges/solution-data-exploration.svg)](https://github.com/vipul-shinde/people-analytics-cs/tree/main/01-Data-Exploration)

## 🧲 Join Implementation <a name = "join-implementation"></a>

Next, we start implementing the table joins which will then help us to start the problem solving. From the analysis section, we have come to conclusion to the following join table sequence.

| Join Journey Part | Start               |  End                      |  Foreign Key         |
|-------------------|---------------------|---------------------------|----------------------|
| Part 1            | ```employee```      | ```title```               | ```employee_id```    |
| Part 2            | ```employee```      | ```salary```              | ```employee_id```    |
| Part 3            | ```employee```      | ```department_employee``` | ```employee_id```    |
| Part 4            | ```department```    | ```department_employee``` | ```department_id```  |
| Part 5            | ```department```    | ```department_manager```  | ```department_id```  |

### Click to view 👇:

[![forthebadge](images/badges/solution-join-implementation.svg)](https://github.com/vipul-shinde/people-analytics-cs/tree/main/02-Join-Implementation)

## ✨ Final Solution <a name = "final-solution"></a>

After implementing the joins, we begin solving for the problems as required by the HR Analytica team. Our solution is divided into two parts viz. ```1. Current Employee Snapshot``` where we have created data assets that can power the first dashboard and ```2. Historic Employee Snapshot``` which will power the second dashboard and contain all the details of the employees at individual level.

### Click to view 👇:

[![forthebadge](images/badges/solution-final-solution.svg)](https://github.com/vipul-shinde/people-analytics-cs/tree/main/03-Final-Solution)

## 🚀 Business Questions <a name = "business-questions"></a>

Lastly, there are a few questions asked by the HR Analytica team and they can be divided into 3 different sections based on the analytical focus areas. They are as follows.

### 1. Current Analysis

<details>
<summary>Click to view questions</summary>
<br>

1. What is the full name of the employee with the highest salary?
2. How many current employees have the equal longest time in their current positions?
3. Which department has the least number of current employees?
4. What is the largest difference between minimimum and maximum salary values for all current employees?
5. How many male employees are above the average salary value for the Production department?
6. Which title has the highest average salary for male employees?
7. Which department has the highest average salary for female employees?
8. Which department has the most female employees?
9. What is the gender ratio in the department which has the highest average male salary and what is the average male salary value for that department?
10. HR Analytica want to change the average salary increase percentage value to 2 decimal places - what will the new value be for males for the company level dashboard?

</details>

### 2. Employee Churn

<details>
<summary>Click to view questions</summary>
<br>

1. How many employees have left the company?
2. What percentage of churn employees were male?
3. Which title had the most churn?
4. Which department had the most churn?
5. Which year had the most churn?
6. What was the average salary for each employee who has left the company?
7. What was the median total company tenure for each churn employee just before they left?
8. On average, how many different titles did each churn employee hold?
9. What was the average last pay increase for churn employees?
10. What proportion of churn employees had a pay decrease event in their last 5 events?
11. How many current employees have the equal longest overall time in their current positions (not in years)?

</details>

### 3. Management Analysis

<details>
<summary>Click to view questions</summary>
<br>

1. How many managers are there currently in the company?
2. How many employees have ever been a manager?
3. On average - how long did it take for an employee to first become a manager from their the date they were originally hired?
4. What was the most common titles that managers had just before before they became a manager?
5. On average - how much more do current managers make on average compared to all other employees?

</details>

### Click to view 👇:

[![forthebadge](images/badges/solution-business-questions.svg)](https://github.com/vipul-shinde/people-analytics-cs/tree/main/04-Solving-Business-Questions)

## 🎨 Contributing <a name = "contributing"></a>

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🌟 Support

Please hit the ⭐button if you like this project. 😄

# Thank you!