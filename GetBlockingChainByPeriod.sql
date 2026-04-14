 /**********************  Blockings current day *****************************/

 
EXEC DBA.dbo.GetBlockingChainByPeriod @StartTime = '2024-06-02 00:30',
                                      @EndTime =   '2024-06-02 00:50',
									  --@GetCountOfBlockingsPerMin = 1,
									  --@Include = 1, @LoginNames = 'PAYSQL\AppUser_WBO'
									  @Exclude = 1,
									  @LoginNames = 'PAYSQL\AppUser_SCHEX';



/**********************  Blockings for last 10 minutes *****************************/



DECLARE @DateStart DATETIME =DATEADD(HOUR ,-4,GETDATE())
DECLARE @DateEnd DATETIME =GETDATE()
EXEC DBA.dbo.GetBlockingChainByPeriod @StartTime = @DateStart,
                                      @EndTime = @DateEnd,
									  --@GetCountOfBlockingsPerMin = 1,
									  @INCLUDE = 1, @LOGINNAMES = 'PAYSQL\AppUser_WBOPARTNER'
									  @Exclude = 1,
									  @LoginNames = 'PAYSQL\SQLSVC';




/**********************  Investigations *****************************/



DECLARE @Date DATETIME;
SELECT @Date = DATEADD(HOUR, -1, GETDATE()); --add 3 hours in case timestamp is taken from email
--SET @Date = '2024-06-02 00:35'
--SELECT @Date, GETDATE()

SELECT --TOP 1000
       wia.collection_time,
       *
FROM DBA_Local.dbo.WhoIsActiveLocal AS wia
WHERE wia.collection_time > DATEADD(MINUTE, -1, @Date)
      AND wia.collection_time < DATEADD(MINUTE, 4, @Date)
      --AND wia.login_name <> 'pay_report_user'
      AND wia.login_name = 'PAYSQL\AppUser_WBOANG'
	  --AND wia.session_id = 601
      --AND wia.login_name <> 'PAYSQL\AppUser_SCHEX'
	  --AND wia.login_name='elenako'
	  --AND CAST(wia.sql_text AS VARCHAR(MAX)) LIKE '%SavePartnerCardChargeRequestWrp%'
	  --AND wia.database_name = 'PayoneerMailing'
ORDER BY wia.collection_time,
         wia.session_id;

/**/

SELECT 
       wia.collection_time, *
FROM DBA_Local.dbo.WhoIsActiveLocal AS wia
WHERE wia.collection_time > DATEADD(HOUR, -4, GETDATE())
--AND wia.program_name = 'CommunicationDetailsService'
--AND CAST(wia.sql_text AS VARCHAR(MAX)) LIKE '%BO_SetPartnerFees%'
AND wia.login_name = 'PAYSQL\AppUser_WBOPARTNER'
ORDER BY wia.collection_time desc,
         wia.session_id;

/**/

EXEC dbo.sp_WhoIsActive 
                        @not_filter_type = 'login',
                        @not_filter = 'PAYSQL\AppUser_SCHEX',
                        @show_sleeping_spids = 0;

EXEC dbo.sp_WhoIsActive @filter_type = 'login', @filter = 'PAYSQL\AppUser_CDS'

/**/

SELECT TOP 100 *
FROM DBA..DeadlocksCollection AS dc
--WHERE dc.DeadlockSignature like '%fees%'
WHERE dc.VictimApp LIKE '%wbopartner%'
ORDER BY dc.DeadlockStartTime DESC

SELECT GETDATE()