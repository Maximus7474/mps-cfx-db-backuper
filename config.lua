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
		Enabled = false,

		-- How long should a backup be store for, set to false to disable
		--[[ Accepted values:
			- day length: 7d, 6d, 5d, etc...
			- hour length: 20h, 50h, 100h, etc...
		]]
		ClearAfter = "7d",
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
