USE DBA
GO
/**/
SELECT  *
FROM    DBA.dbo.DDL_Audit
WHERE   ObjectName LIKE '%TableColumnsDataTypesCompareWeekly%'
ORDER BY DDL_Audit_ID DESC;
/**/
CREATE PROCEDURE [dbo].[TableColumnsDataTypesCompareWeekly]
AS
-- Author:       Dudu Arviv
-- Create date:  2019-12-15
-- Description:  This procedure is used to send an email containing information about tables that were change or created in the last week that has parameters with data types that are not alligned to our instructions in the wiki page.
--				 https://dev.azure.com/Payoneer/Payoneer/_wiki/wikis/Payoneer.wiki/528/DB-Review?anchor=data-types
-- ==============================================================
BEGIN
	--Makes sure that this procedure run only on sunday 09:00
	IF (DATEPART(WEEKDAY, GETDATE()) = 1 AND DATEPART(HOUR, GETDATE()) = 9 AND DATEPART(MINUTE, GETDATE()) BETWEEN 0 AND 30)
	BEGIN
		SET NOCOUNT ON
	
	
		DROP TABLE IF EXISTS #ColumnsDiffrencesSinceLastRun
		DROP TABLE IF EXISTS #TablesLastDateChange
		DROP TABLE IF EXISTS #TableColumnsDataTypesToBeAligned
		DROP TABLE IF EXISTS #TableColumnsDataTypesToBeAlignedUsers

		CREATE TABLE #TableColumnsDataTypesToBeAligned (Column_Name NVARCHAR(100), CurrentDataType NVARCHAR(100), sholdBeDataType NVARCHAR(100), DBName NVARCHAR(100), SchemaName NVARCHAR(100), TableName NVARCHAR(100))


		DECLARE @LastExecution DATETIME = DATEADD(DAY, -7, GETDATE())


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
		FROM
			SYS.databases
		WHERE
			NAME IN (SELECT DISTINCT Database_Name FROM #TablesLastDateChange)
		ORDER BY
			NAME


		EXEC (@Command)


		DECLARE @Emailsubject NVARCHAR(MAX)
		DECLARE @EmailHTML NVARCHAR(MAX)
		DECLARE @EmailRecipients VARCHAR(500)


		SET @EmailHTML = N'<body style="font-family: Arial;">
		  Hi,<BR>' + NCHAR(13) + NCHAR(10)
		  + N'<BR>The following table/s were created or altered in the last week with incorrect data type.<BR>'+ NCHAR(13) + NCHAR(10)
		  + N'<BR>A request to fix the data type was sent to the relevant developer but the data type was not fixed yet.<BR>' + NCHAR(13) + NCHAR(10)
		  + N'<BR>&nbsp;<BR>' + NCHAR(13) + NCHAR(10);

		  -- HTML table header for the unused indexes
		  SET @EmailHTML = @EmailHTML + N'<table border="1" style="font-family: Arial; font-size: 14px;">' + NCHAR(13) + NCHAR(10)
		  + N'<TR>' + NCHAR(13) + NCHAR(10)
		  + N'<TH>DB Name</TH>' + NCHAR(13) + NCHAR(10)
		  + N'<TH>Schema Name</TH>' + NCHAR(13) + NCHAR(10)
		  + N'<TH>Table Name</TH>' + NCHAR(13) + NCHAR(10)
		  + N'<TH>Column Name</TH>' + NCHAR(13) + NCHAR(10)
		  + N'<TH>Current Data Type</TH>' + NCHAR(13) + NCHAR(10)
		  + N'<TH>Should Be Data Type</TH>' + NCHAR(13) + NCHAR(10)
		  + N'<TH>Relevant User Name</TH>' + NCHAR(13) + NCHAR(10)
		  + N'</TR>' + NCHAR(13) + NCHAR(10);

		  -- HTML table for the unused indexes
		  SET @EmailHTML = @EmailHTML +
		  CAST(( SELECT 
						td = TCDTTBA.DBName, ''
					   ,td = TCDTTBA.SchemaName, ''
					   ,td = TCDTTBA.TableName, ''
					   ,td = TCDTTBA.Column_Name, ''
					   ,td = TCDTTBA.CurrentDataType, ''
					   ,td = TCDTTBA.sholdBeDataType, ''
					   ,td = DDL.SystemUser, '' + NCHAR(13) + NCHAR(10)
		  FROM #TableColumnsDataTypesToBeAligned AS TCDTTBA INNER JOIN #TablesLastDateChange AS LDC ON LDC.Database_Name = TCDTTBA.DBName AND LDC.SchemaName = TCDTTBA.SchemaName AND LDC.ObjectName = TCDTTBA.TableName
			INNER JOIN DBA.dbo.DDL_Audit AS DDL ON DDL.Database_Name = TCDTTBA.DBName AND DDL.SchemaName = TCDTTBA.SchemaName AND DDL.ObjectName = TCDTTBA.TableName AND DDL.EventDate = LDC.MaxEventDate
			ORDER BY TCDTTBA.DBName, TCDTTBA.SchemaName, TCDTTBA.TableName, TCDTTBA.Column_Name
		  FOR XML PATH('tr'),TYPE) AS NVARCHAR(MAX));

  
		  -- Close HTML table
		  SET @EmailHTML = @EmailHTML + NCHAR(13) + NCHAR(10) + '</table>&nbsp;<BR>&nbsp;<BR>';
  
		  -- Close HTML body
		  SET @EmailHTML = @EmailHTML + NCHAR(13) + NCHAR(10) + '</body>';


		  SET @Emailsubject = N'Weekly Report: Table Columns Data Types'
  
  
		  EXEC msdb.dbo.sp_send_dbmail
			@recipients = 'AppDBAs@payoneer.com'
		   ,@subject = @Emailsubject
		   ,@body = @EmailHTML
		   ,@body_format = 'HTML'


	END
END

/**/