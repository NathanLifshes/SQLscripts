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
 AND      su.UserName IN ('KenticoDB')
  --AND ss.ServerName NOT LIKE 'prod%'
  AND sdb.DATABASE_NAME IN ('toolDB')
  --AND sdb.DATABASE_NAME IN ('TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_ClientsMgmt')
  --AND sdb.DATABASE_NAME IN ('WavesBI','WavesReports','BIWebConsole')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','WavesBI','WavesReports','BIWebConsole')
  --AND sdb.DATABASE_NAME IN ('Waves2010','Kentico_OM')
ORDER BY sdb.ServerID, su.DataBaseID
 
 /**/ 

;WITH cte_Permissions AS 
(
	--SELECT * FROM DBSetup.Security_Permission WHERE id IN (1,2,3,4,5,6)
	--SELECT * FROM DBSetup.Security_Permission WHERE id IN (2,3,6)
	SELECT * FROM DBSetup.Security_Permission WHERE id IN (2,3)
	--SELECT * FROM DBSetup.Security_Permission WHERE id IN (5)
	--SELECT * FROM DBSetup.Security_Permission WHERE id IN (15)
)
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
      , '+ CAST(cte.ID AS VARCHAR) +'               -- PermissionID - int
      , 1                -- Grant - bit
      , N''' + sdb.DATABASE_NAME + ''' -- Securable - nvarchar(128)
      , N''DATABASE''          -- Class - nvarchar(128)
    );
'
FROM       DBSetup.Security_Server         ss
INNER JOIN DBSetup.Security_DataBase       sdb
   ON      sdb.ServerID  = ss.ID
INNER JOIN DBSetup.Security_User           su
   ON      su.DataBaseID = sdb.ID
CROSS JOIN cte_Permissions AS cte
WHERE      1=1
  AND      su.UserName IN ('KenticoDB')
  --AND ss.ServerName NOT LIKE 'prod%'
  AND sdb.DATABASE_NAME IN ('ToolDB')
  --AND sdb.DATABASE_NAME IN ('TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_ClientsMgmt')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','WavesBI','WavesReports','BIWebConsole')
  --AND sdb.DATABASE_NAME IN ('WavesBI','WavesReports','BIWebConsole')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','US_DBUtils')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('Waves2010','Kentico_OM')

