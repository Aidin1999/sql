-- Drop the table if it exists and recreate it with sample data
BEGIN TRANSACTION;
DROP TABLE IF EXISTS dbo.orders;
GO

CREATE TABLE dbo.orders (
    orderid   INT NOT NULL PRIMARY KEY,
    orderdate DATE NOT NULL,
    empid     INT NOT NULL,
    custid    CHAR(1) NOT NULL,
    qty       INT NOT NULL
);
GO

INSERT INTO dbo.orders (orderid, orderdate, empid, custid, qty) 
VALUES 
    (10001, '2014-12-24', 2, 'A', 12),
    (10005, '2014-12-24', 1, 'B', 20),
    (10006, '2015-01-18', 1, 'C', 14),
    (20001, '2015-02-12', 2, 'B', 12),
    (20002, '2016-02-16', 1, 'C', 20),
    (30001, '2014-08-02', 3, 'A', 10),
    (30003, '2016-04-18', 2, 'B', 15),
    (30004, '2014-04-18', 3, 'C', 22),
    (30007, '2016-09-07', 3, 'D', 30),
    (40001, '2015-01-09', 2, 'A', 40),
    (40005, '2016-02-12', 3, 'A', 10);
GO

-- q1: Use RANK and DENSE_RANK to order and rank orders by quantity within each customer
BEGIN TRANSACTION;
SELECT 
    custid,
    orderid,
    qty,
    RANK() OVER (PARTITION BY custid ORDER BY qty) AS rank,
    DENSE_RANK() OVER (PARTITION BY custid ORDER BY qty) AS drank
FROM dbo.orders
ORDER BY custid;
COMMIT;
GO

-- q2: Calculate the dense rank for values in Sales.OrderValues
BEGIN TRANSACTION;
SELECT 
    val, 
    DENSE_RANK() OVER (ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;
COMMIT;
GO

-- q3: Use LAG and LEAD to find differences between current and previous/next quantities
BEGIN TRANSACTION;
SELECT 
    custid,
    orderid,
    qty,
    (-LAG(qty, 1) OVER (PARTITION BY custid ORDER BY orderdate) + qty) AS differperv,
    (LEAD(qty, 1) OVER (PARTITION BY custid ORDER BY orderdate) - qty) AS differnext
FROM dbo.orders
ORDER BY custid, orderdate;
COMMIT;
GO

-- q4: Pivot orders data to get counts of orders per year for each employee
BEGIN TRANSACTION;
SELECT 
    empid,
    [2014] AS cnt2014,
    [2015] AS cnt2015,
    [2016] AS cnt2016
FROM (
    SELECT 
        empid,
        orderid,
        YEAR(orderdate) AS yearorderdate
    FROM dbo.orders
) AS hichi
PIVOT (
    COUNT(orderid) 
    FOR yearorderdate IN ([2014], [2015], [2016])
) AS bazam_hichi;
COMMIT;
GO
