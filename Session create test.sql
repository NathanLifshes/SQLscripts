/* Notes:
1. DON'T FORGET TO STOP AND DROP SESSION WHEN FINISHED!!
2. Use this code to collect small amount of events < 1000 or small time phases instead of using profiler.
3. Replace every occurence of Test_Mich to your own session name.
4. Adjust WHERE clause in both events. Where supports various ARD\OR combined options.
5. For searching [] use [[] for [, leave ] as is  -   [p].[ProcessId] --> [[]p].[[]ProcessId]
6. sql_text doesn't save parameters value in rpc_completed event 
	and there is no "collect_statement" option for sql_batch_completed. 
	So in final select statement value is chosen first.
7. You won't see CPU, reads, writes etc in actions list since those are events and not actions - read more about those in Extended events documentary. 
8. rpc_completed cannot catch inner procedures
You can use add module_start to catch those but it won't catch exec parameters
ALTER EVENT SESSION [Test_mich] ON SERVER 
ADD EVENT sqlserver.module_start(SET collect_statement=(1)
    WHERE ([object_type]='P ' AND [object_name]=N'MR_IsPartnerCreatesAccounts'))
*/

/********** Phase 1 - Create ExEvents session and start it  **********/

CREATE EVENT SESSION [Test_Mich] ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.database_name,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]
		([sqlserver].[server_principal_name],N'michaelch')
		OR
		([sqlserver].[equal_i_sql_unicode_string]
		([sqlserver].[server_principal_name],N'pay_app_user')
		AND [sqlserver].[equal_i_sql_unicode_string]
			([sqlserver].[client_hostname],N'PT-APP04-QA') 
		AND [sqlserver].[like_i_sql_unicode_string]
			([sqlserver].[sql_text],N'%SELECT TOP(1) [[]p].[[]ProcessId]%')
		AND [duration]>(200))
	)),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(0)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.database_name,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]
		([sqlserver].[server_principal_name],N'michaelch')
		OR
		([sqlserver].[equal_i_sql_unicode_string]
		([sqlserver].[server_principal_name],N'pay_app_user')
		AND [sqlserver].[equal_i_sql_unicode_string]
			([sqlserver].[client_hostname],N'PT-APP04-QA') 
		AND [sqlserver].[like_i_sql_unicode_string]
			([sqlserver].[sql_text],N'%SELECT TOP(1) [[]p].[[]ProcessId]%')
		AND [duration]>(200))
	))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=10 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO

ALTER EVENT SESSION Test_Mich ON SERVER STATE = START;

/********** Phase 2(Optional) - Check num of events captured **********/
WITH cte AS
	(SELECT CAST(target_data as xml) AS targetdata
	FROM sys.dm_xe_session_targets xet
	JOIN sys.dm_xe_sessions xes
		ON xes.address = xet.event_session_address
	WHERE xes.name = 'Test_Mich'
	  AND xet.target_name = 'ring_buffer')
SELECT xed.event_data.value('(@eventCount)[1]', 'int') AS [event]
FROM cte
	CROSS APPLY targetdata.nodes('//RingBufferTarget') AS xed(event_data);

/********** Phase 3 - Collect data stop and drop session **********/
DROP TABLE IF EXISTS #ExEventsData
SELECT CAST(target_data as xml) AS targetdata
INTO #ExEventsData
FROM sys.dm_xe_session_targets xet
JOIN sys.dm_xe_sessions xes
    ON xes.address = xet.event_session_address
WHERE xes.name = 'Test_Mich'
  AND xet.target_name = 'ring_buffer';

ALTER EVENT SESSION Test_Mich ON SERVER STATE = STOP;

DROP EVENT SESSION Test_Mich ON SERVER;

/********** Phase 4 - Query output table **********/
SELECT xed.event_data.value('(@name)[1]', 'varchar(100)') AS [event],
	xed.event_data.value('(@timestamp)[1]', 'datetime2') AS [timestamp],
	xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'varchar(25)') AS ApplicationName,
	CASE WHEN xed.event_data.value('(data[@name="statement"]/value)[1]', 'varchar(max)') IS NOT NULL
		THEN xed.event_data.value('(data[@name="statement"]/value)[1]', 'varchar(max)') 
		ELSE xed.event_data.value('(action[@name="sql_text"]/value)[1]', 'varchar(max)') 
	END AS [Text],
	xed.event_data.value('(action[@name="session_id"]/value)[1]', 'varchar(25)') AS SPID,
	xed.event_data.value('(action[@name="server_principal_name"]/value)[1]', 'varchar(25)') AS [Login],
	xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(25)') AS DatabaseName,
	xed.event_data.value('(action[@name="client_pid"]/value)[1]', 'varchar(25)') AS ClientProcessId,
	xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'varchar(25)') AS HostName,
	xed.event_data.value('(data[@name="cpu_time"]/value)[1]', 'int') AS CPU,
	xed.event_data.value('(data[@name="logical_reads"]/value)[1]', 'int') AS Reads,
	xed.event_data.value('(data[@name="writes"]/value)[1]', 'int') AS Writes,
	xed.event_data.value('(data[@name="duration"]/value)[1]', 'int') AS Duration
FROM #ExEventsData
    CROSS APPLY targetdata.nodes('//RingBufferTarget/event') AS xed(event_data);
