DROP TABLE IF EXISTS #temp;
CREATE TABLE #temp
(
    DatabaseName sysname,
	SchemaName sysname,
    TableName sysname
);

EXEC sp_foreachdb @user_only = 1,
                  @command = '
							use ?
							insert into #temp
							SELECT distinct ''?'', s.name, t.name
							from sys.partitions p
							inner join sys.tables t
							on p.object_id = t.object_id
							INNER JOIN sys.schemas s
							ON s.schema_id = t.schema_id
							where p.partition_number <> 1
                              ';

WITH cte AS (
SELECT SUBSTRING(t.DatabaseName, 2, LEN(t.DatabaseName) - 2) DatabaseName,
	t.SchemaName,
    t.TableName
FROM #temp t
), cte2 AS 
(
	SELECT DatabaseName, TableSchemaName, TableName, PartitionSchemaName FROM DBA.PartitionMaintenance.TableConfiguration
	UNION 
	SELECT DatabaseName, TableSchemaName, TableName, PartitionSchemaName FROM DBA_B.PartitionMaintenance.TableConfiguration
)
SELECT * FROM cte t
FULL OUTER JOIN cte2 C
ON C.DatabaseName = t.DatabaseName AND C.TableName = t.TableName
WHERE C.PartitionSchemaName IS NULL

