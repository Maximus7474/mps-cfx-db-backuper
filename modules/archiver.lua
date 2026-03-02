Archiver = {
	data = {},
	clearDelay = nil,
	config = {},
}

---save a text payload to a sql file
---@param fileName string
---@param payload string
function Archiver:SaveFile(fileName, payload)
	local path = string.format('backups/%s.sql', fileName)
	SaveResourceFile(GetCurrentResourceName(), path, payload, -1)

	Archiver:StoreFileMetdata(string.format('%s.sql', fileName))
end

---store the creation timestamp of a backup
---@param fileName string
function Archiver:StoreFileMetdata(fileName)
	self.data[fileName] = os.time()
	self:SaveArchiveData()
end

function Archiver:Initialize()
	self.config = Config.Archiver
	self:LoadArchiveData()

	-- cleanup the inputted parameter
	local clearValue = tostring(self.config.ClearAfter):lower():gsub("%s+", "")
	local amount, unit = clearValue:match("(%d+)([dh])")
    amount = tonumber(amount)

	if not amount or not unit then
		error(string.format(
			"[ARCHIVER]: Invalid 'ClearAfter' value provided: '%s'\n" ..
			"Expected Format: A number followed by 'd', 'h', or 'm' (e.g., '7d', '24h', '30m').\n" ..
			"Current Setting: Check your Config.Archiver.ClearAfter setting.",
			tostring(clearValue)
		))
	end

    local multipliers = {
        ["d"] = 86400,
        ["h"] = 3600,
    }

	self.clearDelay = amount * multipliers[unit]

	Archiver:ClearExpiredBackups()
end

function Archiver:ClearExpiredBackups()
	if not self.config.Enabled then return end

	local curTimestamp, changesMade = os.time(), 0
	for fileName, timestamp in pairs(self.data) do
		local timeGap = os.difftime(curTimestamp, timestamp)

		if timeGap >= self.clearDelay then
			print(string.format('[ARCHIVER] Deleting backup "^3%s^7" being considered as expired...', fileName))

			exports[GetCurrentResourceName()]:DeleteBackup(fileName)

			self.data[fileName] = nil

			changesMade += 1
		end
	end

	if changesMade > 0 then
		self:SaveArchiveData()
	end
end

---load archive data from kvp
function Archiver:LoadArchiveData()
	local data = GetResourceKvpString('archivedata')

	if not data then return end

	local parsedData = json.decode(data)
	self.data = parsedData
end

---save archive data to kvp
function Archiver:SaveArchiveData()
	SetResourceKvp('archivedata', json.encode(self.data))
end

CreateThread(function ()
	Archiver:Initialize()
end)
