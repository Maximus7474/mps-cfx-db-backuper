RegisterCommand('backup_database', function (source, args)
	if source ~= 0 then return end

	local fileName = args[1] or BackupFileName()

	print(string.format('Saving database backup to: "^3%s^7"', fileName))

	local payload = DB:CreateFullBackup()
	Archiver:SaveFile(fileName, payload)

	print('Database backup finished successfully')
end, true)

if Config.Cron.Enabled then
	LoadOxLib()

	local Cron = Config.Cron
	local cronExpression
	if Cron.ExpressionOverride then
		cronExpression = Cron.ExpressionOverride
	else
		local expression = Cron.Frequency == 'daily' and '0 %d * * *' or '* */%d * * *'

		cronExpression = string.format(
			expression,
			Cron.Interval
		)
	end

	lib.cron.new(cronExpression, function ()
		local fileName = BackupFileName()

		print(string.format('[CRON] Saving database backup "^3%s^7"', fileName))

		local payload = DB:CreateFullBackup()
		Archiver:SaveFile(fileName, payload)

		Archiver:ClearExpiredBackups()
		print('[CRON] Database backup finished successfully')
	end)
end
