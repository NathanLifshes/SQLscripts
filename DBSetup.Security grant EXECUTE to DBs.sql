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
  AND      su.UserName        = 'sapuser'
  AND ss.ServerName LIKE 'prod%'
  AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004')
  --AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('Kentico_OM','Waves2010_DWH','Waves2010')
ORDER BY sdb.ServerID, su.DataBaseID
  
  

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
      , 6               -- PermissionID - int
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
WHERE      1=1
  AND      su.UserName        = 'sapuser'
  AND ss.ServerName LIKE 'prod%'
  AND sdb.DATABASE_NAME IN ('ClientsMgmt','VirtualStock','TT_VirtualStock','US_DBUtils','TT_Waves_Inc2004','Waves_Inc2004','Waves_Inc2019','TT_ClientsMgmt','Waves_Inc2019_NRT')
  --AND sdb.DATABASE_NAME IN ('Kentico_OM','Waves2010_DWH','Waves2010')
