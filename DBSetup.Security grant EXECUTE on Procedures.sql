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
  --AND sdb.DATABASE_NAME IN ('Waves2010')
  AND sdb.DATABASE_NAME IN ('ToolDB')
ORDER BY sdb.ServerID, su.DataBaseID
  

--DECLARE @allObjects TABLE (ObjectName NVARCHAR(1000))
--INSERT INTO @allObjects
--VALUES	 ('aw_acc_GetClientBy')
--		,('aw_OMC_Insert')
--		,('aw_acc_GetEmailByITDevID')
--		,('aw_UPG_GetGUIDProductsByUserNameAndEmail')
--		,('aw_UPG_GetGUIDProductsByGUID')
--		,('aw_UPG_StaticUpgrades')
--		,('aw_PDL_VerifyOffer')
--		,('aw_WUP_GetGUIDProductsByGUID')
--		,('aw_WUP_GetGUIDProductsByUserNameAndEmail')

DECLARE @allObjects TABLE (ObjectName NVARCHAR(1000))
INSERT INTO @allObjects
VALUES	 ('WSP_PDL_GetUserProductBreakdown')
		,('WSP_PDL_GetCrossSellSources')


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
      , N''' + ObjectName + ''' -- Securable - nvarchar(128)
      , N''OBJECT''          -- Class - nvarchar(128)
    );
'
FROM       DBSetup.Security_Server         ss
INNER JOIN DBSetup.Security_DataBase       sdb
   ON      sdb.ServerID  = ss.ID
INNER JOIN DBSetup.Security_User           su
   ON      su.DataBaseID = sdb.ID
CROSS JOIN @allObjects
WHERE      1=1
  AND      su.UserName        = 'WAVES\SQL_BI_ADMIN'
  AND ss.ServerName LIKE 'prod%'
  --AND sdb.DATABASE_NAME IN ('Waves2010')
  AND sdb.DATABASE_NAME IN ('ToolDB')