SELECT TOP 10 *
FROM WavesBI..sys_Sessions
ORDER BY StartTime DESC

SELECT * 
FROM WavesBI..sys_SessionsDetails 
WHERE SessionID = (
                SELECT TOP 1 SessionID
                FROM WavesBI..sys_Sessions
				WHERE Is_Full = 1
                ORDER BY StartTime DESC
                )
ORDER BY TotalElapsedTimeInSeconds DESC
