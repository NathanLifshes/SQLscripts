--1. All Objects:
 
DECLARE @command VARCHAR(MAX), @LastDate DATETIME;

/*This is temporary - you can get the date as a parameter*/
SET @LastDate = GETDATE()-7
 
SELECT @command = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'' , ''ZZZ_Applications_Clone'', ''ZZZ_DBA_Clone'', ''ZZZ_Harar_ExternalData_for_comparison'', ''ZZZ_Encryption_Clone'') BEGIN USE [?] 
   
-- Extract all objects:
 
-- Basic object details:
SELECT 
                obj.object_id, 
                db_id() as ''database_id'',
                obj.schema_id, 
                db_name() as ''database_name'', 
                OBJECT_SCHEMA_NAME(obj.object_id) AS ''schema'',
                obj.NAME as ''name'', 
                type,
                type_desc,
                create_date,
                modify_date,
                parent_object_id             
                --,obj.*
FROM 
                sys.all_objects obj
WHERE 
                -- Ignore PK, unique keys, defaults:
                TYPE NOT IN (''PK'', ''UQ'' , ''D'' )
 
                /* !!!!! CONSULT WITH NOAM !!!!!! */
                AND is_ms_shipped = 0

				/* This is filter the Last Date */
				AND modify_date >= '''+ CAST(@LastDate AS VARCHAR(50)) +'''
                
                --AND parent_object_id > 0
--ORDER BY type
 
--RETURN;   
   END' 
 
EXEC sp_MSforeachdb @command