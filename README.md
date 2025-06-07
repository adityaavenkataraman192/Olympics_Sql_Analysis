# 🏅 Olympics SQL Analysis

This project presents an in-depth SQL-based analysis of Olympic Games historical data, exploring trends in country participation, medal distribution, athlete performance, and event statistics. The queries leverage PostgreSQL features including window functions, CTEs, and pivoting with `crosstab`.

---

## 📂 Dataset Overview

The project uses two core tables:
This project utilizes the [120 Years of Olympic History: Athletes and Results](https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results) dataset from Kaggle. It encompasses detailed records from the modern Olympic Games, spanning from Athens 1896 to Rio 2016. The dataset includes information on athletes, events, medals, and participating countries.

- **`olympics_history`**  
  Contains detailed data on athletes, events, teams, medals, and years.
  
- **`olympics_history_noc_regions`**  
  Maps National Olympic Committee (NOC) codes to full country/region names.

---

## ✅ Objectives & Key Queries

Problem Statemants:

1.How many olympics games have been held?
2.List down all Olympics games held so far.
3.Mention the total no of nations who participated in each olympics game?
4.Which year saw the highest and lowest no of countries participating in olympics?
5.Which nation has participated in all of the olympic games?
6.Identify the sport which was played in all summer olympics.
7.Which Sports were just played only once in the olympics?
8.Fetch the total no of sports played in each olympic games.
9.Fetch details of the oldest athletes to win a gold medal.
10.Find the Ratio of male and female athletes participated in all olympic games.
11.Fetch the top 5 athletes who have won the most gold medals.
12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
14.List down total gold, silver and broze medals won by each country.
15.List down total gold, silver and broze medals won by each country corresponding to each olympic games.
16.Identify which country won the most gold, most silver and most bronze medals in each olympic games.
17.Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
18.Which countries have never won gold medal but have won silver/bronze medals?
19.In which Sport/event, India has won highest medals.
20.Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

Each query is clearly labeled in the SQL file and uses best practices in SQL query structure.

---

## 🛠️ Concepts Used

- **SQL (PostgreSQL)**
- **PostgreSQL Extensions**: `tablefunc` (for crosstab)
- **Advanced SQL Features**:
  - CTEs (`WITH` clauses)
  - Aggregate functions
  - Window functions (`RANK`, `DENSE_RANK`, `FIRST_VALUE`)
  - Conditional logic with `CASE WHEN`

---

## 📊 Insights Extracted

- Participation and medal trends across countries and years
- Top-performing sports and nations
- Gender-based participation patterns
- Medal distribution for individual athletes
- India's Olympic history analysis

---
