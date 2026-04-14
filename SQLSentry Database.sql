USE SentryOne
GO

SELECT TOP (100) NormalizedStartTime, CAST(Duration / 10000000.0 AS DECIMAL(5,2)) AS Duration
FROM dbo.vwMetaHistorySqlServerTraceLog
WHERE MessageText LIKE '%REP_Transfer_Method_Transactions%'
AND NormalizedStartTime > GETDATE()-2
ORDER BY NormalizedStartTime DESC

SELECT NormalizedStartTime, CAST(Duration / 10000000.0 AS DECIMAL(5,2)) AS Duration
,CAST(AVG(Duration / 10000000.0 ) OVER (ORDER BY NormalizedStartTime ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)AS DECIMAL(5,2)) AvgDuration 
,MessageText, Operator, RunStatus
FROM dbo.vwMetaHistorySqlServerTraceLog
WHERE MessageText LIKE '%REP_Transfer_Method_Transactions%'
--AND MessageText NOT LIKE '%@AlertFilterMatchEntityID=NULL%'
--AND NormalizedStartTime > GETDATE()-2
--AND RunStatus = -1
AND Operator <> 'nathanli'
ORDER BY NormalizedStartTime DESC

SELECT NormalizedStartTime, CAST(Duration / 10000000.0 AS DECIMAL(5,2)) AS Duration
,CAST(AVG(Duration / 10000000.0 ) OVER (ORDER BY NormalizedStartTime ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)AS DECIMAL(5,2)) AvgDuration 
,MessageText, Operator, RunStatus, Application
FROM dbo.vwMetaHistorySqlServerTraceLog
WHERE MessageText LIKE '%BO_GetInitiatorAliases%'
--AND MessageText NOT LIKE '%@AlertFilterMatchEntityID=NULL%'
AND NormalizedStartTime > GETDATE()-2
--AND RunStatus = -1
AND Operator <> 'nathanli'
ORDER BY NormalizedStartTime DESC

SELECT NormalizedStartTime, CAST(Duration / 10000000.0 AS DECIMAL(10,2)) AS Duration
,MessageText, Operator, RunStatus, Application, StartTime, EndTime
FROM dbo.vwMetaHistorySqlServerTraceLog
WHERE MessageText LIKE '%REP_Transfer_Method_Transactions%'
AND StartTime > GETDATE()-2
ORDER BY NormalizedStartTime DESC

/**/


SELECT TOP (100) * FROM DBA.dbo.ServersPerDBA                WHERE DBALogin = 'nathanli'
SELECT TOP (100) * FROM DBA.dbo.ReportsConfigurationPerDBA    WHERE DBALogin = 'nathanli'
SELECT TOP (100) * FROM DBA.dbo.MonitoredLoginsPerDBA        WHERE DBALogin = 'nathanli'
SELECT TOP (100) * FROM DBA.dbo.SchemasPerDBA                WHERE DBALogin = 'nathanli'

--SELECT * FROM DBA.dbo.SchemasPerDBA
--WHERE SchemaName IN ('ADM','PNS','PSUPT','PUM','PUS')

--INSERT INTO DBA.dbo.SchemasPerDBA
--VALUES  ('nathanli','Applications ','ADM'), 
--		('nathanli','Applications ','PNS'),
--		('nathanli','Applications ','PSUPT'),
--		('nathanli','Applications ','PUM'),
--		('nathanli','Applications ','PUS')

--SELECT * FROM DBA.dbo.MonitoredLoginsPerDBA
--WHERE DBALogin = 'nathanli' AND 
--AppLoginName IN ('PAYSQL\AppUser_BLA','paysql\AppUser_BSQA','paysql\AppUser_RM')

/**/
USE SQLSentry
GO
SELECT tl.StartTime,
       esc.ServerName,
	   tl.Computer,
       CAST(Duration / 10000000.0 AS DECIMAL(10, 2)) AS Duration,
       MessageText,
       Operator,
       RunStatus,
       Application,
       tl.StartTime,
       EndTime,
	   tl.*
