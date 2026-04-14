CREATE OR ALTER PROCEDURE WhateverProc
  @XMLResult xml OUTPUT
AS

SET @XMLResult = (
  SELECT name, type_desc
  FROM sys.objects
  FOR XML PATH('item'), ROOT('results')
  )
GO

DECLARE @XMLResult xml;
EXEC dbo.WhateverProc @XMLResult = @XMLResult OUTPUT -- xml
--SELECT @XMLResult

SELECT
name = x.value('(name)[1]','sysname'),
type_desc = x.value('(type_desc)[1]','nvarchar(max)')
FROM @XMLResult.nodes('results/item') AS t(x)
