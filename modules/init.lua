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

	lib.cron.new(cronExpression, function (task, date)
		local fileName = BackupFileName()
		local backupPath = string.format('backups/%s.sql', fileName)

		print(string.format('[CRON] Saving database backup "^3%s^7"', fileName))

		local payload = DB:CreateFullBackup()
		SaveResourceFile(GetCurrentResourceName(), backupPath, payload, -1)
	end)
end
