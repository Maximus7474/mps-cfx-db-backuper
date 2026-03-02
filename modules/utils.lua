---@param t1 table
---@param t2 table
---@return table
function CombineTables(t1, t2)
	for k, v in pairs(t2) do
        t1[k] = v
    end

    return t1
end

---Load ox lib into the resource
function LoadOxLib()
	local fileData = LoadResourceFile('ox_lib', 'init.lua')
	if not fileData then error('Failed to load @ox_lib/init.lua - Resource not found') end

	local chunk, err = load(fileData, ('@@%s/%s'):format('ox_lib', 'init.lua'))
	if not chunk then error(string.format('Failed to load @ox_lib/init.lua - %s', err)) end

	return chunk()
end

---generate a filename for the backup file
---@return string
function BackupFileName()
	return string.format('backup-%s', os.date("%Y%m%d-%H%M%S"))
end
