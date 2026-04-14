---------------------------------------------------------------------
-- Workarounds for T-SQL Restrictions and Limitations
-- © Itzik Ben-Gan
-- For more, see 5-day Advanced T-SQL class: https://tsql.lucient.com
---------------------------------------------------------------------

-- Sample databases TSQLV5: https://tsql.lucient.com/SampleDatabases/TSQLV5.zip
-- Sample databases PerformanceV5: https://tsql.lucient.com/SampleDatabases/PerformanceV5.zip

---------------------------------------------------------------------
-- Computing minimum/maximum over columns
---------------------------------------------------------------------

-- Sample data
USE TSQLV5;

DROP TABLE IF EXISTS dbo.Sales;

SELECT custid, [2017] AS qty2017, [2018] AS qty2018, [2019] AS qty2019
INTO dbo.Sales
FROM (SELECT custid, YEAR(orderdate) AS orderyear, qty
      FROM Sales.OrderValues) AS D
  PIVOT(SUM(qty) FOR orderyear IN([2017],[2018],[2019])) AS P;

SELECT * FROM dbo.Sales;

-- Solution query
SELECT S.custid, S.qty2017, S.qty2018, S.qty2019, A.minqty, A.maxqty
FROM dbo.Sales AS S
  CROSS APPLY ( SELECT MIN(qty) AS minqty, MAX(qty) AS maxqty
                FROM ( VALUES(qty2017),
                             (qty2018),
                             (qty2019) ) AS D(qty) ) AS A;

---------------------------------------------------------------------
-- Computing row numbers with no particular order
---------------------------------------------------------------------

USE PerformanceV5;

SELECT orderid, empid, custid, orderdate, filler,
  ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
FROM dbo.Orders;
go

---------------------------------------------------------------------
-- Function that generates a series of numbers
---------------------------------------------------------------------

CREATE OR ALTER FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT)
  RETURNS TABLE
AS
RETURN
  WITH
    L0 AS (SELECT 0 AS c FROM (VALUES(0),(0)) as d(c)),
    L1 AS (SELECT 0 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2 AS (SELECT 0 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3 AS (SELECT 0 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4 AS (SELECT 0 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5 AS (SELECT 0 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
             FROM l5)
    SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
    FROM Nums
    ORDER BY rownum;
GO

-- Test function
SELECT n
FROM dbo.GetNums(1, 100);
GO

---------------------------------------------------------------------
-- Creating ordered views (please don’t)
---------------------------------------------------------------------

USE TSQLV5;
GO

-- Normally you're not allowed to create ordered views
CREATE OR ALTER VIEW dbo.MyView
AS

SELECT orderid, val
FROM Sales.OrderValues
ORDER BY val DESC;
GO

Msg 1033, Level 15, State 1, Procedure MyView, Line 6 [Batch Start Line 80]
The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.

-- An attempt to add TOP is futile since only ORDER BY in outer query really counts
CREATE OR ALTER VIEW dbo.MyView
AS

SELECT TOP (100) PERCENT orderid, val
FROM Sales.OrderValues
ORDER BY val DESC;
GO

SELECT * FROM dbo.MyView;

orderid     val
----------- ---------------------------------------
10248       440.00
10249       1863.40
10250       1552.60
10251       654.06
10252       3597.90
...

-- An attempt to use large number might seem to work, but still not guaranteed
CREATE OR ALTER VIEW dbo.MyView
AS

SELECT TOP (9223372036854775807) orderid, val
FROM Sales.OrderValues
ORDER BY val DESC;
GO

SELECT * FROM dbo.MyView;

orderid     val
----------- ---------------------------------------
10865       16387.50
10981       15810.00
11030       12615.05
10889       11380.00
10417       11188.40
...

-- Same goes for OFFSET 0 ROWS
CREATE OR ALTER VIEW dbo.MyView
AS

SELECT orderid, val
FROM Sales.OrderValues
ORDER BY val DESC
OFFSET 0 ROWS;
GO

SELECT * FROM dbo.MyView;

orderid     val
----------- ---------------------------------------
10865       16387.50
10981       15810.00
11030       12615.05
10889       11380.00
10417       11188.40
...

-- Note, can use TOP (9223372036854775807) to prevent unnesting
-- See details here: https://sqlperformance.com/2020/07/t-sql-queries/table-expressions-part-4

---------------------------------------------------------------------
-- Prevent unnesting of table expressions
---------------------------------------------------------------------

-- Top prevents unnesting
USE PerformanceV5;

WITH C1 AS
(
  SELECT TOP (9223372036854775807) *
  FROM dbo.Orders
  WHERE orderdate >= '20170101'
),
C2 AS
(
  SELECT TOP (9223372036854775807) *
  FROM C1
  WHERE orderdate >= '20180101'
)
SELECT *
FROM C2;

-- Example preventing errors
USE TSQLV5;

WITH C AS
(
  SELECT TOP (9223372036854775807) *
  FROM Sales.OrderDetails
  WHERE discount > (SELECT MIN(discount) FROM Sales.OrderDetails)
)
SELECT *
FROM C
WHERE 1.0 / discount > 10.0;

---------------------------------------------------------------------
-- Reusing column aliases
---------------------------------------------------------------------

USE TSQLV5;

SELECT orderid, orderyear
FROM Sales.Orders
  CROSS APPLY ( VALUES( YEAR(orderdate) ) ) AS A1(orderyear)
  CROSS APPLY ( VALUES( DATEFROMPARTS(orderyear, 12, 31) ) ) AS A2(endofyear)
WHERE orderdate = endofyear;