SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DBA].[DENYDDLTriggerDisable]
	@ExecuteMode INT = 0
	,@Verbose INT = 0
AS
BEGIN

	SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY LOW;

	DECLARE @Command NVARCHAR(MAX) = NULL

	DROP TABLE IF EXISTS #AllDenyALTGForAllRolesInAllDBs
	CREATE TABLE #AllDenyALTGForAllRolesInAllDBs (Command NVARCHAR(MAX))

	INSERT INTO #AllDenyALTGForAllRolesInAllDBs
	EXEC sys.sp_MSforeachdb
	'
	USE ?
	SELECT ''USE [?] DENY ALTER ANY DATABASE DDL TRIGGER TO public'' AS Command 
	 FROM
	(
	SELECT u.name FROM sys.database_principals AS u WHERE u.type = ''R'' AND NAME = ''public''
	) AS AllDBRoles
	LEFT JOIN 
	(
	SELECT  ''?'' AS DBName, u.name
	FROM sys.database_permissions AS rm
		INNER JOIN
		sys.database_principals AS u
		ON rm.grantee_principal_id = u.principal_id
	WHERE rm.major_id = 0 AND rm.state = ''D'' AND rm.type = ''ALTG'' AND U.type = ''R''
	) AS AllDENYALTGForAllRoles
	ON AllDBRoles.name = AllDENYALTGForAllRoles.name
	WHERE
	AllDENYALTGForAllRoles.name IS NULL
	'
	
	SELECT  @Command = ( SELECT CHAR(13) + CHAR(10) + Command   -- Insert all the above actions into a parameter in order to exec them. CHAR(13) + CHAR(10) : linebreak
								FROM   #AllDENYALTGForAllRolesInAllDBs
		FOR     XML PATH('')
					,TYPE
								).value('.', 'NVARCHAR(MAX)');

	IF @Verbose = 1 AND @Command IS NOT NULL
		EXEC sp_LongPrint @Command
	ELSE
		PRINT 'No Roles Needed To Deny'

	IF @ExecuteMode = 1 AND @Command IS NOT NULL
	BEGIN
		EXEC (@Command)
		
		INSERT INTO [DBA].[DBA].[DENYDDLTriggerDisableLog] 
		SELECT Command, GETDATE() AS RunTime FROM #AllDenyALTGForAllRolesInAllDBs
	END
END
GO
