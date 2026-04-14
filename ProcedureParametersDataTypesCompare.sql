ALTER PROCEDURE [dbo].[ProcedureParametersDataTypesCompare]
AS
-- Author:       Dudu Arviv
-- Create date:  2019-12-15
-- Description:  This procedure is used to send an email containing information about procedures that were change or created since the last time the job DBA - Data Types Compare ran that has 
--				 parameters with data types that are not aligned to our instructions in the wiki page.
--				 https://dev.azure.com/Payoneer/Payoneer/_wiki/wikis/Payoneer.wiki/528/DB-Review?anchor=data-types
-- ==============================================================
BEGIN
	SET NOCOUNT ON


	DROP TABLE IF EXISTS #ColumnsDiffrencesSinceLastRun
	DROP TABLE IF EXISTS #TablesLastDateChange
	DROP TABLE IF EXISTS #ProcedureParametersDataTypesToBeAligned
	DROP TABLE IF EXISTS #ProcedureParametersDataTypesToBeAlignedUsers


	CREATE TABLE #ProcedureParametersDataTypesToBeAligned (ParameterName NVARCHAR(100), CurrentDataType NVARCHAR(100), sholdBeDataType NVARCHAR(100), DBName NVARCHAR(100), SchemaName NVARCHAR(100), ProcedureName NVARCHAR(100))


	DECLARE @LastExecution DATETIME =
	(
	SELECT
		ISNULL(MAX(MSDB.dbo.agent_datetime(run_date,run_time)), DATEADD(MINUTE, -10, GETDATE()))
	From
		msdb.dbo.sysjobs j 
		INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
	where
		j.name = 'DBA - Data Types Compare'
		AND H.run_status = 1
		AND h.step_id = 0
	)


	SELECT
		Database_Name
		,SchemaName
		,ObjectName
		,MAX(EventDate) AS MaxEventDate
		INTO #TablesLastDateChange
	FROM
		DBA.dbo.DDL_Audit
	WHERE
		EventDate > @LastExecution
		AND ObjectType = 'PROCEDURE'
		AND Event_Type IN ('ALTER_PROCEDURE','CREATE_PROCEDURE')
	GROUP BY
		Database_Name
		,SchemaName
		,ObjectName


	DECLARE @Command NVARCHAR(MAX) = ''

	
	SELECT
	@Command = @Command +
	'
	USE ' + name + '
	INSERT INTO #ProcedureParametersDataTypesToBeAligned
	select
	   P.PARAMETER_NAME,
	   UPPER(REPLACE(P.DATA_TYPE + CASE WHEN P.CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN ''('' + CONVERT(NVARCHAR(10),P.CHARACTER_MAXIMUM_LENGTH) + '')'' ELSE '''' END, ''-1'', ''MAX'')) AS CurrentDataType,
	   CASE WHEN P.PARAMETER_NAME LIKE N''@CardholderId'' THEN ''VARCHAR(50)''
		WHEN P.PARAMETER_NAME LIKE N''@PartnerId'' THEN ''INT''
		WHEN P.PARAMETER_NAME LIKE N''@DebitCardId'' THEN ''VARCHAR(50)''
		WHEN P.PARAMETER_NAME LIKE N''@iACHId'' THEN ''VARCHAR(50)''
		WHEN P.PARAMETER_NAME LIKE N''@PaymentId'' THEN ''VARCHAR(50) / NVARCHAR(50)''
		WHEN P.PARAMETER_NAME LIKE N''@LoadId'' OR P.PARAMETER_NAME LIKE N''@TransactionId'' THEN ''VARCHAR(50) / NVARCHAR(50)''
		WHEN P.PARAMETER_NAME LIKE N''@Currency'' THEN ''VARCHAR(6)''
		WHEN P.PARAMETER_NAME LIKE N''@Country'' THEN ''NVARCHAR(50)''
		END AS ShouldBeDataType,
		''' + name + ''',
		P.SPECIFIC_SCHEMA,
		P.SPECIFIC_NAME
	  from INFORMATION_SCHEMA.PARAMETERS AS P-- INNER JOIN SYS.OBJECTS AS O ON P.OBJECT_ID = O.OBJECT_ID
	  WHERE
		((P.PARAMETER_NAME LIKE N''@CardholderId'' AND (P.DATA_TYPE <> ''varchar'' OR P.CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (P.PARAMETER_NAME LIKE N''@PartnerId'' AND (P.DATA_TYPE <> ''int''))
		OR (P.PARAMETER_NAME LIKE N''@DebitCardId'' AND (P.DATA_TYPE <> ''varchar'' OR P.CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (P.PARAMETER_NAME LIKE N''@iACHId'' AND (P.DATA_TYPE <> ''varchar'' OR P.CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (P.PARAMETER_NAME LIKE N''@PaymentId'' AND (P.CHARACTER_MAXIMUM_LENGTH <> 50))
		OR ((P.PARAMETER_NAME LIKE N''@LoadId'' OR P.PARAMETER_NAME LIKE N''@TransactionId'') AND (P.CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (P.PARAMETER_NAME LIKE N''@Currency'' AND (P.DATA_TYPE <> ''varchar'' OR P.CHARACTER_MAXIMUM_LENGTH <> 6))
		OR (P.PARAMETER_NAME LIKE N''@Country'' AND (P.DATA_TYPE <> ''nvarchar'' OR P.CHARACTER_MAXIMUM_LENGTH <> 50)))
		AND P.SPECIFIC_NAME COLLATE SQL_Latin1_General_CP1_CI_AS IN (SELECT ObjectName FROM #TablesLastDateChange WHERE Database_Name = ''' + name + ''')
	'
	FROM
		SYS.databases
	WHERE
		NAME IN (SELECT DISTINCT Database_Name FROM #TablesLastDateChange)
	ORDER BY
		NAME


	EXEC (@Command)


	SELECT
		ROW_NUMBER() OVER (ORDER BY Users.SystemUser) AS RN
		,Users.SystemUser
		INTO #ProcedureParametersDataTypesToBeAlignedUsers
	FROM
	(
		SELECT DISTINCT 
			DDL.SystemUser
		FROM
			#ProcedureParametersDataTypesToBeAligned AS TCDTTBA INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCDTTBA.DBName AND LDC.SchemaName = TCDTTBA.SchemaName AND LDC.ObjectName = TCDTTBA.ProcedureName
			INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCDTTBA.DBName AND DDL.SchemaName = TCDTTBA.SchemaName AND DDL.ObjectName = TCDTTBA.ProcedureName AND DDL.EventDate = LDC.MaxEventDate
	) AS Users


	DECLARE @Emailsubject NVARCHAR(MAX)
	DECLARE @EmailHTML NVARCHAR(MAX)
	DECLARE @EmailRecipients VARCHAR(500)


	DECLARE @I INT = 1, @MaxUser INT = (SELECT MAX(RN) FROM #ProcedureParametersDataTypesToBeAlignedUsers)
	WHILE (@I <= @MaxUser)
	BEGIN


	SET @EmailHTML = N'<body style="font-family: Arial;">
	  Hi,<BR>' + NCHAR(13) + NCHAR(10)
	  + N'<BR>The following procedure/s were recently created or altered by you.<BR>'+ NCHAR(13) + NCHAR(10)
	  + N'<BR>They contain parameter data type that is not aligned to the data type in the table holding the original source of data.' + NCHAR(13) + NCHAR(10)
	  + N'<BR>It is very important for good performance to have the data type aligned in order to prevent type conversions.<BR>' + NCHAR(13) + NCHAR(10)
	  + N'<BR>Please change the parameter data type as it should be.<BR>&nbsp;<BR>' + NCHAR(13) + NCHAR(10);

	  -- HTML table header for the unused indexes
	  SET @EmailHTML = @EmailHTML + N'<table border="1" style="font-family: Arial; font-size: 14px;">' + NCHAR(13) + NCHAR(10)
	  + N'<TR>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>DB Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Schema Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Procedure Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Parameter Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Current Data Type</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Should Be Data Type</TH>' + NCHAR(13) + NCHAR(10)
	  + N'</TR>' + NCHAR(13) + NCHAR(10);

	  -- HTML table for the unused indexes
	  SET @EmailHTML = @EmailHTML +
	  CAST(( SELECT 
					td = TCDTTBA.DBName, ''
				   ,td = TCDTTBA.SchemaName, ''
				   ,td = TCDTTBA.ProcedureName, ''
				   ,td = TCDTTBA.ParameterName, ''
				   ,td = TCDTTBA.CurrentDataType, ''
				   ,td = TCDTTBA.sholdBeDataType, '' + NCHAR(13) + NCHAR(10)
	  FROM #ProcedureParametersDataTypesToBeAligned AS TCDTTBA INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCDTTBA.DBName AND LDC.SchemaName = TCDTTBA.SchemaName AND LDC.ObjectName = TCDTTBA.ProcedureName
		INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCDTTBA.DBName AND DDL.SchemaName = TCDTTBA.SchemaName AND DDL.ObjectName = TCDTTBA.ProcedureName AND DDL.EventDate = LDC.MaxEventDate
		WHERE DDL.SystemUser = (SELECT TCDTTBAU.SystemUser FROM #ProcedureParametersDataTypesToBeAlignedUsers AS TCDTTBAU WHERE TCDTTBAU.RN = @I)
		ORDER BY TCDTTBA.DBName, TCDTTBA.SchemaName, TCDTTBA.ProcedureName, TCDTTBA.ParameterName
	  FOR XML PATH('tr'),TYPE) AS NVARCHAR(MAX));
  
	  -- Close HTML table
	  SET @EmailHTML = @EmailHTML + NCHAR(13) + NCHAR(10) + '</table>&nbsp;<BR>&nbsp;<BR>';
  
	  -- Close HTML body
	  SET @EmailHTML = @EmailHTML + N'For more information please check: https://dev.azure.com/Payoneer/Payoneer/_wiki/wikis/Payoneer.wiki/528/DB-Review?anchor=data-types' + NCHAR(13) + NCHAR(10) + '</body>';

  
	  SET @EmailRecipients = (SELECT TCDTTBAU.SystemUser FROM #ProcedureParametersDataTypesToBeAlignedUsers AS TCDTTBAU WHERE TCDTTBAU.RN = @I) + '@payoneer.com'
  
  
	  SET @Emailsubject = N'QA - '+ @EmailRecipients +N' Please Cahnge Paramater Data Type On Procedure: ' + (SELECT STRING_AGG(ProcedureName, ', ') FROM #ProcedureParametersDataTypesToBeAligned AS TCDTTBA INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCDTTBA.DBName AND LDC.SchemaName = TCDTTBA.SchemaName AND LDC.ObjectName = TCDTTBA.ProcedureName
		INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCDTTBA.DBName AND DDL.SchemaName = TCDTTBA.SchemaName AND DDL.ObjectName = TCDTTBA.ProcedureName AND DDL.EventDate = LDC.MaxEventDate
		WHERE DDL.SystemUser = (SELECT TCDTTBAU.SystemUser FROM #ProcedureParametersDataTypesToBeAlignedUsers AS TCDTTBAU WHERE TCDTTBAU.RN = @I))
  
  
	  EXEC msdb.dbo.sp_send_dbmail
		@recipients = 'AppDBAs@payoneer.com'
	   ,@subject = @Emailsubject
	   ,@body = @EmailHTML
	   ,@body_format = 'HTML'


	SET @I = @I + 1


	END
END
