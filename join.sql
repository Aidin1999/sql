-- Use the database
USE TSQLV4;

-- Query 1: Retrieve employee details with a self-join condition and order by employee IDs
BEGIN TRANSACTION;
SELECT e1.empid, e1.firstname, e1.lastname, e2.empid AS n
FROM HR.Employees AS e1, HR.Employees AS e2
WHERE e2.empid < 6
ORDER BY e2.empid, e1.empid;
COMMIT;

-- Query 1-2: Retrieve employee IDs and order dates for orders made between June 12 and June 16, 2015
BEGIN TRANSACTION;
SELECT e.empid, s.orderdate
FROM HR.Employees AS e, Sales.Orders AS s
WHERE YEAR(s.orderdate) = 2015 AND MONTH(s.orderdate) = 6 AND DAY(s.orderdate) > 11 AND DAY(s.orderdate) < 17
ORDER BY e.empid, s.orderdate;
COMMIT;

-- Query 2: Inner join between Customers and Orders to retrieve order details
BEGIN TRANSACTION;
SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
FROM Sales.Customers
INNER JOIN Sales.Orders
ON Customers.custid = Orders.custid;
COMMIT;

-- Query 3: Calculate total quantity and number of orders for customers in the USA
BEGIN TRANSACTION;
SELECT c.custid, SUM(od.qty) AS totalqty, COUNT(DISTINCT o.orderid) AS numorders
FROM Sales.Customers AS c, Sales.Orders AS o, Sales.OrderDetails AS od
WHERE c.custid = o.custid AND o.orderid = od.orderid AND o.shipcountry = 'USA'
GROUP BY c.custid
ORDER BY c.custid;
COMMIT;

-- Query 4: Left join between Customers and Orders to retrieve order details
BEGIN TRANSACTION;
SELECT s.custid, s.companyname, o.orderid, o.orderdate
FROM Sales.Customers AS s
LEFT OUTER JOIN Sales.Orders AS o
ON s.custid = o.custid;
COMMIT;

-- Query 5: Retrieve customers who have no orders
BEGIN TRANSACTION;
SELECT s.custid, s.companyname
FROM Sales.Customers AS s
LEFT OUTER JOIN Sales.Orders AS o
ON s.custid = o.custid
WHERE o.orderid IS NULL;
COMMIT;

-- Query 6: Retrieve orders made on '2016-02-12' with a left join
BEGIN TRANSACTION;
SELECT s.custid, s.companyname, o.orderid, o.orderdate
FROM Sales.Customers AS s
LEFT OUTER JOIN Sales.Orders AS o
ON s.custid = o.custid
WHERE o.orderdate = '2016-02-12';
COMMIT;

-- Query 7: Left join between Customers and Orders with a specific order date condition
BEGIN TRANSACTION;
SELECT C.custid, o.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
ON O.custid = C.custid AND O.orderdate = '20160212';
COMMIT;

-- Query 8: Retrieve customers with specific order date condition or no orders at all
BEGIN TRANSACTION;
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
ON O.custid = C.custid
WHERE O.orderdate = '20160212'
OR O.orderid IS NULL;
COMMIT;
