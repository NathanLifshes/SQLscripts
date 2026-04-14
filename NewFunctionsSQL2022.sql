
DECLARE @str NVARCHAR(100) = N'D6J,DE8,ZMN,OM3,XS3,I40,L2G,403ZMN,OM3,XS3,I40,L2G,403ZMN,OM3,XS3,I40,L2G,403,J70,AKE';
SELECT *
FROM STRING_SPLIT(@str, ',');

DECLARE @str NVARCHAR(100) = N'D6J,DE8,ZMN,OM3,XS3,I40,L2G,403ZMN,OM3,XS3,I40,L2G,403ZMN,OM3,XS3,I40,L2G,403,J70,AKE';
SELECT *
FROM STRING_SPLIT(@str, ',', 1);

/**/

SELECT * FROM GENERATE_SERIES(1,10,1)

SELECT * FROM GENERATE_SERIES(1,100,5)

SELECT * FROM GENERATE_SERIES(100,10,-9)

DECLARE @start decimal(2, 1) = 0.0;
DECLARE @stop decimal(2, 1) = 1.0;
DECLARE @step decimal(2, 1) = 0.1;
SELECT value
FROM GENERATE_SERIES(@start, @stop, @step);


SELECT * FROM GENERATE_SERIES(0, DATEDIFF(day, '2022-01-01', '2022-01-10'))

SELECT DATEADD(day, value, '2022-01-01') AS Date
FROM GENERATE_SERIES(0, DATEDIFF(day, '2022-01-01', '2022-01-10'));

;WITH DateRange AS (
    SELECT MIN(SaleDate) AS StartDate, MAX(SaleDate) AS EndDate
    FROM [Sales].[Orders]
)
SELECT
    DATEADD(MONTH, n.value, dr.StartDate) AS Month,
    ISNULL(SUM(s.Amount), 0) AS TotalSales
FROM
    DateRange dr
    CROSS APPLY GENERATE_SERIES(0, DATEDIFF(MONTH, dr.StartDate, dr.EndDate)) AS n
    LEFT JOIN Sales s ON s.SaleDate >= DATEADD(MONTH, n.value, dr.StartDate)
                       AND s.SaleDate < DATEADD(MONTH, n.value + 1, dr.StartDate)
GROUP BY
    DATEADD(MONTH, n.value, dr.StartDate)
ORDER BY
    Month;
/**/

SELECT DATETRUNC( year, CAST(GETDATE() AS DATE) ) AS startofyear;
SELECT DATETRUNC( year, GETDATE() ) AS startofyear;

SELECT DATETRUNC( week, CAST(GETDATE() AS DATE) ) AS startofyear;
SELECT DATETRUNC( week, GETDATE() ) AS startofyear;

DECLARE @d datetime2 = GETDATE()

SET DATEFIRST 7; -- Uses the default DATEFIRST setting value of 7 (U.S. English)
SELECT 'Week-7', DATETRUNC(week, @d); 

SET DATEFIRST 6;
SELECT 'Week-6', DATETRUNC(week, @d);

SET DATEFIRST 3;
SELECT 'Week-3', DATETRUNC(week, @d);

DECLARE @d DATETIME2 = GETDATE()
SELECT 'Year', DATETRUNC(YEAR, @d);
SELECT 'Quarter', DATETRUNC(QUARTER, @d);
SELECT 'Month', DATETRUNC(MONTH, @d);
SELECT 'Week', DATETRUNC(week, @d); -- Using the default DATEFIRST setting value of 7 (U.S. English)
SELECT 'Iso_week', DATETRUNC(iso_week, @d);
SELECT 'DayOfYear', DATETRUNC(dayofyear, @d);
SELECT 'Day', DATETRUNC(day, @d);
SELECT 'Hour', DATETRUNC(hour, @d);
SELECT 'Minute', DATETRUNC(minute, @d);
SELECT 'Second', DATETRUNC(second, @d);
SELECT 'Millisecond', DATETRUNC(millisecond, @d);
SELECT 'Microsecond', DATETRUNC(microsecond, @d);

/**/
SELECT DATE_BUCKET( year, 1, CAST('20220718' AS DATE) ) AS startofyear

DECLARE @date DATETIME2 = GETDATE();
SELECT  @date AS [Now],DATE_BUCKET(YEAR, 1, @date) AS [Start Of Year],DATE_BUCKET(QUARTER, 1, @date) AS [Start Of Quarter],DATE_BUCKET(MONTH, 1, @date) AS [Start Of Month], DATE_BUCKET(WEEK, 1, @date) AS [Start Of Week]

SELECT DATE_BUCKET( year, 1, CAST('20220718' AS DATE) ,CAST('20000202' AS DATE)) AS startofyear
SELECT DATE_BUCKET( year, 1, CAST('20220118' AS DATE) ,CAST('20000202' AS DATE)) AS startofyear

SELECT DATE_BUCKET( MONTH, 3, GETDATE())


/*
In summary, both functions are useful for time-based grouping, 
but DATE_BUCKET provides better optimization by allowing the optimizer to rely on index order
*/

/**/

SELECT GREATEST(1,2,3) AS TheGreatest,
	LEAST(1,2,3) AS TheLeastest;

SELECT *,DATEDIFF(MINUTE,X.LeastDate, X.GreatestDate) AS DiffInMin FROM (
SELECT TOP (100)
       ID,
       SendDate,
       CreatedDate,
	   ActualSendDate,
	   LEAST(SendDate,CreatedDate,ActualSendDate,NULL) LeastDate,
	   GREATEST(SendDate,CreatedDate,ActualSendDate) GreatestDate
FROM PayoneerIPCN.dbo.[payoneer_IPCNQueue]
WHERE ActualSendDate IS NOT NULL
ORDER BY CreatedDate DESC
) X --WHERE DATEDIFF(MINUTE,X.LeastDate, X.GreatestDate) > 10
ORDER BY DiffInMin DESC
