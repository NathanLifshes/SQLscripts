
-- Detect blocking (run multiple times)  (Query 40) (Detect Blocking)
SELECT     t1.resource_type                 AS [lock type]
         , DB_NAME (resource_database_id)   AS [database]
         , t1.resource_associated_entity_id AS [blk object]
         , t1.request_mode                  AS [lock req]    -- lock requested
         , t1.request_session_id            AS [waiter sid]
         , t2.wait_duration_ms              AS [wait time]   -- spid of waiter  
         , (
               SELECT      [text]
               FROM        sys.dm_exec_requests AS r WITH (NOLOCK) -- get sql for waiter
               CROSS APPLY sys.dm_exec_sql_text (r.[sql_handle])
               WHERE       r.session_id = t1.request_session_id
           )                                AS [waiter_batch]
         , (
               SELECT      SUBSTRING (
                                         qt.[text]
                                       , r.statement_start_offset / 2
                                       , (CASE
                                               WHEN r.statement_end_offset = -1 THEN
                                                   LEN (CONVERT (NVARCHAR(MAX), qt.[text])) * 2
                                               ELSE r.statement_end_offset
                                          END - r.statement_start_offset
                                         ) / 2
                                     )
               FROM        sys.dm_exec_requests                  AS r WITH (NOLOCK)
               CROSS APPLY sys.dm_exec_sql_text (r.[sql_handle]) AS qt
               WHERE       r.session_id = t1.request_session_id
           )                                AS [waiter_stmt] -- statement blocked
         , t2.blocking_session_id           AS [blocker sid] -- spid of blocker
         , (
               SELECT      [text]
               FROM        sys.sysprocesses AS p -- get sql for blocker
               CROSS APPLY sys.dm_exec_sql_text (p.[sql_handle])
               WHERE       p.spid = t2.blocking_session_id
           )                                AS [blocker_batch]
FROM       sys.dm_tran_locks       AS t1 WITH (NOLOCK)
INNER JOIN sys.dm_os_waiting_tasks AS t2 WITH (NOLOCK)
   ON      t1.lock_owner_address = t2.resource_address
OPTION (RECOMPILE);
------

EXEC sp_WhoIsActive @get_locks = 1
                  , @find_block_leaders = 1
				  --, @output_column_list = '[collection_time][dd%][session_id][sql_text][sql_command][database_name][host_name][login_name][program_name][wait_info][tasks][block%][locks]'
                  , @sort_order = '[blocked_session_count] DESC, [blocking_session_id] DESC'
				  , @show_system_spids = 1
				  , @get_full_inner_text = 1
				  , @get_outer_command = 1
				  , @get_transaction_info = 1
				  , @get_task_info = 1
				  , @get_additional_info = 1

EXEC ToolDB..sp_BlitzLock 
