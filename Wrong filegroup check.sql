DROP TABLE IF EXISTS #temptable 
CREATE TABLE #temptable ([DB_Name] VARCHAR(128), [SchemaName] NVARCHAR(128), [TableName] NVARCHAR(128), [IndexName] NVARCHAR(128), [Filegroup] NVARCHAR(128) )

EXEC sp_foreachdb
@command1 = 
'USE ?
INSERT INTO #temptable ([DB_Name], [SchemaName], [TableName], [IndexName], [Filegroup])
SELECT DISTINCT ''?'' AS DB_Name,
	s.name SchemaName, t.name TableName, i.name IndexName, f.name Filegroup
FROM sys.indexes i
JOIN sys.tables t
	ON t.object_id= i.object_id
JOIN sys.schemas s
	ON t.schema_id = s.schema_id
JOIN sys.filegroups f
     ON i.data_space_id = f.data_space_id
WHERE f.is_default <> 1
	AND s.schema_id > 4'
 
SELECT * FROM #temptable
ORDER BY 1,2,3,4,5
