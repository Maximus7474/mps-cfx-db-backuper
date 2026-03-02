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

	local amount, unit = self.config.ClearAfter:match("(%d+)([dh])")
    amount = tonumber(amount)

    if unit == "d" then
        self.clearDelay = amount * 86400
    elseif unit == "h" then
        self.clearDelay = amount * 3600
	else
		error(string.format('An invalid value was provided for Config.Archiver.ClearAfter ! Please use the indicated value format [number]["d" or "h"]'))
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
