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

	-- Messy function for what it is, yes I agree
	-- the initial stage here sorts all backups in an array,
	-- this then allows us to guarantee that the system will always
	-- keep the minimum wanted backup files

    local backups = {}
    for fileName, timestamp in pairs(self.data) do
        table.insert(backups, { name = fileName, time = timestamp })
    end

    local totalBackups, keepMin = #backups, self.config.KeepMinimum

    table.sort(backups, function(a, b)
        return a.time < b.time
    end)

    local curTimestamp, deletedCount = os.time(), 0
    for _, fileData in ipairs(backups) do
        local timeGap = os.difftime(curTimestamp, fileData.time)

        if timeGap >= self.clearDelay then
            if (totalBackups - deletedCount) > keepMin then
                print(string.format('[ARCHIVER] Deleting expired backup: ^3%s^7', fileData.name))

                exports[GetCurrentResourceName()]:DeleteBackup(fileData.name)

                self.data[fileData.name] = nil
                deletedCount += 1
            else
                print(string.format('[ARCHIVER] Skipping deletion of ^3%s^7 to maintain KeepMinimum (%s)', fileData.name, keepMin))
                break
            end
        end
    end

    if deletedCount > 0 then
        self:SaveArchiveData()
        print(string.format('[ARCHIVER] Cleanup complete. Deleted %s file(s).', deletedCount))
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
