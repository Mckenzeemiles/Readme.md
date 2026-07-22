Week 3: SQL & Data Querying
AnalystLabAfrica Internship — Data Analytics Track
Overview
This project applies core and advanced SQL to two datasets: the Chinook music store database and the Sample Sales Data dataset from Kaggle. The goal was to move from basic querying to business-driven analysis using joins, subqueries, window functions, and query optimization.
Datasets
Dataset
Source
Description
Chinook
lerocha/chinook-database
Digital music store: 11 tables, 3,503 tracks, 412 invoices, 59 customers
Sample Sales Data
Kaggle
2,823 order lines across product lines, countries, and deal sizes
Tools Used
MySQL / SQLite
SQL client (MySQL Workbench)
Python (pandas) for data loading and validation
What's in This Repo
File
Description
Week3_SQL_Querying.sql
Full commented SQL script — schema setup, core queries, joins, subqueries, window functions, business questions, and indexing
Week3_SQL_Report.docx
Write-up explaining each query and the real insights it produced
chart_chinook_genre_revenue.png
Top genres by revenue (Chinook)
chart_sales_productline_revenue.png
Revenue by product line (Sales dataset)
chart_sales_quarterly_trend.png
Quarterly revenue trend (Sales dataset)
SQL Concepts Covered
SELECT, WHERE, ORDER BY
GROUP BY, HAVING
Aggregate functions: SUM, AVG, COUNT
INNER JOIN, LEFT JOIN, RIGHT JOIN
Subqueries
Window functions: RANK(), ROW_NUMBER(), PARTITION BY
Indexing for query optimization
Key Insights
Chinook (Music Store)
Rock makes up 37% of the entire track catalogue and generates more than double the revenue of the next genre (Latin).
All 59 customers have made at least one purchase — no dormant customer segment.
Customer support workload is concentrated in just 3 of 8 employees.
Sales Dataset
Classic Cars is the flagship product line, generating ~39% of total revenue ($3.92M of $10.03M).
Q4 is consistently the strongest sales quarter every year — a clear seasonal pattern.
A join across countries and territories revealed a data quality gap: the USA, the largest market, has no territory value in the source data.
Medium-size deals are the revenue backbone (61% of total revenue), even though Large deals have the highest average value per order.
How to Run
Create the databases and tables using the schema section of Week3_SQL_Querying.sql.
Load the Chinook data and sales_data_sample.csv into the respective tables.
Run each labeled section of the script in a SQL client such as MySQL Workbench.
Author
Mckenzee — AnalystLabAfrica Data Analytics Internship
