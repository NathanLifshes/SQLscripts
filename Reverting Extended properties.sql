USE PayoneerIPCN
GO

/*Reverting Extended properties */

WITH cte_Old_PROPERTY AS (
SELECT X.extended_properties_Name,
       CAST(X.value AS VARCHAR(50)) extended_properties_value,
       X.type,
       X.type_desc,
       X.OrgValue,
       X.ObjectName,
       X.Event_Type,
       X.EventDate,
       X.EventDataText
	   FROM (
SELECT e.name extended_properties_Name,
       e.value,
       o.type,
	   o.type_desc,
       OrgValue =  SUBSTRING(
                 ss.value, /*First argument*/
                 CHARINDEX('''', ss.value) + LEN(''''), /*Second argument*/
                 CHARINDEX('''', ss.value, CHARINDEX('''', ss.value) + LEN(''''))
                 - LEN('''') - CHARINDEX('''', ss.value) /*Third argument*/
                 ),
	   ddl.ObjectName, ddl.Event_Type, ddl.EventDate, ddl.EventDataText, ROW_NUMBER() OVER(PARTITION BY ddl.ObjectName, ddl.Event_Type ORDER BY ddl.EventDate DESC) RowNum
FROM sys.extended_properties e
    INNER JOIN sys.objects o
        ON e.major_id = o.object_id
INNER JOIN DBA.dbo.DDL_Audit ddl ON ObjectName = o.name COLLATE SQL_Latin1_General_CP1_CI_AS AND ddl.Event_Type IN ('CREATE_EXTENDED_PROPERTY')
CROSS APPLY STRING_SPLIT(ddl.EventDataText, ',') ss
WHERE o.schema_id = SCHEMA_ID('dbo')
      AND e.name = 'SSDT_repo'
      AND CONVERT(NVARCHAR(500), e.[value]) IN ('partnersservices-dbo-ssdt','partnersadmin-openapi-funding','partnersadmin-partner-details-api','partnersadmin-tax-forms-service')
	  AND ss.value LIKE '%@value%'
) X WHERE X.RowNum = 1

), cte_New_PROPERTY AS (
SELECT X.extended_properties_Name,
       CAST(X.value AS VARCHAR(50)) extended_properties_value,
       X.type,
       X.type_desc,
       X.ObjectName,
       X.Event_Type,
       X.EventDate,
       X.EventDataText
	   FROM (
SELECT e.name extended_properties_Name,
       e.value,
       o.type,
	   o.type_desc,
	   ddl.ObjectName, ddl.Event_Type, ddl.EventDate, ddl.EventDataText, ROW_NUMBER() OVER(PARTITION BY ddl.ObjectName, ddl.Event_Type ORDER BY ddl.EventDate DESC) RowNum
FROM sys.extended_properties e
    INNER JOIN sys.objects o
        ON e.major_id = o.object_id
INNER JOIN DBA.dbo.DDL_Audit ddl ON ObjectName = o.name COLLATE SQL_Latin1_General_CP1_CI_AS AND ddl.Event_Type IN ('ALTER_EXTENDED_PROPERTY')
CROSS APPLY STRING_SPLIT(ddl.EventDataText, ',') ss
WHERE o.schema_id = SCHEMA_ID('dbo')
      AND e.name = 'SSDT_repo'
      AND CONVERT(NVARCHAR(500), e.[value]) IN ('partnersservices-dbo-ssdt','partnersadmin-openapi-funding','partnersadmin-partner-details-api','partnersadmin-tax-forms-service')
	  AND ss.value LIKE '%@value%'
) X WHERE X.RowNum = 1

)

SELECT cte_New_PROPERTY.ObjectName, cte_New_PROPERTY.type_desc, cte_Old_PROPERTY.extended_properties_value, cte_Old_PROPERTY.OrgValue, REPLACE(cte_New_PROPERTY.EventDataText,cte_Old_PROPERTY.extended_properties_value, cte_Old_PROPERTY.OrgValue) AS EventDataText
FROM cte_New_PROPERTY
INNER JOIN cte_Old_PROPERTY
ON cte_New_PROPERTY.ObjectName = cte_Old_PROPERTY.ObjectName
AND cte_New_PROPERTY.type = cte_Old_PROPERTY.type


/**/
