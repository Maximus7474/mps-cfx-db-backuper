Config = {
	-- Maximum size of a query when creating a backup
	QuerySize = 100,

	Cron = {
		-- This REQUIRES ox_lib to be installed & running
		Enabled = false,

		-- Expression override, determine your own frequency (Advanced Knowledge Required)
		-- https://coxdocs.dev/ox_lib/Modules/Cron/Server#cron-expression
		-- ExpressionOverride = "0 0 * * *",

		-- Number of days between backups
		DayFrequency = 1,

		-- What hour of the day do you want the backup to occur at
		-- (24 hour format, accepts values between 0 and 23)
		Hour = 0,
	},

	-- Array of table names to not backup
	ExcludedTables = {
	-- 	'example_tablename',
	},

	-- Array of tables to backup, no other tables will be backed up !
	ExclusiveTables = {
	-- 	'users',
	},
}
