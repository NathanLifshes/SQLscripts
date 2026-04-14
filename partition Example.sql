--partition Example:
--Create a new table, partitioned by CreateDate column with daily PartitionUnitType
/**/

--Step 1: Create Partition function:
USE DBA
CREATE PARTITION FUNCTION [PF_DBA_PartitionTest_Daily](DATETIME2) AS RANGE RIGHT FOR VALUES (N'2022-04-05T00:00:00.000', N'2022-04-06T00:00:00.000')
/**/

--Step 2: Create Partition Scheme:
CREATE PARTITION SCHEME [PS_DBA_PartitionTest_Daily] AS PARTITION [PF_DBA_PartitionTest_Daily] ALL TO ([PRIMARY])

/**/

--Step 3: Create table DBA.PartitionTest

CREATE TABLE DBA.PartitionTest
(
ID INT IDENTITY(1,1) NOT NULL,
Col_Guid UNIQUEIDENTIFIER NULL,
Col_Str NVARCHAR(400) NOT NULL,
CreateDate DATETIME2 NOT NULL 
)

ALTER TABLE DBA.PartitionTest ADD CONSTRAINT [PK_PartitionTest_ID] PRIMARY KEY CLUSTERED (ID,CreateDate) ON [PS_DBA_PartitionTest_Daily](CreateDate)

CREATE UNIQUE NONCLUSTERED INDEX UIX_PartitionTest_Col_Str ON DBA.PartitionTest (Col_Str,CreateDate) INCLUDE(Col_Guid) WITH(ONLINE=ON) ON [PS_DBA_PartitionTest_Daily](CreateDate) 

CREATE NONCLUSTERED INDEX FIX_PartitionTest_Col_Col_Guid ON DBA.PartitionTest (Col_Guid,CreateDate) WHERE ID>10 WITH(ONLINE=ON) ON [PS_DBA_PartitionTest_Daily](CreateDate)

/**/

--Step 4: Insert Configuration

INSERT INTO dba.PartitionMaintenance.TableConfiguration(DatabaseName,PartitionSchemaName,TableName,PartitionUnitType,PartitionUnitSize,NumberOfEmptyPartitions,PartitionRetentionInUnits,CreateDate,TableSchemaName)
SELECT 'DBA','PS_DBA_PartitionTest_Daily','PartitionTest','day',1,10,2,GETDATE(),'DBA'
/**/

--Step 5: Run Job DBA-PartitionMaintenance-Add
--If the job failed, check the error in JobLog table:
SELECT TOP 10 * FROM DBA_Local.PartitionMaintenance.JobLog 
WHERE tablename='PartitionTest'
ORDER BY ID DESC
/**/

--Step 6: Get partition details
EXEC dba.PartitionMaintenance.GetTablePartitionDetails 
@DatabaseName = 'DBA',
       @TableSchemaName = 'DBA',    
       @PartitionSchemaName = 'PS_DBA_PartitionTest_Daily', 
       @TableName = 'PartitionTest'           
/**/
