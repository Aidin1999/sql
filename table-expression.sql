-- Use the TSQLV4 database
USE TSQLV4;
GO

-- 1-1: Select distinct orders with the end of year date
BEGIN TRANSACTION;
WITH endofyear AS (
    SELECT DATEFROMPARTS(YEAR(orderdate), 12, 31) AS DATEFROMPARTS
    FROM Sales.Orders
)
SELECT DISTINCT orderid, orderdate, custid, empid, DATEFROMPARTS
FROM Sales.Orders, endofyear
WHERE orderdate = DATEFROMPARTS;
COMMIT;
GO

-- q2 1: Retrieve the maximum order date for each employee
BEGIN TRANSACTION;
SELECT DISTINCT MAX(o1.orderdate) AS maxorderdate, o1.empid
FROM Sales.Orders AS o1 
INNER JOIN Sales.Orders AS o2 ON o1.empid = o2.empid 
GROUP BY o1.empid;
COMMIT;
GO

-- q2 2: Use CTE to retrieve the maximum order date for each employee
BEGIN TRANSACTION;
WITH maxorderdate AS (
    SELECT DISTINCT MAX(o1.orderdate) AS maxorderdate, o1.empid
    FROM Sales.Orders AS o1 
    INNER JOIN Sales.Orders AS o2 ON o1.empid = o2.empid 
    GROUP BY o1.empid
)
SELECT maxorderdate
FROM maxorderdate;
COMMIT;
GO

-- q3-1: Retrieve orders with a row number based on the order date
BEGIN TRANSACTION;
SELECT orderid, orderdate, custid, empid, ROW_NUMBER() OVER(ORDER BY orderdate) AS rownum
FROM Sales.Orders 
ORDER BY orderdate;
COMMIT;
GO

-- q3-2: Use CTE to paginate the orders
BEGIN TRANSACTION;
WITH someorders AS (
    SELECT TOP (100) PERCENT orderid, orderdate, custid, empid, ROW_NUMBER() OVER(ORDER BY orderdate) AS rownum
    FROM Sales.Orders 
    ORDER BY orderdate 
) 
SELECT * 
FROM someorders 
ORDER BY rownum 
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;
COMMIT;
GO

-- q4: Recursive CTE to find the chain of employees
BEGIN TRANSACTION;
WITH chainemployee AS (
    SELECT empid, mgrid, firstname, lastname 
    FROM hr.Employees 
    WHERE empid = 9
    UNION ALL
    SELECT d.empid, d.mgrid, d.firstname, d.lastname 
    FROM chainemployee AS c
    JOIN hr.Employees AS d ON d.empid = c.mgrid 
)
SELECT * 
FROM chainemployee;
COMMIT;
GO

-- q5-1: Drop and recreate the Sales.VEmpOrders view
BEGIN TRANSACTION;
DROP VIEW IF EXISTS Sales.VEmpOrders;
GO

CREATE VIEW Sales.VEmpOrders AS 
(
    SELECT DISTINCT o.empid, YEAR(o.orderdate) AS orderyear, SUM(od.qty) AS sumqty
    FROM Sales.Orders AS o
    JOIN Sales.OrderDetails AS od ON o.orderid = od.orderid 
    GROUP BY o.empid, YEAR(o.orderdate)
);
GO

SELECT * 
FROM Sales.VEmpOrders 
ORDER BY empid, orderyear;
COMMIT;
GO

-- q5-2: Retrieve running total of quantity ordered by employees per year
BEGIN TRANSACTION;
SELECT DISTINCT TOP (100) PERCENT v1.empid, v1.orderyear, v1.sumqty, SUM(v2.sumqty) AS runqty
FROM Sales.VEmpOrders AS v1
JOIN Sales.VEmpOrders AS v2 ON v1.empid = v2.empid AND v2.orderyear <= v1.orderyear
GROUP BY v1.empid, v1.orderyear, v1.sumqty
ORDER BY v1.empid, v1.orderyear;
COMMIT;
GO

-- q6-1: Drop and recreate the function Production.topproduct
BEGIN TRANSACTION;
DROP FUNCTION IF EXISTS Production.topproduct;
GO

CREATE FUNCTION Production.topproduct(@supid INT, @n INT)
RETURNS TABLE 
AS 
RETURN (
    SELECT TOP(@n) productid, productname, unitprice
    FROM Production.Products 
    WHERE supplierid = @supid 
    ORDER BY unitprice
);
GO

SELECT * 
FROM Production.topproduct(5, 2);
COMMIT;
GO

-- q6-2: Use CROSS APPLY with Production.topproduct function
BEGIN TRANSACTION;
SELECT s.supplierid, s.companyname, p.productid, p.productname, p.unitprice 
FROM Production.Products AS p
JOIN Production.Suppliers AS s ON p.supplierid = s.supplierid
CROSS APPLY Production.topproduct(s.supplierid, 2) AS a
WHERE p.supplierid = s.supplierid AND a.productid = p.productid;
COMMIT;
GO
