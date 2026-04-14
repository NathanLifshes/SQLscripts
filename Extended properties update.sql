/*
partners-dbo-ssdt  => partnersservices-dbo-ssdt
partners-openapi-funding => partnersadmin-openapi-funding
partners-partner-details-api => partnersadmin-partner-details-api
partners-tax-forms-service => partnersadmin-tax-forms-service

('partners-dbo-ssdt','partners-openapi-funding','partners-partner-details-api','partners-tax-forms-service')
('partnersservices-dbo-ssdt','partnersadmin-openapi-funding','partnersadmin-partner-details-api','partnersadmin-tax-forms-service')
*/

USE Payments_Gen2
GO
SELECT e.name,
       e.value,
       o.type,
	   o.type_desc,
       o.name,
       'Payments_Gen2',
       'USE Payments_Gen2; EXEC sp_updateextendedproperty @name = ''SSDT_repo'', @value = ' + CASE e.value
                                                                               WHEN 'partners-dbo-ssdt' THEN '''partnersservices-dbo-ssdt'''
																			   WHEN 'partners-openapi-funding' THEN '''partnersadmin-openapi-funding'''
																			   WHEN 'partners-partner-details-api' THEN '''partnersadmin-partner-details-api'''
																			   WHEN 'partners-tax-forms-service' THEN '''partnersadmin-tax-forms-service'''
																			   ELSE ''' '''
                                                                           END
       + ', @level0type = ''SCHEMA'', @level0name = ''dbo'', @level1type = '+ CASE o.type WHEN 'P' THEN '''PROCEDURE''' WHEN 'U' THEN '''TABLE''' WHEN 'TR' THEN '''TRIGGER''' ELSE '' END+', @level1name = ''' + o.name
       + ''''
FROM Payments_Gen2.sys.extended_properties e
    INNER JOIN Payments_Gen2.sys.objects o
        ON e.major_id = o.object_id
WHERE o.schema_id = SCHEMA_ID('dbo')
      AND e.name = 'SSDT_repo'
      AND CONVERT(NVARCHAR(500), e.[value]) IN ('partners-dbo-ssdt','partners-openapi-funding','partners-partner-details-api','partners-tax-forms-service')
GO	
/**/ 

USE Payouts
GO
SELECT e.name,
       e.value,
       o.type,
	   o.type_desc,
       o.name,
       'PayOuts',
       'USE PayOuts; EXEC sp_updateextendedproperty @name = ''SSDT_repo'', @value = ' + CASE e.value
                                                                               WHEN 'partners-dbo-ssdt' THEN '''partnersservices-dbo-ssdt'''
																			   WHEN 'partners-openapi-funding' THEN '''partnersadmin-openapi-funding'''
																			   WHEN 'partners-partner-details-api' THEN '''partnersadmin-partner-details-api'''
																			   WHEN 'partners-tax-forms-service' THEN '''partnersadmin-tax-forms-service'''
																			   ELSE ''' '''
                                                                           END
       + ', @level0type = ''SCHEMA'', @level0name = ''dbo'', @level1type = '+ CASE o.type WHEN 'P' THEN '''PROCEDURE''' WHEN 'U' THEN '''TABLE''' WHEN 'TR' THEN '''TRIGGER''' ELSE '' END+', @level1name = ''' + o.name
       + ''''
FROM PayOuts.sys.extended_properties e
    INNER JOIN PayOuts.sys.objects o
        ON e.major_id = o.object_id
WHERE o.schema_id = SCHEMA_ID('dbo')
      AND e.name = 'SSDT_repo'
      AND CONVERT(NVARCHAR(500), e.[value]) IN ('partners-dbo-ssdt','partners-openapi-funding','partners-partner-details-api','partners-tax-forms-service')
GO	
/**/ 

USE Administration_Gen2
GO
SELECT e.name,
       e.value,
       o.type,
	   o.type_desc,
       o.name,
       'Administration_Gen2',
       'USE Administration_Gen2; EXEC sp_updateextendedproperty @name = ''SSDT_repo'', @value = ' + CASE e.value
                                                                               WHEN 'partners-dbo-ssdt' THEN '''partnersservices-dbo-ssdt'''
																			   WHEN 'partners-openapi-funding' THEN '''partnersadmin-openapi-funding'''
																			   WHEN 'partners-partner-details-api' THEN '''partnersadmin-partner-details-api'''
																			   WHEN 'partners-tax-forms-service' THEN '''partnersadmin-tax-forms-service'''
																			   ELSE ''' '''
                                                                           END
       + ', @level0type = ''SCHEMA'', @level0name = ''dbo'', @level1type = '+ CASE o.type WHEN 'P' THEN '''PROCEDURE''' WHEN 'U' THEN '''TABLE''' WHEN 'TR' THEN '''TRIGGER''' ELSE '' END+', @level1name = ''' + o.name
       + ''''
FROM Administration_Gen2.sys.extended_properties e
    INNER JOIN Administration_Gen2.sys.objects o
        ON e.major_id = o.object_id
WHERE o.schema_id = SCHEMA_ID('dbo')
      AND e.name = 'SSDT_repo'
      AND CONVERT(NVARCHAR(500), e.[value]) IN ('partners-dbo-ssdt','partners-openapi-funding','partners-partner-details-api','partners-tax-forms-service')
GO	
/**/ 

USE PayoneerIPCN
GO
SELECT e.name,
       e.value,
       o.type,
	   o.type_desc,
       o.name,
       'PayoneerIPCN',
       'USE PayoneerIPCN; EXEC sp_updateextendedproperty @name = ''SSDT_repo'', @value = ' + CASE e.value
                                                                               WHEN 'partners-dbo-ssdt' THEN '''partnersservices-dbo-ssdt'''
																			   WHEN 'partners-openapi-funding' THEN '''partnersadmin-openapi-funding'''
																			   WHEN 'partners-partner-details-api' THEN '''partnersadmin-partner-details-api'''
																			   WHEN 'partners-tax-forms-service' THEN '''partnersadmin-tax-forms-service'''
																			   ELSE ''' '''
                                                                           END
       + ', @level0type = ''SCHEMA'', @level0name = ''dbo'', @level1type = '+ CASE o.type WHEN 'P' THEN '''PROCEDURE''' WHEN 'U' THEN '''TABLE''' WHEN 'TR' THEN '''TRIGGER''' ELSE '' END+', @level1name = ''' + o.name
       + ''''
FROM PayoneerIPCN.sys.extended_properties e
    INNER JOIN PayoneerIPCN.sys.objects o
        ON e.major_id = o.object_id
WHERE o.schema_id = SCHEMA_ID('dbo')
      AND e.name = 'SSDT_repo'
      AND CONVERT(NVARCHAR(500), e.[value]) IN ('partners-dbo-ssdt','partners-openapi-funding','partners-partner-details-api','partners-tax-forms-service')
GO	
/**/
