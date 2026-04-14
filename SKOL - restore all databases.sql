set nocount on;

declare @Tsql nvarchar(max)='';


IF OBJECT_ID('tempdb..#restore_code') IS NOT NULL
    DROP TABLE #restore_code

create table #restore_code
(
[DB_name] nvarchar(128) not null,
file_path nvarchar(max) null,
move_file nvarchar(max) null
)


INSERT INTO  #restore_code
(
    DB_name
  , file_path
  , move_file
)
select dbs.name as [DB_name],
--@Tsql+=' 
'
restore database ' +dbs.name +' from  disk = ''G:\Imported_Prod_Backups\'+dbs.name+'.bak''  with ' as [file_path],
'move N'''+mf.name+'''  to N'''+mf.physical_name+'''' as move_file
from sys.master_files mf INNER JOIN 
sys.databases dbs on dbs.database_id=mf.database_id
where dbs.database_id>4
and dbs.name not in ('Waves_Inc2004','SBO-COMMON','SLDModel.SLDData','clear_trace','PerformanceV5','TSQLV5','WavesAudio08','ToolDB','VirtualStock','MG_statistics','WavesBI_Staging_BCM')



select @Tsql +=' 
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'''+dbs.name+''' '
from sys.databases dbs
where dbs.database_id>4
and dbs.name not in ('Waves_Inc2004','SBO-COMMON','SLDModel.SLDData','clear_trace','PerformanceV5','TSQLV5','WavesAudio08','ToolDB')

select @Tsql +=' 

'

select @Tsql +=' 
ALTER DATABASE '+dbs.name+' SET  restricted_user  WITH ROLLBACK IMMEDIATE'
from sys.databases dbs
where dbs.database_id>4
and dbs.name not in ('Waves_Inc2004','SBO-COMMON','SLDModel.SLDData','clear_trace','PerformanceV5','TSQLV5','WavesAudio08','ToolDB')

select @Tsql +=' 

'

select @Tsql +=' 
DROP DATABASE  '+dbs.name+' 
'
from sys.databases dbs
where dbs.database_id>4
and dbs.name not in ('Waves_Inc2004','SBO-COMMON','SLDModel.SLDData','clear_trace','PerformanceV5','TSQLV5','WavesAudio08','ToolDB')
select @Tsql +=' 

'


select @Tsql += 
      file_path + '
	  '+
     STUFF(
         (SELECT DISTINCT ',' + move_file
          FROM #restore_code
          WHERE file_path = a.file_path 
          FOR XML PATH (''))
          , 1, 1, '') 
		  from #restore_code AS a
GROUP BY file_path





--EXEC ToolDB.dbo.usp_PrintNvarcharMax @TSql

 exec(@Tsql);







RESTORE DATABASE [VirtualStock] FROM  DISK = N'G:\Imported_Prod_Backups\VirtualStock.Bak' WITH  FILE = 1,  
MOVE N'VirtualStock_Data' TO N'D:\SQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\VirtualStock_Data.mdf', 
 MOVE N'VirtualStock_Log' TO N'D:\SQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\VirtualStock_Log.ldf',  
 MOVE N'VirtualStock_Log2' TO N'D:\SQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\VirtualStock_Log2.ldf',  NOUNLOAD,  STATS = 5



USE [master]
RESTORE DATABASE [MG_statistics] FROM  DISK = N'G:\Imported_Prod_Backups\MG_statistics_20200610_23000.bak' WITH  FILE = 1,  MOVE N'MG_statistics' TO N'D:\SQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\MG_statistics.mdf',  MOVE N'MG_statistics_log' TO N'D:\SQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\MG_statistics_log.ldf',  NOUNLOAD,  STATS = 5

GO




