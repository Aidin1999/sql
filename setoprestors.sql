-- Use the TSQLV4 database
USE TSQLV4;

-- Query 1: Retrieve the order details for the most recent order date
BEGIN TRANSACTION;
SELECT orderdate, orderid, custid, empid
FROM Sales.Orders AS o1
WHERE orderdate = (
    SELECT MAX(o2.orderdate) 
    FROM Sales.Orders AS o2
);
COMMIT;

-- Query 1-2: Retrieve order details for the customer with the highest number of orders
BEGIN TRANSACTION;
SELECT o1.custid, o1.orderdate, o1.orderid, o1.empid
FROM Sales.Orders AS o1
WHERE o1.custid = (
    SELECT TOP 1 o2.custid 
    FROM Sales.Orders AS o2   
    GROUP BY o2.custid 
    ORDER BY COUNT(o2.orderid) DESC
);
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

-- Query 3 (new): Retrieve customers and employees who placed orders in January 2016 but not in February 2016
BEGIN TRANSACTION;
SELECT custid, empid 
FROM Sales.Orders 
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 1

EXCEPT

SELECT custid, empid 
FROM Sales.Orders 
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 2

ORDER BY custid;
COMMIT;

-- Query 4 (new): Retrieve customers and employees who placed orders in both January 2016 and February 2016
BEGIN TRANSACTION;
SELECT custid, empid 
FROM Sales.Orders 
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 1

INTERSECT

SELECT custid, empid 
FROM Sales.Orders 
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 2

ORDER BY custid;
COMMIT;

-- Query 5 (new): Retrieve customers and employees who placed orders in both January 2016 and February 2016 but not in 2015
BEGIN TRANSACTION;
(SELECT custid, empid 
FROM Sales.Orders 
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 1

INTERSECT 

SELECT custid, empid 
FROM Sales.Orders 
WHERE YEAR(orderdate) = 2016 AND MONTH(orderdate) = 2)

EXCEPT

SELECT custid, empid 
FROM Sales.Orders 
WHERE YEAR(orderdate) = 2015;
COMMIT;

-- Query 6 (new): Retrieve country, region, and city from Employees and Suppliers
BEGIN TRANSACTION;
SELECT country, region, city
FROM HR.Employees

UNION ALL

SELECT country, region, city
FROM Production.Suppliers

ORDER BY country, region, city;
COMMIT;
