USE ToolDB
GO

SELECT     ss.ServerName
         , sdb.DATABASE_NAME
         , su.ID user_id, su.UserName
         , sup.PermissionID, sp.Permission, sup.Class
         , sup.Securable
FROM       DBSetup.Security_Server         ss
INNER JOIN DBSetup.Security_DataBase       sdb
   ON      sdb.ServerID  = ss.ID
INNER JOIN DBSetup.Security_User           su
   ON      su.DataBaseID = sdb.ID
INNER JOIN DBSetup.Security_UserPermission sup
   ON      sup.UserID    = su.ID
INNER JOIN DBSetup.Security_Permission sp
	ON sp.ID = sup.PermissionID
WHERE      1=1
  AND      su.UserName        = 'WAVES\SQL_BI_ADMIN'
  AND ss.ServerName LIKE 'prod%'
  AND sdb.DATABASE_NAME IN ('US_DBUtils')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_ClientsMgmt')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('WavesBI','WavesReports','BIWebConsole')
ORDER BY sdb.ServerID, su.DataBaseID
  
  
DECLARE @AllTables table (ServerName sysname, DatabaseName sysname, SchemaName sysname, TableName sysname)
INSERT INTO @AllTables 
    EXEC sp_msforeachdb 'select @@SERVERNAME,''?'',s.name,t.name from [?].sys.TABLE_TYPES t inner join sys.schemas s on t.schema_id=s.schema_id WHERE IS_USER_DEFINED = 1'
--SELECT * FROM @AllTables ORDER BY 1
SELECT 
'
INSERT INTO DBSetup.Security_UserPermission
(
    UserID
  , PermissionID
  , [Grant]
  , Securable
  , Class
)
VALUES ('+ CAST(su.ID AS VARCHAR) +'             -- UserID - int
      , 15               -- PermissionID - int
      , 1                -- Grant - bit
      , N''' + tt.TableName + ''' -- Securable - nvarchar(128)
      , N''TYPE''          -- Class - nvarchar(128)
    );
'
FROM       DBSetup.Security_Server         ss
INNER JOIN DBSetup.Security_DataBase       sdb
   ON      sdb.ServerID  = ss.ID
INNER JOIN DBSetup.Security_User           su
   ON      su.DataBaseID = sdb.ID
INNER JOIN @AllTables tt
	ON tt.DatabaseName = sdb.DATABASE_NAME
WHERE      1=1
  AND      su.UserName        = 'WAVES\SQL_BI_ADMIN'
  AND ss.ServerName LIKE 'prod%'
  AND sdb.DATABASE_NAME IN ('US_DBUtils')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_ClientsMgmt')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('WavesBI','WavesReports','BIWebConsole')


--DECLARE @AllTables table (ServerName sysname, DatabaseName sysname, SchemaName sysname, TableName sysname)
--INSERT INTO @AllTables 
--    EXEC sp_msforeachdb 'select @@SERVERNAME,''?'',s.name,t.name from [?].sys.TABLE_TYPES t inner join sys.schemas s on t.schema_id=s.schema_id WHERE IS_USER_DEFINED = 1'
----SELECT * FROM @AllTables ORDER BY 1

--SELECT     ss.ServerName
--         , sdb.DATABASE_NAME
--         , su.ID user_id, su.UserName
--		 , tt.TableName
--FROM       DBSetup.Security_Server         ss
--INNER JOIN DBSetup.Security_DataBase       sdb
--   ON      sdb.ServerID  = ss.ID
--INNER JOIN DBSetup.Security_User           su
--   ON      su.DataBaseID = sdb.ID
--INNER JOIN @AllTables tt
--	ON tt.DatabaseName = sdb.DATABASE_NAME
--WHERE      1=1
--  AND      su.UserName        = 'wavesdev'
--  AND ss.ServerName LIKE 'prod%'
--  AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')


