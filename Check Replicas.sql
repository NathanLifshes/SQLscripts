

EXEC dba.[dbo].[CheckReplicaLag]

EXEC Applications.[REPLS].[GetReplicaState]

/**/

EXEC dbo.sp_WhoIsActive --@get_plans = 1,
                        --@get_transaction_info = 1,
                        @not_filter_type = 'login',
                        @not_filter = 'PAYSQL\AppUser_SCHEX',
                        @show_sleeping_spids = 0;