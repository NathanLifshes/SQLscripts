USE applications

SELECT  q.query_id
       ,t.query_sql_text
       ,OBJECT_NAME(q.object_id) AS parent_object
       ,q.initial_compile_start_time
       ,q.last_compile_start_time
       ,q.last_execution_time
       ,q.count_compiles
FROM    sys.query_store_query_text t
INNER JOIN    sys.query_store_query q
        ON t.query_text_id = q.query_text_id
WHERE   
--t.query_sql_text LIKE  N'%MT_RegisteriACHPayee%'
OBJECT_NAME(q.object_id) = 'BOGetPartnerInfoALL'
ORDER BY q.last_execution_time DESC;   
GO

SELECT  t.query_sql_text
       ,q.query_id
       ,p.plan_id
       ,OBJECT_NAME(q.object_id) AS parent_object
       ,p.initial_compile_start_time
       ,p.last_compile_start_time
       ,p.last_execution_time
       ,p.count_compiles
FROM    sys.query_store_query_text t
JOIN    sys.query_store_query q
        ON t.query_text_id = q.query_text_id
JOIN    sys.query_store_plan p
        ON q.query_id = p.query_id
WHERE   q.query_id IN (199538839)
ORDER BY p.last_execution_time DESC;
 -- The following query returns information about queries and plans in the query store in current database.

SELECT Txt.query_text_id
      ,OBJECT_NAME(Qry.object_id) AS OBjectName
      ,Txt.query_sql_text
      ,Pl.plan_id
      ,Qry.query_id
         ,Pl.query_plan
         ,Pl.is_forced_plan
FROM   sys.query_store_plan AS Pl
JOIN   sys.query_store_query AS Qry
       ON Pl.query_id = Qry.query_id
JOIN   sys.query_store_query_text AS Txt
       ON Qry.query_text_id = Txt.query_text_id
WHERE  Pl.is_forced_plan = 1 /*
--It can be forced by a procedure as well: EXEC sys.sp_query_store_force_plan @query_id = 457, @plan_id = 430; --Or it can be unforced: EXEC sys.sp_query_store_unforce_plan @query_id = 457, @plan_id = 430;
*/