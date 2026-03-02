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

---clear archive data
function Archiver:ClearArchiveData()
	self.data = {}
	self:SaveArchiveData()
end

---set archive data from an external source
function Archiver:SetArchiveData(data)
	self.data = data
	self:SaveArchiveData()
end

---clear archive data
function Archiver:DumpArchiveData()
	return json.encode(
		self.data,
		{ indent=true, sort_keys=true }
	)
end

-- quick command to clear the kvp where all backup data is stored
RegisterCommand('clear_kvp', function (source, args)
	if source ~= 0 then return end

	local confirmation = tostring(args[1] or 'no'):lower():gsub("%s+", "")
    if confirmation ~= 'yes' then
        print('[ARCHIVER] ^3WARNING:^7 This will wipe all backup metadata. Files will remain, but the script will "forget" their ages.')
        print('[ARCHIVER] ^3USAGE:^7 clear_kvp yes')
        return
    end

	Archiver:ClearArchiveData()
	print('[ARCHIVER] KVP storage and local cache have been cleared.')
end, true)

-- quick command to dump the kvp into a json file
RegisterCommand('dump_kvp', function (source, args)
	if source ~= 0 then return end

	local resourceName = GetCurrentResourceName()
	local payload = Archiver:DumpArchiveData()
	local success = SaveResourceFile(resourceName, 'archiveData.json', payload, -1)

    if success then
        print(string.format('[ARCHIVER] Data exported to: ^3%s/archiveData.json', resourceName))
    else
        error('[ARCHIVER] Failed to write file. Check folder permissions.')
    end
end, true)

-- loads archive data metadata from the archiveData.json file
RegisterCommand('load_kvp', function(source, args)
    if source ~= 0 then return end

    local resourceName = GetCurrentResourceName()
    local fileContent = LoadResourceFile(resourceName, 'archiveData.json')

    if not fileContent then
        error('[ARCHIVER] Could not find "archiveData.json" in the resource folder.')
    end

    local data = json.decode(fileContent)

    if type(data) ~= 'table' then
        error('[ARCHIVER] "archiveData.json" contains invalid data (not a JSON object).')
    end

    Archiver:SetArchiveData(data)

    local count = 0
    for _ in pairs(data) do count = count + 1 end

    print(string.format('[ARCHIVER] Successfully imported "^3%s^7" metadata entries from JSON.', count))
end, true)

CreateThread(function ()
	Archiver:Initialize()
end)
