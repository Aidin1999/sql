-- Use the TSQLV4 database
USE TSQLV4;

-- 1-1: Drop and recreate the dbo.Customers table, and insert a single record
BEGIN TRANSACTION;
DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid      INT          NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country     NVARCHAR(15) NOT NULL,
  region      NVARCHAR(15) NULL,
  city        NVARCHAR(15) NOT NULL  
);

INSERT INTO dbo.Customers VALUES (100, 'Coho Winery', 'USA', 'WA', 'Redmond');
COMMIT;

-- 1-2: Drop and recreate the dbo.Customers table, and insert records from Sales.Customers that have corresponding orders
BEGIN TRANSACTION;
DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid      INT          NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country     NVARCHAR(15) NOT NULL,
  region      NVARCHAR(15) NULL,
  city        NVARCHAR(15) NOT NULL  
);

INSERT INTO dbo.Customers  
SELECT custid, companyname, country, region, city 
FROM Sales.Customers
WHERE EXISTS (
    SELECT DISTINCT custid 
    FROM Sales.Orders 
    WHERE Sales.Orders.custid = Sales.Customers.custid
);
COMMIT;

-- 1-3: Drop the dbo.orders table if it exists, and create it from Sales.Orders for orders between 2014 and 2016
BEGIN TRANSACTION;
DROP TABLE IF EXISTS dbo.orders;

SELECT *
INTO dbo.orders
FROM Sales.Orders 
WHERE YEAR(orderdate) > 2013 AND YEAR(orderdate) < 2017;
COMMIT;

-- q2: Delete orders from 2014 before August and output the deleted rows' custid and orderdate
BEGIN TRANSACTION;
DELETE FROM dbo.orders 
OUTPUT deleted.custid, deleted.orderdate
WHERE YEAR(orderdate) = 2014 AND MONTH(orderdate) < 8;
COMMIT;

-- q3: Delete orders shipped to Brazil
BEGIN TRANSACTION;
DELETE FROM dbo.orders 
WHERE shipcountry = 'Brazil';
COMMIT;

-- q4: Update orders with null shipregion to 'none' and output the old and new shipregion values into dbo.orderhistory
BEGIN TRANSACTION;
UPDATE dbo.orders 
SET shipregion = 'none' 
OUTPUT 
    deleted.shipregion AS oldregion,
    inserted.shipregion AS newregion,
    inserted.custid,
    inserted.shipregion AS nregion,
    deleted.shipregion AS oregion
INTO dbo.orderhistory (custid, nregion, oregion)
WHERE shipregion IS NULL;
COMMIT;
