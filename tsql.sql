USE TSQLV4;
GO

-- Part 1: Create and Execute a Stored Procedure with a Loop
BEGIN TRANSACTION;

-- Drop the stored procedure if it exists
DROP PROCEDURE IF EXISTS Sales.aa;
GO

-- Create the stored procedure
CREATE PROCEDURE Sales.aa
AS
BEGIN
    -- Set NOCOUNT ON to prevent extra result sets from interfering with results
    SET NOCOUNT ON;

    DECLARE @n INT = 1;
    DECLARE @m INT = (SELECT MAX(custid) FROM Sales.Customers);

    -- Loop through each custid from 1 to the maximum custid
    WHILE @n <= @m 
    BEGIN 
        SELECT * FROM Sales.Customers WHERE custid = @n;
        SET @n = @n + 1;
    END
END;
GO

-- Execute the stored procedure
EXEC Sales.aa;

-- Drop the stored procedure after execution
DROP PROCEDURE IF EXISTS Sales.aa;
GO

-- Part 2: Data Validation and Error Handling with Triggers

-- Drop the table if it exists and recreate it with constraints
BEGIN TRANSACTION;

-- Drop the table if it exists
DROP TABLE IF EXISTS dbo.test;
GO

-- Create the table with a check constraint
CREATE TABLE dbo.test (
    orderid INT NOT NULL,
    orderdate DATETIME NOT NULL CHECK (YEAR(orderdate) < '2020')
);
GO

-- Insert data from Sales.Orders into dbo.test
INSERT INTO dbo.test (orderid, orderdate)
SELECT orderid, orderdate FROM Sales.Orders;

-- Drop the old table and create a new one for data checks
DROP TABLE IF EXISTS dbo.datacheck;
GO

-- Create a new table to store data checks
CREATE TABLE dbo.datacheck (
    name SYSNAME NOT NULL DEFAULT (ORIGINAL_LOGIN()),
    dt DATETIME NOT NULL DEFAULT (SYSDATETIME()),
    orderdate DATETIME NOT NULL
);
GO

-- Create a trigger to insert into dbo.datacheck after insert on dbo.test
CREATE TRIGGER checking
ON dbo.test
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.datacheck (orderdate)
    SELECT orderdate FROM inserted;
END;
GO

-- Try inserting a record with an invalid date to test the trigger and error handling
BEGIN TRY
    INSERT INTO dbo.test (orderid, orderdate) VALUES (10555, '2022-10-25');
    PRINT 'No error in first try';
END TRY
BEGIN CATCH
    PRINT 'Error in first try';
END CATCH;
GO

-- Try inserting a record with a valid date
BEGIN TRY
    INSERT INTO dbo.test (orderid, orderdate) VALUES (10555, '2018-10-25');
    PRINT 'No error in second try';
END TRY
BEGIN CATCH
    PRINT 'Error in second try';
END CATCH;
GO

-- Drop the trigger and tables after testing
DROP TRIGGER IF EXISTS checking;
DROP TABLE IF EXISTS dbo.test;
DROP TABLE IF EXISTS dbo.datacheck;
GO


