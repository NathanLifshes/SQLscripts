USE DBA
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
/*
	EXEC dbo.usp_FindAllServerObject @PartObjectName = N'WSP_CPN_RedeemCoupon_Before_Price', -- nvarchar(128)
                                 @PrintOnly = 1,     -- bit OR = 0
                                 @DataBase_Name = N'ClientsMgmt'  OR 'ALL' -- nvarchar(128)

*/
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_FindAllServerObject] 
(
 @PartObjectName NVARCHAR(128),
 @PrintOnly BIT =0,
 @DataBase_Name NVARCHAR(128)= N'ALL'
 )
AS 
begin




SET NOCOUNT ON ;


DECLARE @Tsql_Script NVARCHAR(max)='';

SELECT @Tsql_Script +=' ;with cte as (
 SELECT ''MSDB'' as [Database name], Job.name  COLLATE SQL_Latin1_General_CP1_CI_AS   AS [Object_Name],''JOB'' as [TYPE],
       JobStep.step_name COLLATE SQL_Latin1_General_CP1_CI_AS AS Inner_Object_Name,
      JobStep.command COLLATE SQL_Latin1_General_CP1_CI_AS AS Command
 FROM   msdb.dbo.sysjobs Job
       INNER JOIN msdb.dbo.sysjobsteps JobStep
               ON Job.job_id = JobStep.job_id 
WHERE  JobStep.command LIKE ''%'+@PartObjectName+'%''	'

IF OBJECT_ID('tempdb..#db_names') IS NOT NULL
    DROP TABLE #db_names



if @DataBase_Name!='ALL'
begin
SELECT r.value('.','VARCHAR(MAX)') as name
into #db_names
        FROM (SELECT CONVERT(XML, N'<root><r>' + REPLACE(REPLACE(REPLACE(@DataBase_Name,'& ','&amp; '),'<','&lt;'), ',', '</r><r>') + '</r></root>') as valxml) x
        CROSS APPLY x.valxml.nodes('//root/r') AS RECORDS(r)




SELECT @Tsql_Script+='  
UNION ALL
SELECT '''+dbs.name+''' as [Database name],o.name as [Object Name],
CASE WHEN o.type=''P''  THEN  '' Store Procedure  ''  
	 WHEN o.type=''S''  THEN   ''System Object  '' 
	 WHEN o.type=''D''  THEN   '' DEFAULT_CONSTRAINT  '' 
	 WHEN o.type=''PK'' THEN ''  PRIMARY_KEY_CONSTRAINT  '' 
	 WHEN o.type=''U'' THEN  '' USER_TABLE - ''
	 WHEN o.type=''TF'' THEN  '' SQL_TABLE_VALUED_FUNCTION '' 
	 WHEN o.type=''FN''  THEN ''  SQL_SCALAR_FUNCTION '' 
	 WHEN o.type=''V''  THEN  '' VIEW ''
 	 WHEN o.type=''D''  THEN  '' DEFAULT_CONSTRAINT  '' 
	 ELSE ''reference db object do not exist''
	 END AS [TYPE],
	   NULL AS Inner_Object_Name,
       sm.definition AS Command
       FROM ['+dbs.name+'].sys.sql_modules sm
	   INNER JOIN ['+dbs.name+'].sys.objects o  
	   ON o.object_id = sm.object_id
WHERE sm.definition LIKE ''%'+@PartObjectName+'%'' OR o.name LIKE ''%'+@PartObjectName+'%''
'
FROM sys.databases dbs
where  dbs.name in (SELECT	name from #db_names)


end

else

BEGIN
    
SELECT @Tsql_Script+='  

UNION ALL
SELECT '''+dbs.name+''' as [Database name],o.name as [Object Name],
CASE WHEN o.type=''P''  THEN  '' Store Procedure  ''  
	 WHEN o.type=''S''  THEN   ''System Object  '' 
	 WHEN o.type=''D''  THEN   '' DEFAULT_CONSTRAINT  '' 
	 WHEN o.type=''PK'' THEN ''  PRIMARY_KEY_CONSTRAINT  '' 
	 WHEN o.type=''U'' THEN  '' USER_TABLE - ''
	 WHEN o.type=''TF'' THEN  '' SQL_TABLE_VALUED_FUNCTION '' 
	 WHEN o.type=''FN''  THEN ''  SQL_SCALAR_FUNCTION '' 
	 WHEN o.type=''V''  THEN  '' VIEW ''
 	 WHEN o.type=''D''  THEN  '' DEFAULT_CONSTRAINT  '' 
	 ELSE ''reference db object do not exist''
	 END AS [TYPE],
	   NULL AS Inner_Object_Name,
       sm.definition AS Command
       FROM ['+dbs.name+'].sys.sql_modules sm
	   INNER JOIN ['+dbs.name+'].sys.objects o  
	   ON o.object_id = sm.object_id
WHERE sm.definition LIKE ''%'+@PartObjectName+'%'' OR o.name LIKE ''%'+@PartObjectName+'%''
'
FROM sys.databases dbs
WHERE dbs.state_desc='ONLINE' AND dbs.name = IIF(@DataBase_Name='ALL',dbs.name ,@DataBase_Name)



END

select @Tsql_Script+=') 
select * from cte	ORDER BY Object_Name	'


IF @PrintOnly = 1
EXEC DBA.dbo.usp_PrintNvarcharMax @Tsql_Script 
ELSE 
EXECUTE (@Tsql_Script)

 END ;
GO

