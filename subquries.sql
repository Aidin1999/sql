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

-- Query 3: Retrieve employees who have not handled any orders after May 1, 2016
BEGIN TRANSACTION;
SELECT e.empid, e.FirstName, e.lastname 
FROM HR.Employees AS e 
WHERE e.empid NOT IN (
    SELECT o.empid 
    FROM Sales.Orders AS o
    WHERE o.orderdate > '20160501'
);
COMMIT;

-- Query 4: Retrieve countries where orders have been shipped but no employees are from
BEGIN TRANSACTION;
SELECT DISTINCT o.shipcountry
FROM Sales.Orders AS o
WHERE o.shipcountry NOT IN (
    SELECT e.country 
    FROM HR.Employees AS e
);
COMMIT;

-- Query 5: Retrieve the most recent order details for each customer and order by customer ID
BEGIN TRANSACTION;
SELECT o1.custid, o1.orderid, o1.orderdate, o1.empid
FROM Sales.Orders AS o1
WHERE o1.orderdate IN (
    SELECT MAX(o2.orderdate) 
    FROM Sales.Orders AS o2 
    WHERE o2.custid = o1.custid
)
ORDER BY custid;
COMMIT;

-- Query 6: Retrieve customers who placed orders in 2015 but not in 2016
BEGIN TRANSACTION;
SELECT c.custid, c.companyname 
FROM Sales.Customers AS c 
WHERE c.custid IN (
    SELECT o1.custid 
    FROM Sales.Orders AS o1
    WHERE YEAR(orderdate) = 2015 
    AND o1.custid NOT IN (
        SELECT o2.custid 
        FROM Sales.Orders AS o2
        WHERE YEAR(o2.orderdate) = 2016
    )
);
COMMIT;

-- Query 7: Retrieve customers who ordered product with ID 12 and order by customer ID
BEGIN TRANSACTION;
SELECT c.custid, c.companyname 
FROM Sales.Customers AS c 
WHERE c.custid IN (
    SELECT o1.custid 
    FROM Sales.Orders AS o1
    WHERE o1.orderid IN (
        SELECT od.orderid
        FROM Sales.OrderDetails AS od
        WHERE productid = 12
    )
)
ORDER BY custid;
COMMIT;

-- Query 8: Calculate the day difference between consecutive orders for each customer
BEGIN TRANSACTION;
SELECT o1.custid, o1.orderid, o1.orderdate, o1.empid,
DATEDIFF(day, (
    SELECT MAX(o2.orderdate) 
    FROM Sales.Orders AS o2 
    WHERE o2.custid = o1.custid 
    AND o2.orderdate < o1.orderdate
), o1.orderdate) AS diff
FROM Sales.Orders AS o1
ORDER BY o1.custid, orderid;
COMMIT;


