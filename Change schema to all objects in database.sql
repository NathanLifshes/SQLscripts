
/* Change schema to all objects in database */

declare @NewSchemaName varchar(MAX) = db_name();
declare @SQL varchar(Max) = '
IF Not Exists (select 1 from sys.schemas where name ='''+@NewSchemaName+''')
		EXEC(''CREATE SCHEMA '+@NewSchemaName+''')'  + char(13);

SELECT @SQL += 'ALTER SCHEMA '+ @NewSchemaName +' TRANSFER [' + SysSchemas.Name + '].[' + DbObjects.Name + '];' + char(13)
FROM sys.Objects DbObjects
INNER JOIN sys.Schemas SysSchemas ON DbObjects.schema_id = SysSchemas.schema_id
WHERE SysSchemas.Name = 'dbo'
AND (DbObjects.Type IN ('U', 'P', 'V'))

--print @sql

exec (@SQL)
