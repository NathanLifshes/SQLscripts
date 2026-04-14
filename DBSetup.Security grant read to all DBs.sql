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
  AND      su.UserName        = 'WAVES\EternityDevelopers'
  AND ss.ServerName NOT LIKE 'prod%'
  AND ss.ServerName LIKE '%onlssqlao%'
  --AND  sdb.DATABASE_NAME IN ('Waves_Inc2019_NRT','Waves_Inc2019','ClientsMgmt','Waves2010','US_DBUtils','Kentico_OM')
  --AND sup.PermissionID = 1
  --AND sup.Class='OBJECT'
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
      , 1               -- PermissionID - int
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
  AND      su.UserName        = 'WAVES\EternityDevelopers'
  --AND  sdb.DATABASE_NAME IN ('Waves_Inc2019_NRT','Waves_Inc2019','ClientsMgmt','Waves2010','US_DBUtils','Kentico_OM')
  AND ss.ServerName NOT LIKE 'prod%'