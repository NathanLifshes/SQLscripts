--2. All Columns:
DECLARE @command NVARCHAR(MAX), @LastDate DATETIME;

/*This is temporary - you can get the date as a parameter*/
SET @LastDate = GETDATE()-7

/*This will take only the last changed Tables */
DROP TABLE IF EXISTS #TableCursor;
SELECT  Database_Name,SchemaName, TableName = ObjectName, ObjectType, MAX(EventDate) AS EventDate
INTO #TableCursor
FROM    DBA.dbo.DDL_Audit
WHERE   ObjectType IN ('TABLE')
AND EventDate >= @LastDate
GROUP BY Database_Name,SchemaName, ObjectName, ObjectType
ORDER BY EventDate DESC


DECLARE @dbName sysname, @Schema sysname, @table sysname, @EventDate DATETIME = @LastDate;

WHILE (1=1)
BEGIN
	SELECT TOP (1) @dbName = Database_Name, @Schema = SchemaName, @table = TableName, @EventDate = EventDate
	FROM #TableCursor
	WHERE EventDate > @EventDate
	ORDER BY EventDate

	IF @@ROWCOUNT = 0
		BREAK;

SELECT @command = N'IF '''+@dbName+''' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'' , ''ZZZ_Applications_Clone'', ''ZZZ_DBA_Clone'', ''ZZZ_Harar_ExternalData_for_comparison'', ''ZZZ_Encryption_Clone'') BEGIN USE ['+@dbName+'] 
SELECT 
	db_id() as ''database_id'', 
    CONCAT(object_id(TABLE_CATALOG + ''.'' + TABLE_SCHEMA + ''.'' + TABLE_NAME), ''@'' , ORDINAL_POSITION) as ''object_id'', 
    object_id(TABLE_CATALOG + ''.'' + TABLE_SCHEMA + ''.'' + TABLE_NAME) as ''parent_object_id'', 
    * 
FROM INFORMATION_SCHEMA.COLUMNS ISC
WHERE TABLE_CATALOG = '''+@dbName+''' AND TABLE_SCHEMA = '''+@Schema+''' AND TABLE_NAME = '''+@table+'''
RETURN;
   END' 
--SELECT @command 
EXECUTE sys.sp_executesql @command

END
 