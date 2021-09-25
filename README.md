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

[![forthebadge](images/badges/solution-data-exploration.svg)](https://github.com/vipul-shinde/people-analytics-cs/tree/main/01-Data-Exploration)

