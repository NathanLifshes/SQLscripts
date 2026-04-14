SELECT      TOP (10) @@SERVERNAME,
            last_elapsed_time / 1000000.0                                     last_elapsed_time_seconds
          --, S.plan_handle
		  , S.max_elapsed_time/ 1000000.0                                     max_elapsed_time_seconds
		  , S.EXECUTION_COUNT
		  , total_elapsed_time/ 1000000.0	total_elapsed_time
		  , total_elapsed_time / CAST(EXECUTION_COUNT AS DECIMAL) / 1000000.0 avg_elapsed_time_seconds
          , S.last_execution_time
          , OBJECT_NAME (t.objectid, t.dbid)                                  AS ObjectName
          , DB_NAME (t.dbid)                                                  AS DBName
          --, CAST(p.query_plan AS XML)                                         AS query_plan
FROM        sys.dm_exec_procedure_stats       S
CROSS APPLY sys.dm_exec_sql_text (sql_handle) t
OUTER APPLY sys.dm_exec_query_plan (plan_handle) p
--WHERE OBJECT_NAME(t.objectid, t.dbid) IS NOT NULL
WHERE OBJECT_NAME(t.objectid, t.dbid) IN ('BOGetPartnerInfoALL')
--WHERE (total_elapsed_time / CAST(execution_count AS DECIMAL) / 1000000.0) > 1
--WHERE DB_NAME (t.dbid) = 'Clean_FetchTables'
ORDER BY avg_elapsed_time_seconds DESC;
--SELECT GETDATE()

--DBCC FREEPROCCACHE (0x05000600A0CB9B73301E8C22F306000001000000000000000000000000000000000000000000000000000000)

SELECT      TOP (10)
            t.objectid
          , r.execution_count
		  , last_elapsed_time / 1000000.0                                     last_elapsed_time_seconds
          , total_elapsed_time / CAST(execution_count AS DECIMAL) / 1000000.0 avg_elapsed_time_seconds
          , r.last_execution_time
          , SUBSTRING (   text
                        , statement_start_offset / 2 + 1
                        , ((CASE
                                 WHEN statement_end_offset = -1 THEN DATALENGTH (text)
                                 ELSE statement_end_offset
                            END - statement_start_offset
                           ) / 2
                          ) + 1
                      )                                                       AS running_statement
          , text                                                              AS current_batch
          , OBJECT_NAME (t.objectid, t.dbid)
          , DB_NAME (t.dbid)                                                  AS DBName
          --p.query_plan,
          , CAST(p.query_plan AS XML)                                         AS query_plan
		--,r.*
FROM        sys.dm_exec_query_stats           r
CROSS APPLY sys.dm_exec_sql_text (sql_handle) t
--outer apply sys.dm_exec_query_plan(plan_handle) p
OUTER APPLY sys.dm_exec_text_query_plan (plan_handle, statement_start_offset, statement_end_offset) p
WHERE       OBJECT_NAME (t.objectid, t.dbid) IN ('GetPaymentRequestsPayerCustomerId')
ORDER BY avg_elapsed_time_seconds DESC;


/**/
SELECT @@SERVERNAME

