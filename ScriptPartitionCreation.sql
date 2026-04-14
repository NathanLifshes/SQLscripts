DECLARE @FinalPartitionScript NVARCHAR(MAX);
EXEC DBA.PartitionMaintenance.ScriptPartitionCreation @DatabaseName = 'CustomerManagement',                                -- sysname
                                                      @TableSchemaName = 'CUST',                             -- sysname
                                                      @TableName = 'OutboxMessages',                                   -- sysname
                                                      @PartitionUnitType = 'WEEK',                             -- varchar(6)
                                                      @numOfEmptyPartitions = 3,                           -- tinyint
                                                      @PartitionRetentionInUnits = 4,                      -- tinyint
                                                      @PartitionColumnName = 'ProcessedDate',                         -- sysname
                                                      @StartDate = '2024-01-28',                           -- date
                                                      @CreateEmptyPartitions = 1,                       -- bit
                                                      @PartitionUnitSize = 1,                              -- tinyint
                                                      @UseTruncate = 1,                                 -- bit
                                                      @ScriptMode = 1,                                     -- smallint
                                                      @FinalPartitionScript = @FinalPartitionScript OUTPUT -- nvarchar(max)
EXEC dbo.sp_LongPrint @String = N'@FinalPartitionScript' -- nvarchar(max)