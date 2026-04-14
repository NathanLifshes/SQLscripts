USE [master]
RESTORE DATABASE [Kentico_OM] 
	FROM  URL = N'https://prodonlssqlaostrg.blob.core.windows.net/migration-db/19-07-2021-04-44-43/Kentico_OM_20210718_19000.bak' 
		WITH  FILE = 1,  
		MOVE N'Kentico_OM' TO N'N:\SQLData\Kentico_OM.mdf',  
		MOVE N'Kentico_OM_log' TO N'I:\SQLLog\Kentico_OM_log.ldf',  
		NORECOVERY,  
		NOUNLOAD,  
		STATS = 10

GO
