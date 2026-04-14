
/**/

DROP TABLE IF EXISTS #CardholderSupportLog;
SELECT object_name,
       CAST(event_data AS XML) AS event_data,
       timestamp_utc
INTO #CardholderSupportLog
FROM sys.fn_xe_file_target_read_file('I:\SQLServer\Trace\trace_CardholderSupportLog_SPWrites*.xel', NULL, NULL, NULL)

SELECT TOP 100
       n.value('(@name)[1]', 'varchar(50)') AS event_name,
       n.value('(@package)[1]', 'varchar(50)') AS package_name,
       n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
	   n.value('(action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS client_app_name,
	   n.value('(action[@name="client_hostname"]/value)[1]', 'nvarchar(128)') AS client_hostname,
       n.value('(data[@name="object_type"]/text)[1]', 'nvarchar(128)') AS object_type,
	   n.value('(data[@name="object_name"]/value)[1]', 'nvarchar(128)') AS object_name,
	   n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') AS username,
	   n.value('(data[@name="duration"]/value)[1]', 'int') AS duration,
       n.value('(data[@name="cpu_time"]/value)[1]', 'int') AS cpu,
       n.value('(data[@name="physical_reads"]/value)[1]', 'int') AS physical_reads,
       n.value('(data[@name="logical_reads"]/value)[1]', 'int') AS logical_reads,
       n.value('(data[@name="writes"]/value)[1]', 'int') AS writes,
       n.value('(data[@name="row_count"]/value)[1]', 'int') AS row_count,
       n.value('(data[@name="last_row_count"]/value)[1]', 'int') AS last_row_count,
       n.value('(data[@name="line_number"]/value)[1]', 'int') AS line_number,
       n.value('(data[@name="offset"]/value)[1]', 'int') AS offset,
       n.value('(data[@name="offset_end"]/value)[1]', 'int') AS offset_end,
       n.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statement,
	   n.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
       n.value('(action[@name="database_name"]/value)[1]', 'nvarchar(128)') AS database_name
FROM #CardholderSupportLog fx
    CROSS APPLY fx.event_data.nodes('event') AS q(n)
	WHERE n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') <> N'AppUser_EB'
ORDER BY timestamp_utc DESC;


SELECT n.value('(@name)[1]', 'varchar(50)') AS event_name,
       n.value('(@package)[1]', 'varchar(50)') AS package_name,
       n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
       n.value('(action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS client_app_name,
       n.value('(action[@name="client_hostname"]/value)[1]', 'nvarchar(128)') AS client_hostname,
       n.value('(data[@name="object_type"]/text)[1]', 'nvarchar(128)') AS object_type,
       n.value('(data[@name="object_name"]/value)[1]', 'nvarchar(128)') AS object_name,
       n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') AS username,
       n.value('(data[@name="duration"]/value)[1]', 'int') AS duration,
       n.value('(data[@name="cpu_time"]/value)[1]', 'int') AS cpu,
       n.value('(data[@name="physical_reads"]/value)[1]', 'int') AS physical_reads,
       n.value('(data[@name="logical_reads"]/value)[1]', 'int') AS logical_reads,
       n.value('(data[@name="writes"]/value)[1]', 'int') AS writes,
       n.value('(data[@name="row_count"]/value)[1]', 'int') AS row_count,
       n.value('(data[@name="last_row_count"]/value)[1]', 'int') AS last_row_count,
       n.value('(data[@name="line_number"]/value)[1]', 'int') AS line_number,
       n.value('(data[@name="offset"]/value)[1]', 'int') AS offset,
       n.value('(data[@name="offset_end"]/value)[1]', 'int') AS offset_end,
       n.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statement,
       n.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
       n.value('(action[@name="database_name"]/value)[1]', 'nvarchar(128)') AS database_name
INTO DBA_Local.dbo.trace_CardholderSupportLog_SPWrites
FROM #CardholderSupportLog fx
    CROSS APPLY fx.event_data.nodes('event') AS q(n);
/**/

/**/

DROP TABLE IF EXISTS #LoaderSupportLog;
SELECT object_name,
       cast(event_data as XML) AS event_data,
       timestamp_utc
INTO #LoaderSupportLog
FROM sys.fn_xe_file_target_read_file('pay_LoaderSupportLog1*.xel', NULL, NULL, NULL)

SELECT TOP (10) * FROM #LoaderSupportLog ORDER BY timestamp_utc DESC
SELECT COUNT(*),MIN(timestamp_utc), MAX(timestamp_utc) FROM #LoaderSupportLog 
SELECT COUNT(*), CAST(timestamp_utc AS DATE) timestamp FROM #LoaderSupportLog GROUP BY CAST(timestamp_utc AS DATE)



SELECT TOP 100
       n.value('(@name)[1]', 'varchar(50)') AS event_name,
       n.value('(@package)[1]', 'varchar(50)') AS package_name,
       n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
	   n.value('(action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS client_app_name,
	   n.value('(action[@name="client_hostname"]/value)[1]', 'nvarchar(128)') AS client_hostname,
       n.value('(data[@name="object_type"]/text)[1]', 'nvarchar(128)') AS object_type,
	   n.value('(data[@name="object_name"]/value)[1]', 'nvarchar(128)') AS object_name,
	   n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') AS username,
	   n.value('(data[@name="duration"]/value)[1]', 'int') AS duration,
       n.value('(data[@name="cpu_time"]/value)[1]', 'int') AS cpu,
       n.value('(data[@name="physical_reads"]/value)[1]', 'int') AS physical_reads,
       n.value('(data[@name="logical_reads"]/value)[1]', 'int') AS logical_reads,
       n.value('(data[@name="writes"]/value)[1]', 'int') AS writes,
       n.value('(data[@name="row_count"]/value)[1]', 'int') AS row_count,
       n.value('(data[@name="last_row_count"]/value)[1]', 'int') AS last_row_count,
       n.value('(data[@name="line_number"]/value)[1]', 'int') AS line_number,
       n.value('(data[@name="offset"]/value)[1]', 'int') AS offset,
       n.value('(data[@name="offset_end"]/value)[1]', 'int') AS offset_end,
       n.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statement,
	   n.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
       n.value('(action[@name="database_name"]/value)[1]', 'nvarchar(128)') AS database_name
FROM #LoaderSupportLog fx
    CROSS APPLY fx.event_data.nodes('event') AS q(n)
WHERE n.value('(data[@name="object_type"]/text)[1]', 'nvarchar(128)') = 'PROC'
ORDER BY timestamp_utc DESC;

/**/
INSERT INTO DBA_Local..pay_LoaderSupportLog
(
    event_name,
    package_name,
    utc_timestamp,
    client_app_name,
    client_hostname,
    object_type,
    object_name,
    username,
    duration,
    cpu,
    physical_reads,
    logical_reads,
    writes,
    row_count,
    last_row_count,
    line_number,
    offset,
    offset_end,
    statement,
    sql_text,
    database_name
)
SELECT n.value('(@name)[1]', 'varchar(50)') AS event_name,
       n.value('(@package)[1]', 'varchar(50)') AS package_name,
       n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
       n.value('(action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS client_app_name,
       n.value('(action[@name="client_hostname"]/value)[1]', 'nvarchar(128)') AS client_hostname,
       n.value('(data[@name="object_type"]/text)[1]', 'nvarchar(128)') AS object_type,
       n.value('(data[@name="object_name"]/value)[1]', 'nvarchar(128)') AS object_name,
       n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') AS username,
       n.value('(data[@name="duration"]/value)[1]', 'int') AS duration,
       n.value('(data[@name="cpu_time"]/value)[1]', 'int') AS cpu,
       n.value('(data[@name="physical_reads"]/value)[1]', 'int') AS physical_reads,
       n.value('(data[@name="logical_reads"]/value)[1]', 'int') AS logical_reads,
       n.value('(data[@name="writes"]/value)[1]', 'int') AS writes,
       n.value('(data[@name="row_count"]/value)[1]', 'int') AS row_count,
       n.value('(data[@name="last_row_count"]/value)[1]', 'int') AS last_row_count,
       n.value('(data[@name="line_number"]/value)[1]', 'int') AS line_number,
       n.value('(data[@name="offset"]/value)[1]', 'int') AS offset,
       n.value('(data[@name="offset_end"]/value)[1]', 'int') AS offset_end,
       n.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statement,
       n.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
       n.value('(action[@name="database_name"]/value)[1]', 'nvarchar(128)') AS database_name
INTO DBA_Local.dbo.pay_LoaderSupportLog2
FROM #LoaderSupportLog fx
    CROSS APPLY fx.event_data.nodes('event') AS q(n);

/**/

/**/

DROP TABLE IF EXISTS #CardholderSupportLog;
SELECT object_name,
       CAST(event_data AS XML) AS event_data,
       timestamp_utc
INTO #CardholderSupportLog
FROM sys.fn_xe_file_target_read_file('trace_LoaderSupportLog_SPReads*.xel', NULL, NULL, NULL)

SELECT TOP 100
       n.value('(@name)[1]', 'varchar(50)') AS event_name,
       n.value('(@package)[1]', 'varchar(50)') AS package_name,
       n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
	   n.value('(action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS client_app_name,
	   n.value('(action[@name="client_hostname"]/value)[1]', 'nvarchar(128)') AS client_hostname,
       n.value('(data[@name="object_type"]/text)[1]', 'nvarchar(128)') AS object_type,
	   n.value('(data[@name="object_name"]/value)[1]', 'nvarchar(128)') AS object_name,
	   n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') AS username,
	   n.value('(data[@name="duration"]/value)[1]', 'int') AS duration,
       n.value('(data[@name="cpu_time"]/value)[1]', 'int') AS cpu,
       n.value('(data[@name="physical_reads"]/value)[1]', 'int') AS physical_reads,
       n.value('(data[@name="logical_reads"]/value)[1]', 'int') AS logical_reads,
       n.value('(data[@name="writes"]/value)[1]', 'int') AS writes,
       n.value('(data[@name="row_count"]/value)[1]', 'int') AS row_count,
       n.value('(data[@name="last_row_count"]/value)[1]', 'int') AS last_row_count,
       n.value('(data[@name="line_number"]/value)[1]', 'int') AS line_number,
       n.value('(data[@name="offset"]/value)[1]', 'int') AS offset,
       n.value('(data[@name="offset_end"]/value)[1]', 'int') AS offset_end,
       n.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statement,
	   n.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
       n.value('(action[@name="database_name"]/value)[1]', 'nvarchar(128)') AS database_name
FROM #CardholderSupportLog fx
    CROSS APPLY fx.event_data.nodes('event') AS q(n)
	WHERE n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') <> N'AppUser_EB'
ORDER BY timestamp_utc DESC;


SELECT n.value('(@name)[1]', 'varchar(50)') AS event_name,
       n.value('(@package)[1]', 'varchar(50)') AS package_name,
       n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
       n.value('(action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS client_app_name,
       n.value('(action[@name="client_hostname"]/value)[1]', 'nvarchar(128)') AS client_hostname,
       n.value('(data[@name="object_type"]/text)[1]', 'nvarchar(128)') AS object_type,
       n.value('(data[@name="object_name"]/value)[1]', 'nvarchar(128)') AS object_name,
       n.value('(action[@name="username"]/value)[1]', 'nvarchar(128)') AS username,
       n.value('(data[@name="duration"]/value)[1]', 'int') AS duration,
       n.value('(data[@name="cpu_time"]/value)[1]', 'int') AS cpu,
       n.value('(data[@name="physical_reads"]/value)[1]', 'int') AS physical_reads,
       n.value('(data[@name="logical_reads"]/value)[1]', 'int') AS logical_reads,
       n.value('(data[@name="writes"]/value)[1]', 'int') AS writes,
       n.value('(data[@name="row_count"]/value)[1]', 'int') AS row_count,
       n.value('(data[@name="last_row_count"]/value)[1]', 'int') AS last_row_count,
       n.value('(data[@name="line_number"]/value)[1]', 'int') AS line_number,
       n.value('(data[@name="offset"]/value)[1]', 'int') AS offset,
       n.value('(data[@name="offset_end"]/value)[1]', 'int') AS offset_end,
       n.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statement,
       n.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
       n.value('(action[@name="database_name"]/value)[1]', 'nvarchar(128)') AS database_name
INTO DBA_Local.dbo.trace_LoaderSupportLog_SPReads
FROM #CardholderSupportLog fx
    CROSS APPLY fx.event_data.nodes('event') AS q(n);
/**/