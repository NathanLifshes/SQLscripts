USE DBA
GO
/**/
SELECT  *
FROM    DBA.dbo.DDL_Audit
WHERE   ObjectName LIKE '%TableColumnsDataTypesCompare%'
ORDER BY DDL_Audit_ID DESC;
/**/
CREATE PROCEDURE [dbo].[TableColumnsDataTypesCompare]
AS
-- Author:       Dudu Arviv
-- Create date:  2019-12-15
-- Description:  This procedure is used to send an email containing information about tables that were change or created since the last time the job DBA - Data Types Compare ran that has 
--				 columns with data types that are not aligned to our instructions in the wiki page.
--				 https://dev.azure.com/Payoneer/Payoneer/_wiki/wikis/Payoneer.wiki/528/DB-Review?anchor=data-types
-- ==============================================================
BEGIN
	SET NOCOUNT ON


	DROP TABLE IF EXISTS #ColumnsDiffrencesSinceLastRun
	DROP TABLE IF EXISTS #TablesLastDateChange
	DROP TABLE IF EXISTS #TableColumnsDataTypesToBeAligned
	DROP TABLE IF EXISTS #TableColumnsDataTypesToBeAlignedUsers
	DROP TABLE IF EXISTS #TableColumnsBLOB
	DROP TABLE IF EXISTS #TableColumnsBLOBUsers

	CREATE TABLE #TableColumnsDataTypesToBeAligned (Column_Name NVARCHAR(100), CurrentDataType NVARCHAR(100), sholdBeDataType NVARCHAR(100), DBName NVARCHAR(100), SchemaName NVARCHAR(100), TableName NVARCHAR(100))
	CREATE TABLE #TableColumnsBLOB (Column_Name NVARCHAR(100), CurrentDataType NVARCHAR(100), DBName NVARCHAR(100), SchemaName NVARCHAR(100), TableName NVARCHAR(100))


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
		AND ObjectType = 'TABLE'
		AND Event_Type IN ('ALTER_TABLE','CREATE_TABLE')
		AND SchemaName <> 'cdc'
	GROUP BY
		Database_Name
		,SchemaName
		,ObjectName


	DECLARE @Command NVARCHAR(MAX) = ''
	DECLARE @CommandBLOB NVARCHAR(MAX) = ''


	SELECT
	@Command = @Command +
	'
	USE ' + name + '
	INSERT INTO #TableColumnsDataTypesToBeAligned
	SELECT COLUMN_NAME, UPPER(REPLACE(DATA_TYPE + CASE WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN ''('' + CONVERT(NVARCHAR(10),CHARACTER_MAXIMUM_LENGTH) + '')'' ELSE '''' END, ''-1'', ''MAX'')) AS CurrentDataType
	,CASE WHEN COLUMN_NAME = N''CardholderId'' THEN ''VARCHAR(50)''
		WHEN COLUMN_NAME = N''PartnerId'' THEN ''INT''
		WHEN COLUMN_NAME = N''DebitCardId'' THEN ''VARCHAR(50)''
		WHEN COLUMN_NAME = N''iACHId'' THEN ''VARCHAR(50)''
		WHEN COLUMN_NAME = N''PaymentId'' THEN ''VARCHAR(50) / NVARCHAR(50)''
		WHEN COLUMN_NAME = N''LoadId'' OR COLUMN_NAME = N''TransactionId'' THEN ''VARCHAR(50) / NVARCHAR(50)''
		WHEN COLUMN_NAME = N''Currency'' THEN ''VARCHAR(6)''
		WHEN COLUMN_NAME = N''Country'' THEN ''NVARCHAR(50)''
		END AS ShouldBeDataType
	,TABLE_CATALOG
	,TABLE_SCHEMA
	,TABLE_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE --COLUMN_NAME IN (''CardholderId'',''PartnerId'',''DebitCardId'',''iACHId'',''PaymentId'',''LoadId'',''Currency'',''Country'')
		((COLUMN_NAME = N''CardholderId'' AND (DATA_TYPE <> ''varchar'' OR CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (COLUMN_NAME = N''PartnerId'' AND (DATA_TYPE <> ''int''))
		OR (COLUMN_NAME = N''DebitCardId'' AND (DATA_TYPE <> ''varchar'' OR CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (COLUMN_NAME = N''iACHId'' AND (DATA_TYPE <> ''varchar'' OR CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (COLUMN_NAME = N''PaymentId'' AND (CHARACTER_MAXIMUM_LENGTH <> 50))
		OR ((COLUMN_NAME = N''LoadId'' OR COLUMN_NAME = N''TransactionId'') AND (CHARACTER_MAXIMUM_LENGTH <> 50))
		OR (COLUMN_NAME = N''Currency'' AND (DATA_TYPE <> ''varchar'' OR CHARACTER_MAXIMUM_LENGTH <> 6))
		OR (COLUMN_NAME = N''Country'' AND (DATA_TYPE <> ''nvarchar'' OR CHARACTER_MAXIMUM_LENGTH <> 50)))
		AND TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS IN (SELECT ObjectName FROM #TablesLastDateChange WHERE Database_Name = ''' + name + ''')
	'
	,
	@CommandBLOB = @CommandBLOB +
	'
	USE ' + name + '
	INSERT INTO #TableColumnsBLOB
	SELECT COLUMN_NAME, UPPER(REPLACE(DATA_TYPE + CASE WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN ''('' + CONVERT(NVARCHAR(10),CHARACTER_MAXIMUM_LENGTH) + '')'' ELSE '''' END, ''-1'', ''MAX'')) AS CurrentDataType
	,TABLE_CATALOG
	,TABLE_SCHEMA
	,TABLE_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE ((data_type in (''VARCHAR'', ''NVARCHAR'') and character_maximum_length = -1)
		or data_type in (''TEXT'', ''NTEXT'', ''IMAGE'', ''VARBINARY'', ''XML'', ''FILESTREAM''))
		AND TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS IN (SELECT ObjectName FROM #TablesLastDateChange WHERE Database_Name = ''' + name + ''')
	'
	FROM
		SYS.databases
	WHERE
		NAME IN (SELECT DISTINCT Database_Name FROM #TablesLastDateChange)
	ORDER BY
		NAME


	SELECT @Command
	SELECT @CommandBLOB


	EXEC (@Command)
	EXEC (@CommandBLOB)


	SELECT
		ROW_NUMBER() OVER (ORDER BY Users.SystemUser) AS RN
		,Users.SystemUser
		INTO #TableColumnsDataTypesToBeAlignedUsers
	FROM
	(
		SELECT DISTINCT
			DDL.SystemUser
		FROM
			#TableColumnsDataTypesToBeAligned AS TCDTTBA INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCDTTBA.DBName AND LDC.SchemaName = TCDTTBA.SchemaName AND LDC.ObjectName = TCDTTBA.TableName
			INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCDTTBA.DBName AND DDL.SchemaName = TCDTTBA.SchemaName AND DDL.ObjectName = TCDTTBA.TableName AND DDL.EventDate = LDC.MaxEventDate
	) AS Users


	SELECT
		ROW_NUMBER() OVER (ORDER BY UsersBLOB.SystemUser) AS RN
		,UsersBLOB.SystemUser
		INTO #TableColumnsBLOBUsers
	FROM
	(
		SELECT DISTINCT
			DDL.SystemUser
		FROM
			#TableColumnsBLOB AS TCB INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCB.DBName AND LDC.SchemaName = TCB.SchemaName AND LDC.ObjectName = TCB.TableName
			INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCB.DBName AND DDL.SchemaName = TCB.SchemaName AND DDL.ObjectName = TCB.TableName AND DDL.EventDate = LDC.MaxEventDate
	) AS UsersBLOB


	DECLARE @Emailsubject NVARCHAR(MAX)
	DECLARE @EmailHTML NVARCHAR(MAX)
	DECLARE @EmailRecipients VARCHAR(500)


	DECLARE @I INT = 1, @MaxUser INT = (SELECT MAX(RN) FROM #TableColumnsDataTypesToBeAlignedUsers)
	WHILE (@I <= @MaxUser)
	BEGIN


	SET @EmailHTML = N'<body style="font-family: Arial;">
	  Hi,<BR>' + NCHAR(13) + NCHAR(10)
	  + N'<BR>The following table/s were recently created or altered by you.<BR>'+ NCHAR(13) + NCHAR(10)
	  + N'<BR>They contain column data type that is not aligned to the data type in the table holding the original source of data.' + NCHAR(13) + NCHAR(10)
	  + N'<BR>It is very important for good performance to have the data type aligned in order to prevent type conversions.<BR>' + NCHAR(13) + NCHAR(10)
	  + N'<BR>Please change the column data type as it should be.<BR>&nbsp;<BR>' + NCHAR(13) + NCHAR(10);

	  -- HTML table header for the unused indexes
	  SET @EmailHTML = @EmailHTML + N'<table border="1" style="font-family: Arial; font-size: 14px;">' + NCHAR(13) + NCHAR(10)
	  + N'<TR>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>DB Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Schema Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Table Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Column Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Current Data Type</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Should Be Data Type</TH>' + NCHAR(13) + NCHAR(10)
	  + N'</TR>' + NCHAR(13) + NCHAR(10);

	  -- HTML table for the unused indexes
	  SET @EmailHTML = @EmailHTML +
	  CAST(( SELECT 
					td = TCDTTBA.DBName, ''
				   ,td = TCDTTBA.SchemaName, ''
				   ,td = TCDTTBA.TableName, ''
				   ,td = TCDTTBA.Column_Name, ''
				   ,td = TCDTTBA.CurrentDataType, ''
				   ,td = TCDTTBA.sholdBeDataType, '' + NCHAR(13) + NCHAR(10)
	  FROM #TableColumnsDataTypesToBeAligned AS TCDTTBA INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCDTTBA.DBName AND LDC.SchemaName = TCDTTBA.SchemaName AND LDC.ObjectName = TCDTTBA.TableName
		INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCDTTBA.DBName AND DDL.SchemaName = TCDTTBA.SchemaName AND DDL.ObjectName = TCDTTBA.TableName AND DDL.EventDate = LDC.MaxEventDate
		WHERE DDL.SystemUser = (SELECT TCDTTBAU.SystemUser FROM #TableColumnsDataTypesToBeAlignedUsers AS TCDTTBAU WHERE TCDTTBAU.RN = @I)
		ORDER BY TCDTTBA.DBName, TCDTTBA.SchemaName, TCDTTBA.TableName, TCDTTBA.Column_Name
	  FOR XML PATH('tr'),TYPE) AS NVARCHAR(MAX));

  
	  -- Close HTML table
	  SET @EmailHTML = @EmailHTML + NCHAR(13) + NCHAR(10) + '</table>&nbsp;<BR>&nbsp;<BR>';
  
	  -- Close HTML body
	  SET @EmailHTML = @EmailHTML + N'For more information please check: https://dev.azure.com/Payoneer/Payoneer/_wiki/wikis/Payoneer.wiki/528/DB-Review?anchor=data-types' + NCHAR(13) + NCHAR(10) + '</body>';

  
	  SET @EmailRecipients = (SELECT TCDTTBAU.SystemUser FROM #TableColumnsDataTypesToBeAlignedUsers AS TCDTTBAU WHERE TCDTTBAU.RN = @I) + '@payoneer.com'


	  SET @Emailsubject = N'QA - '+ @EmailRecipients +N' Please Cahnge Table Column Data Type On Table: ' + (SELECT STRING_AGG(TableName, ', ') FROM #TableColumnsDataTypesToBeAligned AS TCDTTBA INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCDTTBA.DBName AND LDC.SchemaName = TCDTTBA.SchemaName AND LDC.ObjectName = TCDTTBA.TableName
		INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCDTTBA.DBName AND DDL.SchemaName = TCDTTBA.SchemaName AND DDL.ObjectName = TCDTTBA.TableName AND DDL.EventDate = LDC.MaxEventDate
		WHERE DDL.SystemUser = (SELECT TCDTTBAU.SystemUser FROM #TableColumnsDataTypesToBeAlignedUsers AS TCDTTBAU WHERE TCDTTBAU.RN = @I))
  
  
	  EXEC msdb.dbo.sp_send_dbmail
		@recipients = 'AppDBAs@payoneer.com'
	   ,@subject = @Emailsubject
	   ,@body = @EmailHTML
	   ,@body_format = 'HTML'


	SET @I = @I + 1


	END


	SET @I = 1
	SET @MaxUser = (SELECT MAX(RN) FROM #TableColumnsBLOBUsers)
	WHILE (@I <= @MaxUser)
	BEGIN


	SET @EmailHTML = N'<body style="font-family: Arial;">
	  Hi,<BR>' + NCHAR(13) + NCHAR(10)
	  + N'<BR>The following table/s were recently created or altered by you.<BR>'+ NCHAR(13) + NCHAR(10)
	  + N'<BR>They contain BLOB column data type that is not should be reviewd and approved.' + NCHAR(13) + NCHAR(10)
	  + N'&nbsp;<BR>' + NCHAR(13) + NCHAR(10);

	  -- HTML table header for the unused indexes
	  SET @EmailHTML = @EmailHTML + N'<table border="1" style="font-family: Arial; font-size: 14px;">' + NCHAR(13) + NCHAR(10)
	  + N'<TR>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>DB Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Schema Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Table Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Column Name</TH>' + NCHAR(13) + NCHAR(10)
	  + N'<TH>Current Data Type</TH>' + NCHAR(13) + NCHAR(10)
	  + N'</TR>' + NCHAR(13) + NCHAR(10);

	  -- HTML table for the unused indexes
	  SET @EmailHTML = @EmailHTML +
	  CAST(( SELECT 
					td = TCB.DBName, ''
				   ,td = TCB.SchemaName, ''
				   ,td = TCB.TableName, ''
				   ,td = TCB.Column_Name, ''
				   ,td = TCB.CurrentDataType, '' + NCHAR(13) + NCHAR(10)
	  FROM #TableColumnsBLOB AS TCB INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCB.DBName AND LDC.SchemaName = TCB.SchemaName AND LDC.ObjectName = TCB.TableName
		INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCB.DBName AND DDL.SchemaName = TCB.SchemaName AND DDL.ObjectName = TCB.TableName AND DDL.EventDate = LDC.MaxEventDate
		WHERE DDL.SystemUser = (SELECT TCBU.SystemUser FROM #TableColumnsBLOBUsers AS TCBU WHERE TCBU.RN = @I)
		ORDER BY TCB.DBName, TCB.SchemaName, TCB.TableName, TCB.Column_Name
	  FOR XML PATH('tr'),TYPE) AS NVARCHAR(MAX));

  
	  -- Close HTML table
	  SET @EmailHTML = @EmailHTML + NCHAR(13) + NCHAR(10) + '</table>&nbsp;<BR>&nbsp;<BR>';
  
	  -- Close HTML body
	  SET @EmailHTML = @EmailHTML + N'' + NCHAR(13) + NCHAR(10) + '</body>';

  
	  SET @EmailRecipients = (SELECT TCBU.SystemUser FROM #TableColumnsBLOBUsers AS TCBU WHERE TCBU.RN = @I) + '@payoneer.com'


	  SET @Emailsubject = N'QA - '+ @EmailRecipients +N' Please Cahnge Table Column Data Type On Table: ' + (SELECT STRING_AGG(TableName, ', ') FROM #TableColumnsBLOB AS TCB INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCB.DBName AND LDC.SchemaName = TCB.SchemaName AND LDC.ObjectName = TCB.TableName
		INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCB.DBName AND DDL.SchemaName = TCB.SchemaName AND DDL.ObjectName = TCB.TableName AND DDL.EventDate = LDC.MaxEventDate
		WHERE DDL.SystemUser = (SELECT TCBU.SystemUser FROM #TableColumnsBLOBUsers AS TCBU WHERE TCBU.RN = @I))
  
  
	  EXEC msdb.dbo.sp_send_dbmail
		@recipients = 'AppDBAs@payoneer.com'
	   ,@subject = @Emailsubject
	   ,@body = @EmailHTML
	   ,@body_format = 'HTML'


	SET @I = @I + 1


	END
END