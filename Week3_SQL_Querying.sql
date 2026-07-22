-- SELECT / WHERE / ORDER BY

-- Premium-priced tracks ($1.99 tier vs the standard $0.99)
SELECT Name, UnitPrice
FROM Track
WHERE UnitPrice > 0.99
ORDER BY UnitPrice DESC
LIMIT 10;

-- GROUP BY / HAVING

-- Genres with a large catalogue (more than 150 tracks)
SELECT g.Name AS Genre, COUNT(t.TrackId) AS TrackCount
FROM Track t
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
HAVING COUNT(t.TrackId) > 150
ORDER BY TrackCount DESC;

-- Aggregate functions (SUM, AVG, COUNT)

-- Revenue and invoice volume per billing country
SELECT BillingCountry, ROUND(SUM(Total),2) AS Revenue, COUNT(*) AS Invoices
FROM Invoice
GROUP BY BillingCountry
ORDER BY Revenue DESC
LIMIT 10;

-- ADVANCED SQL — JOINS

-- INNER JOIN: highest-value invoices with the customer who placed them
SELECT i.InvoiceId, CONCAT(c.FirstName,' ',c.LastName) AS Customer,
       i.InvoiceDate, i.Total
FROM Invoice i
INNER JOIN Customer c ON i.CustomerId = c.CustomerId
ORDER BY i.Total DESC
LIMIT 10;

-- LEFT JOIN: identify any customers who have never purchased
SELECT c.CustomerId, CONCAT(c.FirstName,' ',c.LastName) AS Customer, i.InvoiceId
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;

-- RIGHT JOIN: every support rep, including any with zero customers
SELECT CONCAT(e.FirstName,' ',e.LastName) AS SupportRep,
       COUNT(c.CustomerId) AS CustomersSupported
FROM Customer c
RIGHT JOIN Employee e ON c.SupportRepId = e.EmployeeId
GROUP BY e.EmployeeId
ORDER BY CustomersSupported DESC;

-- Subquery — customers spending above the average
SELECT Customer, TotalSpent
FROM (
    SELECT c.CustomerId, CONCAT(c.FirstName,' ',c.LastName) AS Customer,
           SUM(i.Total) AS TotalSpent
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
) AS customer_totals
WHERE TotalSpent > (
    SELECT AVG(Total) FROM (
        SELECT SUM(Total) AS Total FROM Invoice GROUP BY CustomerId
    ) AS invoice_totals
)
ORDER BY TotalSpent DESC;

-- Window functions — RANK / ROW_NUMBER / PARTITION BY

-- Rank customers by lifetime spend
SELECT Customer, TotalSpent,
       RANK()       OVER (ORDER BY TotalSpent DESC) AS SpendRank,
       ROW_NUMBER() OVER (ORDER BY TotalSpent DESC) AS RowNum
FROM (
    SELECT c.CustomerId, CONCAT(c.FirstName,' ',c.LastName) AS Customer,
           ROUND(SUM(i.Total),2) AS TotalSpent
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
) AS t
ORDER BY SpendRank
LIMIT 10;

-- Monthly revenue trend with a running (cumulative) total
SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
       ROUND(SUM(Total),2) AS MonthlyRevenue,
       ROUND(SUM(SUM(Total)) OVER (ORDER BY DATE_FORMAT(InvoiceDate, '%Y-%m')),2) AS RunningTotal
FROM Invoice
GROUP BY Month
ORDER BY Month;

-- BUSINESS PROBLEM SOLVING

-- Top-performing genres by revenue
SELECT g.Name AS Genre, ROUND(SUM(il.UnitPrice * il.Quantity),2) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY Revenue DESC
LIMIT 5;

-- Customer purchasing behavior: order count & average order value
SELECT CONCAT(c.FirstName,' ',c.LastName) AS Customer,
       COUNT(i.InvoiceId) AS Orders,
       ROUND(AVG(i.Total),2) AS AvgOrderValue,
       ROUND(SUM(i.Total),2) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC
LIMIT 10;

-- PART C — QUERY OPTIMIZATION (Task 5)
CREATE INDEX idx_invoice_customer   ON Invoice(CustomerId);
CREATE INDEX idx_invoiceline_invoice ON InvoiceLine(InvoiceId);
CREATE INDEX idx_invoiceline_track   ON InvoiceLine(TrackId);
CREATE INDEX idx_track_genre         ON Track(GenreId);


  -- PART B — SALES DATASET (sample_sales_data.csv)

-- CORE SQL QUERIES

-- SELECT/WHERE/ORDER BY: large shipped orders
SELECT ORDERNUMBER, CUSTOMERNAME, SALES, STATUS
FROM sales
WHERE STATUS = 'Shipped' AND SALES > 5000
ORDER BY SALES DESC
LIMIT 10;

-- GROUP BY/HAVING: high-revenue product lines only
SELECT PRODUCTLINE, ROUND(SUM(SALES),2) AS Revenue, COUNT(*) AS OrderLines
FROM sales
GROUP BY PRODUCTLINE
HAVING SUM(SALES) > 500000
ORDER BY Revenue DESC;

