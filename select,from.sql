-- Query 1: Retrieve orders from June 2015 and order by the order date
BEGIN TRANSACTION;
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE MONTH(orderdate) = 6 AND YEAR(orderdate) = 2015
ORDER BY orderdate;
COMMIT;

-- Query 2: Retrieve orders that were made on the last day of any month and order by the order date
BEGIN TRANSACTION;
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate)
ORDER BY orderdate;
COMMIT;

-- Query 3: Retrieve employees whose last names contain two or three 'e's and order by employee ID
BEGIN TRANSACTION;
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE '%e%e%' OR lastname LIKE '%e%e%e%'
ORDER BY empid;
COMMIT;

-- Query 4: Calculate total value of each order and select orders with total value greater than 10,000, ordered by total value
BEGIN TRANSACTION;
SELECT orderid, SUM(qty * unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty * unitprice) > 10000
ORDER BY totalvalue DESC;
COMMIT;

-- Query 5: Retrieve employee IDs and last names where the last name starts with any letter from a to z
BEGIN TRANSACTION;
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE '[a-z]%';
COMMIT;

-- Query 6
-- First part: Count number of orders each employee handled before May 1, 2016
BEGIN TRANSACTION;
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;
COMMIT;

-- Second part: Count number of orders each employee handled but only include employees whose latest order was before May 1, 2016
BEGIN TRANSACTION;
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';
COMMIT;

-- Query 7: Calculate average freight cost per shipment for each country in 2015 and return top 3 countries with highest average freight cost
BEGIN TRANSACTION;
SELECT TOP 3 SUM(freight) / COUNT(shipcountry) AS avgfreight, shipcountry, COUNT(shipcountry) AS countofships
FROM Sales.Orders
WHERE YEAR(shippeddate) = 2015
GROUP BY shipcountry
ORDER BY avgfreight DESC;
COMMIT;

-- Query 8: Determine gender based on title of courtesy for each employee and order by employee ID
BEGIN TRANSACTION;
SELECT empid, firstname, lastname, titleofcourtesy,
CASE titleofcourtesy
  WHEN 'Ms.' THEN 'Female'
  WHEN 'Mrs.' THEN 'Female'
  WHEN 'Mr.' THEN 'Male'
  ELSE 'Unknown'
END AS gender
FROM HR.Employees
ORDER BY empid;
COMMIT;

-- Query 9: Select distinct customer IDs and regions, ordered by region in descending order and customer ID
BEGIN TRANSACTION;
SELECT DISTINCT custid, region
FROM Sales.Customers
ORDER BY region DESC, custid;
COMMIT;
