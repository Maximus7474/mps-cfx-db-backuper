Config = {
	-- Maximum size of a query when creating a backup
	QuerySize = 100,

	Cron = {
		-- This REQUIRES ox_lib to be installed & running
		Enabled = false,

		-- Expression override, determine your own frequency (Advanced Knowledge Required)
		-- https://coxdocs.dev/ox_lib/Modules/Cron/Server#cron-expression
		-- ExpressionOverride = "0 0 * * *",

		-- Options: "daily" or "hourly"
		Frequency = "daily",

		-- If daily: What hour (0-23)
		-- If hourly: Every X hours (e.g., 2 = every 2 hours)
		Interval = 6,
	},

	-- Handles backup storage
	Archiver = {
		Enabled = true,

		-- How long to keep backups before auto-deletion.
		-- Format: <number><unit> | Units: 'd' (days), 'h' (hours)
		ClearAfter = "7d",

		-- Minimum number of backups to KEEP, regardless of age. 
		-- (Prevents your folder from being empty if no new backups run)
		KeepMinimum = 3,
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