FROM dbo.vwMetaHistorySqlServerTraceLog tl
    INNER JOIN dbo.EventSource (NOLOCK) es
        ON tl.EventSourceID = es.ObjectID
    INNER JOIN dbo.EventSourceConnection (NOLOCK) esc
        ON es.EventSourceConnectionID = esc.ObjectID
WHERE 1=1
	--AND tl.Operator != 'nathanli'
	AND MessageText LIKE '%BOGetPartnerInfoALL%'
	--AND (MessageText LIKE '%BO_GetPermissionDataForAllUsers%' OR MessageText LIKE '%BO_GetPermissionRolesExtended%')
	--AND tl.Application = 'SQLAgent - TSQL JobStep (Job 0xFDEBB4EB44FE7E4E85516F79AC58B6A6 : Step 2)'
	--AND Operator = 'PAYSQL\AppUser_WBOMASS'
      AND tl.StartTime > GETDATE() - 1
	  --AND esc.ServerName LIKE '%HRZ%'
ORDER BY tl.StartTime DESC;
SELECT GETDATE()
/**/

--SELECT tl.RemoteObjectID AS EventType,
--th.NormalizedTextData,
--tl.[Database],
--tl.Computer AS ClientComputer,
--tl.Application,
--tl.Operator AS UserName,
--(tl.Duration/10000000) AS Duration,
--tl.CPU,
--tl.Reads,
--tl.Writes,
--tl.RunStatus,
--FORMAT(DATEADD(mi, DATEDIFF(mi,GETDATE() ,GETUTCDATE()), tl.StartTime),'yyyyMMdd')+'T'+FORMAT(DATEADD(mi, DATEDIFF(mi, GETDATE(),GETUTCDATE() ), tl.StartTime),'HHmmss')+'.000Z' AS EventTime,
--CASE
--WHEN th.NormalizedTextData LIKE '%trace_getdata%' THEN 'Monitoring'
--WHEN th.NormalizedTextData LIKE '%BACKUP%' THEN 'Maintenance'
--WHEN th.NormalizedTextData LIKE '%STATISTICS%' THEN 'Maintenance'
--WHEN th.NormalizedTextData LIKE '%INDEX%' THEN 'Maintenance'
--WHEN th.NormalizedTextData LIKE '%updatestats%' THEN 'Maintenance'
--WHEN th.NormalizedTextData LIKE '%sys.%' THEN 'Monitoring'
--WHEN th.NormalizedTextData LIKE '%repl%' THEN 'Replication'
--WHEN th.NormalizedTextData LIKE '%sp_server_diagnostics%' THEN 'Monitoring'
--WHEN th.NormalizedTextData LIKE '%sp_readrequest%' THEN 'Replication'
--WHEN th.NormalizedTextData LIKE '%sp_MSdistribution%' THEN 'Replication'
--WHEN th.NormalizedTextData LIKE '%syncobj_%' THEN 'Replication'
--WHEN th.NormalizedTextData LIKE '%waitfor delay @waittime%' THEN 'CDC'
--ELSE 'Application Query'
--END AS QueryType,
--esc.ObjectName AS ServerName
--FROM dbo.vwMetaHistorySqlServerTraceLog (nolock) tl
--INNER JOIN dbo.PerformanceAnalysisTraceHash (nolock) th ON tl.NormalizedTextMD5 = th.NormalizedTextMD5
--INNER JOIN EventSource (nolock) es ON tl.EventSourceId = es.ObjectId
--INNER JOIN EventSourceConnection (nolock) esc ON es.EventSourceConnectionID = esc.ObjectId
--WHERE (esc.ObjectName LIKE 'SRV%') AND
--tl.StartTime >= @EventStartTime AND
--tl.StartTime < @EventEndTime


SELECT TOP (100) * FROM SQLSentry.dbo.ProcedureStats
WHERE ObjectName = 'REP_Connections'

SELECT TOP (100) * FROM SQLSentry.dbo.ProcedureStatsHistory
WHERE ProcedureStatsID IN (4376992)