-- Aggregates: quarterly revenue trend
SELECT YEAR_ID, QTR_ID, ROUND(SUM(SALES),2) AS Revenue,
       COUNT(DISTINCT ORDERNUMBER) AS Orders
FROM sales
GROUP BY YEAR_ID, QTR_ID
ORDER BY YEAR_ID, QTR_ID;

-- ADVANCED SQL — JOINS

CREATE TABLE country_territory AS
SELECT DISTINCT COUNTRY, TERRITORY
FROM sales
WHERE TERRITORY IS NOT NULL AND TERRITORY <> '';

-- INNER JOIN
SELECT s.ORDERNUMBER, s.COUNTRY, ct.TERRITORY, s.SALES
FROM sales s
INNER JOIN country_territory ct ON s.COUNTRY = ct.COUNTRY
ORDER BY s.SALES DESC
LIMIT 10;

-- LEFT JOIN
SELECT s.COUNTRY, ct.TERRITORY, COUNT(*) AS Orders
FROM sales s
LEFT JOIN country_territory ct ON s.COUNTRY = ct.COUNTRY
GROUP BY s.COUNTRY, ct.TERRITORY
ORDER BY Orders DESC
LIMIT 10;

-- RIGHT JOIN
SELECT s.ORDERNUMBER, ct.COUNTRY, ct.TERRITORY, s.SALES
FROM sales s
RIGHT JOIN country_territory ct ON s.COUNTRY = ct.COUNTRY
ORDER BY ct.TERRITORY
LIMIT 10;

-- Subquery — orders above the average order value
SELECT ORDERNUMBER, CUSTOMERNAME, OrderTotal
FROM (
    SELECT ORDERNUMBER, CUSTOMERNAME, SUM(SALES) AS OrderTotal
    FROM sales
    GROUP BY ORDERNUMBER, CUSTOMERNAME
) AS order_totals
WHERE OrderTotal > (
    SELECT AVG(OrderTotal) FROM (
        SELECT SUM(SALES) AS OrderTotal FROM sales GROUP BY ORDERNUMBER
    ) AS avg_calc
)
ORDER BY OrderTotal DESC
LIMIT 10;

-- Window functions

-- Rank customers by total revenue
SELECT CUSTOMERNAME, TotalRevenue,
       RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM (
    SELECT CUSTOMERNAME, ROUND(SUM(SALES),2) AS TotalRevenue
    FROM sales
    GROUP BY CUSTOMERNAME
) AS t
ORDER BY RevenueRank
LIMIT 10;

-- Best-selling product per product line (ROW_NUMBER + PARTITION BY)
SELECT PRODUCTLINE, PRODUCTCODE, Revenue
FROM (
    SELECT PRODUCTLINE, PRODUCTCODE, ROUND(SUM(SALES),2) AS Revenue,
           ROW_NUMBER() OVER (PARTITION BY PRODUCTLINE ORDER BY SUM(SALES) DESC) AS rn
    FROM sales
    GROUP BY PRODUCTLINE, PRODUCTCODE
) AS ranked
WHERE rn = 1
ORDER BY Revenue DESC;

-- Monthly revenue trend with running total across 2003-2005
SELECT YEAR_ID, MONTH_ID, ROUND(SUM(SALES),2) AS MonthlyRevenue,
       ROUND(SUM(SUM(SALES)) OVER (ORDER BY YEAR_ID, MONTH_ID),2) AS RunningTotal
FROM sales
GROUP BY YEAR_ID, MONTH_ID
ORDER BY YEAR_ID, MONTH_ID;

-- BUSINESS PROBLEM SOLVING

-- Top 10 customers by revenue
SELECT CUSTOMERNAME, COUNTRY, ROUND(SUM(SALES),2) AS TotalRevenue,
       COUNT(DISTINCT ORDERNUMBER) AS Orders
FROM sales
GROUP BY CUSTOMERNAME
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Deal size distribution and typical order value
SELECT DEALSIZE, COUNT(DISTINCT ORDERNUMBER) AS Orders,
       ROUND(AVG(SALES),2) AS AvgLineValue, ROUND(SUM(SALES),2) AS TotalRevenue
FROM sales
GROUP BY DEALSIZE
ORDER BY TotalRevenue DESC;

-- Top revenue-generating countries
SELECT COUNTRY, ROUND(SUM(SALES),2) AS Revenue
FROM sales
GROUP BY COUNTRY
ORDER BY Revenue DESC
LIMIT 10;

-- PART C — QUERY OPTIMIZATION (Task 5)
CREATE INDEX idx_sales_ordernumber ON sales(ORDERNUMBER);
CREATE INDEX idx_sales_customer    ON sales(CUSTOMERNAME);
CREATE INDEX idx_sales_country     ON sales(COUNTRY);
CREATE INDEX idx_sales_year_month  ON sales(YEAR_ID, MONTH_ID);

