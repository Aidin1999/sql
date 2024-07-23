-- Set the transaction isolation level to REPEATABLE READ and execute a transaction
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Perform a select operation within the transaction
SELECT custid, companyname
FROM Sales.Customers;

-- Commit the transaction
COMMIT TRANSACTION;
GO

-- Set the transaction isolation level to READ UNCOMMITTED and execute a transaction
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Perform a select operation within the transaction
SELECT orderid, custid, orderdate
FROM Sales.Orders;

-- Commit the transaction
COMMIT TRANSACTION;
GO

-- Enable snapshot isolation for the database
ALTER DATABASE TSQLV4 SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

-- Set the transaction isolation level to SNAPSHOT and execute a transaction
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

-- Perform a select operation within the transaction
SELECT orderid, custid, orderdate
FROM Sales.Orders;

-- Commit the transaction
COMMIT TRANSACTION;
GO

-- New connection section
-- Change isolation level and database settings for the new connection
-- Note: The following commands should be executed in a new connection/session

-- Set the transaction isolation level to READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Disable snapshot isolation and read committed snapshot settings
ALTER DATABASE TSQLV4 SET ALLOW_SNAPSHOT_ISOLATION OFF;
ALTER DATABASE TSQLV4 SET READ_COMMITTED_SNAPSHOT OFF;
GO
