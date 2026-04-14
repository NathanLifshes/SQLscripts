
SELECT
	ObjectName = N'Replica Server "' + ar.replica_server_name + N'" (' + ars.role_desc + N')',
	M.Msg
from sys.dm_hadr_availability_replica_states ars
inner join sys.availability_replicas ar on ars.replica_id = ar.replica_id
and ars.group_id = ar.group_id
CROSS APPLY
(
	SELECT N'Synchronization is: ' + ars.synchronization_health_desc
	WHERE ars.synchronization_health_desc <> 'HEALTHY'
	UNION ALL
	SELECT N'Operational State is: ' + ISNULL(ars.operational_state_desc, 'UNKNOWN')
	WHERE ars.operational_state_desc <> 'ONLINE'
	UNION ALL
	SELECT N'Connection is: ' + ars.connected_state_desc
	WHERE ars.connected_state_desc <> 'CONNECTED'
) AS M(Msg)
 
UNION ALL
 
select distinct
N'Replica Database "' + rcs.database_name + N'" in server "' + ar.replica_server_name + N'"',
M.Msg
from sys.dm_hadr_database_replica_states drs
inner join sys.availability_replicas ar on drs.replica_id = ar.replica_id
and drs.group_id = ar.group_id
inner join sys.dm_hadr_database_replica_cluster_states rcs on drs.replica_id = rcs.replica_id
CROSS APPLY
(
	SELECT N'Synchronization is: ' + drs.synchronization_health_desc
	WHERE drs.synchronization_health_desc <> 'HEALTHY'
	UNION ALL
	SELECT N'Data Movement is: ' + drs.synchronization_state_desc
	WHERE drs.synchronization_state_desc IN ('NOT SYNCHRONIZING', 'REVERTING')
) AS M(Msg)


SELECT 
	ar.replica_server_name,
	adc.database_name, 
	ag.name AS ag_name, 
	drs.is_local, 
	drs.is_primary_replica, 
	drs.synchronization_state_desc, 
	drs.is_commit_participant, 
	drs.synchronization_health_desc, 
	drs.recovery_lsn, 
	drs.truncation_lsn
FROM sys.dm_hadr_database_replica_states AS drs
INNER JOIN sys.availability_databases_cluster AS adc ON drs.group_id = adc.group_id AND drs.group_database_id = adc.group_database_id
INNER JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
INNER JOIN sys.availability_replicas AS ar ON drs.group_id = ar.group_id AND drs.replica_id = ar.replica_id
ORDER BY 
	ag.name, 
	ar.replica_server_name, 
	adc.database_name;