/**/

SELECT          ProcedureStats.ID
               ,ProcedureStats.EventSourceConnectionID
               --,#EventSourceConnectionIDs.ObjectName AS EventSourceConnectionName
               ,ProcedureStats.SqlHandle
               ,ProcedureStats.PlanHandle
               ,ProcedureStats.PerformanceAnalysisTraceCachedPlansID
               ,ProcedureStats.DatabaseID
               ,ProcedureStats.DatabaseName
               ,ProcedureStats.ObjectID
               ,ProcedureStats.ObjectName
               ,ProcedureStats.ObjectNameHash
               ,History.ProcedureStatsID
               ,History.TotalCPU
               ,History.TotalLogicalReads
               ,History.TotalLogicalWrites
               ,History.TotalPhysicalReads
               ,History.HistoryCount
               ,History.TotalExecutionCount
               ,History.TotalElapsedTime
               ,History.StartTimeUtc
               ,History.EndTimeUtc
               --,PerformanceAnalysisTraceHash.NormalizedTextData
               --,CASE WHEN vwDistinctPerformanceAnalysisTraceHashHidden.NormalizedTextMD5 IS NULL THEN 1
               --      ELSE 0
               -- END AS IsVisible
--INTO            #FullResults
FROM            SQLSentry.dbo.ProcedureStats
INNER JOIN      (   SELECT   ProcedureStatsID
                            ,SUM(WorkerTimeDelta) / 1000 AS TotalCPU
                            ,SUM(LogicalReadsDelta) AS TotalLogicalReads
                            ,SUM(LogicalWritesDelta) AS TotalLogicalWrites
                            ,SUM(PhysicalReadsDelta) AS TotalPhysicalReads
                            ,COUNT(*) AS HistoryCount
                            ,SUM(ExecutionCountDelta) AS TotalExecutionCount
                            ,SUM(ElapsedTimeDelta) AS TotalElapsedTime
                            ,MIN(StartTimeUtc) AS StartTimeUtc
                            ,MAX(EndTimeUtc) AS EndTimeUtc
                    FROM     SQLSentry.dbo.ProcedureStatsHistory
                    --WHERE    (   (   StartTimeUtc >= @StartTimeUtc
                    --                 AND StartTimeUtc <= @EndTimeUtc )
                    --             OR (   EndTimeUtc >= @StartTimeUtc
                    --                    AND EndTimeUtc <= @EndTimeUtc )
                    --             OR (   StartTimeUtc <= @StartTimeUtc
                    --                    AND EndTimeUtc >= @EndTimeUtc ))
                    --         OR ( ProcedureStatsHistory.ProcedureStatsID = @ID )
                    GROUP BY ProcedureStatsID ) History
                ON History.ProcedureStatsID = ProcedureStats.ID
WHERE ObjectName = 'REP_Connections'

/**/


USE SQLSentry
GO
SELECT cast (StartTime AS DATE) dDate,
       COUNT(*)
FROM dbo.vwMetaHistorySqlServerTraceLog tl
    INNER JOIN dbo.EventSource (NOLOCK) es
        ON tl.EventSourceID = es.ObjectID
    INNER JOIN dbo.EventSourceConnection (NOLOCK) esc
        ON es.EventSourceConnectionID = esc.ObjectID
WHERE 1=1
	--AND tl.Operator = 'PAYSQL\AppUser_FUS'
	AND MessageText LIKE '%REP_Connections%'
	--AND (MessageText LIKE '%BO_GetPermissionDataForAllUsers%' OR MessageText LIKE '%BO_GetPermissionRolesExtended%')
	--AND tl.Application = 'SQLAgent - TSQL JobStep (Job 0xFDEBB4EB44FE7E4E85516F79AC58B6A6 : Step 2)'
      AND StartTime > GETDATE() - 7
	  --AND esc.ServerName LIKE '%HRZ%'
GROUP BY cast (StartTime AS DATE)
ORDER BY dDate DESC
