/*

Author: Eitan Blumin | https://eitanblumin.com | https://madeiradata.com
Description:
This is the simplest possible alternative to sp_MSforeachdb which is not too great.
Instructions:
1. Replace the contents of the @Command variable with the command you want to run INSIDE each database.
2. Replace the contents of the @Parameters variable with the parameters you want the command to receive.
3. Add parameters as needed, given @p1 as an example.
4. Change the database filter predicates in the cursor declaration, as needed.

Remarks:
- The command will be run within the context of each online database in the SQL Server instance.
- This version does NOT support the "?" replacer character.
- Instead, you can use DB_NAME() to get the name of the current database context.

*/

SET NOCOUNT, XACT_ABORT, ARITHABORT ON;

DECLARE @Command nvarchar(max) = N'PRINT DB_NAME() + N'': '' + @p1'
DECLARE @Parameters nvarchar(max) = N'@p1 nvarchar(100)'
DECLARE @p1 nvarchar(100) = N'I am @p1'

DECLARE @CurrDB sysname, @spExecuteSQL NVARCHAR(1000)

DECLARE DBs CURSOR
LOCAL FAST_FORWARD
FOR
SELECT [name]
FROM sys.databases WITH (NOLOCK)
WHERE state = 0 				/* online only */
AND HAS_DBACCESS([name]) = 1 			/* accessible only  */
AND database_id > 4 AND is_distributor = 0 	/* ignore system databases */
AND DATABASEPROPERTYEX([name], 'Updateability') = 'READ_WRITE' /* writeable only */

OPEN DBs

WHILE 1=1
BEGIN
	FETCH NEXT FROM DBs INTO @CurrDB;
	IF @@FETCH_STATUS <> 0 BREAK;

	SET @spExecuteSQL = QUOTENAME(@CurrDB) + N'..sp_executesql'

	EXEC @spExecuteSQL @Command, @Parameters, @p1 /* add or remove parameters here as needed */
		WITH RECOMPILE; -- use RECOMPILE to avoid storing in plan cache for each DB
END

CLOSE DBs;
DEALLOCATE DBs;