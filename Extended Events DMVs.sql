
SELECT * FROM sys.dm_xe_sessions
WHERE name = 'trace_CardholderSupportLog_SPWrites'

-- Session level information for current Event Sessions
SELECT
   s.name,
   s.max_memory,
   s.event_retention_mode_desc,
   s.max_dispatch_latency,
   s.max_event_size,
   s.memory_partition_mode_desc,
   s.track_causality,
   s.startup_state
FROM sys.server_event_sessions AS s
WHERE name = 'trace_CardholderSupportLog_SPWrites'

-- Get events in a session
SELECT
   ses.name AS session_name,
   sese.package AS event_package,
   sese.name AS event_name,
   sese.predicate AS event_predicate
FROM sys.server_event_sessions AS ses
INNER JOIN sys.server_event_session_events AS sese
    ON ses.event_session_id = sese.event_session_id
WHERE ses.name = 'trace_CardholderSupportLog_SPWrites'


-- Get actions 
SELECT
   ses.name AS session_name,
   sese.package AS event_package,
   sese.name AS event_name,
   sese.predicate AS event_predicate,
   sesa.package AS action_package,
   sesa.name AS action_name
FROM sys.server_event_sessions AS ses
INNER JOIN sys.server_event_session_events AS sese
    ON ses.event_session_id = sese.event_session_id
INNER JOIN sys.server_event_session_actions AS sesa
     ON ses.event_session_id = sesa.event_session_id
    AND sese.event_id = sesa.event_id
WHERE ses.name = 'trace_CardholderSupportLog_SPWrites'

-- Get target information
SELECT
   ses.name AS session_name,
   sest.name AS target_name
FROM sys.server_event_sessions AS ses
INNER JOIN sys.server_event_session_targets AS sest
   ON ses.event_session_id = sest.event_session_id
WHERE ses.name = 'trace_CardholderSupportLog_SPWrites'

-- Get target option information
SELECT
   ses.name AS session_name,
   sest.name AS target_name,
   sesf.name AS option_name,
   sesf.value AS option_value
FROM sys.server_event_sessions AS ses
INNER JOIN sys.server_event_session_targets AS sest
   ON ses.event_session_id = sest.event_session_id
INNER JOIN sys.server_event_session_fields AS sesf
   ON sest.event_session_id = sesf.event_session_id
   AND sest.target_id = sesf.object_id
WHERE ses.name = 'trace_CardholderSupportLog_SPWrites'

-- Look at Active Session Information
SELECT
   s.name, 
   s.pending_buffers,
   s.total_regular_buffers,
   s.regular_buffer_size,
   s.total_large_buffers,
   s.large_buffer_size,
   s.total_buffer_size,
   s.buffer_policy_flags,
   s.buffer_policy_desc,
   s.flags,
   s.flag_desc,
   s.dropped_event_count,
   s.dropped_buffer_count,
   s.blocked_event_fire_time,
   s.create_time,
   s.largest_event_dropped_size
FROM sys.dm_xe_sessions AS s
WHERE s.name = 'trace_CardholderSupportLog_SPWrites'

-- Target information for a running session
SELECT
   s.name AS session_name,
   t.target_name AS target_name,
   t.execution_count AS execution_count,
   t.execution_duration_ms AS execution_duration,
   CAST(t.target_data AS XML) AS target_data,
   convert(DECIMAL(18,2), round(t.bytes_written / 1024.0 / 1024.0, 2)) AS MB_written
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_targets AS t
   ON s.address = t.event_session_address
WHERE s.name = 'trace_CardholderSupportLog_SPWrites'

-- Event Information for a running session
SELECT s.name AS session_name,
       e.event_name AS event_name,
       e.event_predicate AS event_predicate
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_events AS e
     ON s.address = e.event_session_address
WHERE s.name = 'trace_CardholderSupportLog_SPWrites'

-- Event Information with Actions for a running session
SELECT s.name AS session_name,
       e.event_name AS event_name,
       e.event_predicate AS event_predicate,
       ea.action_name AS action_name
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_events AS e
     ON s.address = e.event_session_address
INNER JOIN sys.dm_xe_session_event_actions AS ea
     ON e.event_session_address = ea.event_session_address
    AND e.event_name = ea.event_name
WHERE s.name = 'trace_CardholderSupportLog_SPWrites'


-- Configurable event and target column information
SELECT DISTINCT s.name AS session_name, 
       oc.OBJECT_NAME, 
       oc.object_type, 
       oc.column_name, 
       oc.column_value
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_targets AS t
     ON s.address = t.event_session_address
INNER JOIN sys.dm_xe_session_events AS e
     ON s.address = e.event_session_address
INNER JOIN sys.dm_xe_session_object_columns AS oc
     ON s.address = oc.event_session_address
       AND ((oc.object_type = 'target' AND t.target_name = oc.object_name) 
       OR (oc.object_type = 'event' AND e.event_name = oc.object_name))
WHERE s.name = 'trace_CardholderSupportLog_SPWrites'
