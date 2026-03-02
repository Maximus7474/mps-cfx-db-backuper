RegisterCommand('backup_database', function (source, args)
	if source ~= 0 then return end

	local fileName = args[1] or BackupFileName()
	local backupPath = string.format('backups/%s.sql', fileName)

	print(string.format('Saving database backup to: "^3%s^7"', backupPath))

	local payload = DB:CreateFullBackup()
	SaveResourceFile(GetCurrentResourceName(), backupPath, payload, -1)
end, true)

if Config.Cron.Enabled then
	LoadOxLib()

	local cronExpression
	if Config.Cron.ExpressionOverride then
		cronExpression = Config.Cron.ExpressionOverride
	else
		cronExpression = string.format(
			'0 %d %d * *',
			Config.Cron.Hour,
			Config.Cron.DayFrequency
		)
	end

	lib.cron.new(cronExpression, function (task, date)
		local fileName = BackupFileName()
		local backupPath = string.format('backups/%s.sql', fileName)

		print(string.format('[CRON] Saving database backup "^3%s^7"', fileName))

		local payload = DB:CreateFullBackup()
		SaveResourceFile(GetCurrentResourceName(), backupPath, payload, -1)
	end)
end
