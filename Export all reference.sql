--3. All References:
DECLARE @command NVARCHAR(MAX), @LastDate DATETIME;

/*This is temporary - you can get the date as a parameter*/
SET @LastDate = GETDATE()-7

/*This will take only the last changed Tables */
DROP TABLE IF EXISTS #TableCursor;
SELECT  Database_Name,SchemaName, ObjectName, ObjectType, MAX(EventDate) AS EventDate
INTO #TableCursor
FROM    DBA.dbo.DDL_Audit
WHERE   ObjectType IN ('VIEW','COLUMN','PROCEDURE','INDEX','FUNCTION','TABLE','TYPE')
AND EventDate >= @LastDate
GROUP BY Database_Name,SchemaName, ObjectName, ObjectType
ORDER BY EventDate DESC

DECLARE @dbName sysname, @Schema sysname, @object sysname, @EventDate DATETIME = @LastDate;

WHILE (1=1)
BEGIN
	SELECT TOP (1) @dbName = Database_Name, @Schema = SchemaName, @object = ObjectName, @EventDate = EventDate
	FROM #TableCursor
	WHERE EventDate > @EventDate
	ORDER BY EventDate

	IF @@ROWCOUNT = 0
		BREAK;

SELECT @command = N'IF '''+@dbName+''' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'' , ''ZZZ_Applications_Clone'', ''ZZZ_DBA_Clone'', ''ZZZ_Harar_ExternalData_for_comparison'', ''ZZZ_Encryption_Clone'') BEGIN USE ['+@dbName+'] 
SELECT 
	--TOP 1000 
	db_name() as ''database_name''
	,replace(CONCAT(lower(reference.referenced_database_name) , ''#'' , CAST(reference.referenced_id AS VARCHAR(100)) , ''@'' , reference.referenced_minor_id), ''@0'' , '''') as ''target_fqid''
	, OBJECT_SCHEMA_NAME(obj.id) AS ''schema''
	, obj.NAME as ''object_name''
	, reference.*
	, obj.*
FROM 
	sysobjects obj
	CROSS APPLY sys.dm_sql_referenced_entities(OBJECT_SCHEMA_NAME(obj.id)+''.''+obj.name, ''OBJECT'') reference
WHERE obj.name = '''+@object+''' AND OBJECT_SCHEMA_NAME(obj.id) = '''+@Schema+'''
RETURN;
   END' 
--SELECT @command 
EXECUTE sys.sp_executesql @command

END
