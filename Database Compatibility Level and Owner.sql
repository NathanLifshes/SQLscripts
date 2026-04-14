-- Recovery model, log reuse wait description, log file size, log usage size  (Query 30) (Database Properties)
-- and compatibility level for all databases on instance
SELECT db.[name] AS [Database Name], SUSER_SNAME(db.owner_sid) AS [Database Owner],
db.[compatibility_level] AS [DB Compatibility Level], 
db.recovery_model_desc AS [Recovery Model], 
db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0) AS [Log Size (MB)], CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS [Log Used (MB)],
CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
db.page_verify_option_desc AS [Page Verify Option], db.user_access_desc, db.state_desc, db.containment_desc,
db.is_mixed_page_allocation_on,  
db.is_auto_create_stats_on, db.is_auto_update_stats_on, db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on, db.is_auto_close_on, db.is_auto_shrink_on, 
db.target_recovery_time_in_seconds, db.is_cdc_enabled, db.is_published, db.is_distributor, db.is_sync_with_backup, 
db.group_database_id, db.replica_id, db.is_memory_optimized_elevate_to_snapshot_on, 
db.delayed_durability_desc, db.is_query_store_on, db.is_remote_data_archive_enabled, 
db.is_master_key_encrypted_by_server, db.is_encrypted, 
de.encryption_state, de.percent_complete, de.key_algorithm, de.key_length
FROM sys.databases AS db WITH (NOLOCK)
LEFT OUTER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
LEFT OUTER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
ON db.name = ls.instance_name
LEFT OUTER JOIN sys.dm_database_encryption_keys AS de WITH (NOLOCK)
ON db.database_id = de.database_id
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 

AND SUSER_SNAME(db.owner_sid) <> 'sa'
--AND db.name IN ('Waves2010','Waves2010_DWH','Kentico_OM','WavesReports','ClientsMgmt','VirtualStock','US_DBUtils')

ORDER BY [DB Compatibility Level] OPTION (RECOMPILE);

--USE [master]
--GO
---- SQL Server 2016
--ALTER DATABASE [ClientsMgmt] SET COMPATIBILITY_LEVEL = 130
--GO
--ALTER DATABASE [VirtualStock] SET COMPATIBILITY_LEVEL = 130
--GO
--ALTER DATABASE [US_DBUtils] SET COMPATIBILITY_LEVEL = 130
--GO
--ALTER DATABASE [ToolDB] SET COMPATIBILITY_LEVEL = 130
--GO


--use Waves2010; exec sp_changedbowner [sa];
--use Waves2010_DWH; exec sp_changedbowner [sa];
--use Kentico_OM; exec sp_changedbowner [sa];
--use DMCA; exec sp_changedbowner [sa];
--use InDB; exec sp_changedbowner [sa];
--use ToolDB; exec sp_changedbowner [sa];
--use TT_Waves_Inc2004; exec sp_changedbowner [sa];
--use TT_ClientsMgmt; exec sp_changedbowner [sa];
--use TT_VirtualStock; exec sp_changedbowner [sa];
--use [SLDModel.SLDData]; exec sp_changedbowner [sa];
--use MonitorDB; exec sp_changedbowner [sa];
--use Waves_Inc2019_NRT; exec sp_changedbowner [sa];
--use Waves_Inc2004; exec sp_changedbowner [sa];
--use [SBO-COMMON]; exec sp_changedbowner [sa];
--use [Kentico_OMv13]; exec sp_changedbowner [sa];

--use FreashDesk; exec sp_changedbowner [sa];
--use ToolDB; exec sp_changedbowner [sa];
--use MG_statistics; exec sp_changedbowner [sa];
--use Kentico_OM_His; exec sp_changedbowner [sa];
--use BIWebConsole; exec sp_changedbowner [sa];
--use WavesAudio08; exec sp_changedbowner [sa];
--use WavesReports; exec sp_changedbowner [sa];
--use WavesBI_Staging; exec sp_changedbowner [sa];
--use MonitorDB; exec sp_changedbowner [sa];
--use WavesBI; exec sp_changedbowner [sa];