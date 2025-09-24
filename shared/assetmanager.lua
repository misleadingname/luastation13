local AssetManager = {}

local assets = {}

function AssetManager.Get(id)
	local asset = assets[id]
	if not asset then
		LS13.Logging.PrintError("Asset with id " .. id .. " not found!")
	end

	return asset
end

function AssetManager.Push(asset, id)
	if id:match("[%s/]") then
		LS13.Logging.PrintError(("Asset ID (\"%s\") contains illegal characters, BAIL!"):format(id))
		return
	end

	if assets[id] then
		LS13.Logging.PrintInfo("Asset with id " .. id .. " already exists! Overwriting...")
	end

	assets[id] = asset
	LS13.Logging.PrintDebug("Pushed asset " .. id)
end

function AssetManager.GetPrefixed(prefix)
	local prefixed = {}
	for id, asset in pairs(assets) do
		if id:sub(1, #prefix) == prefix then
			table.insert(prefixed, asset)
		end
	end

	return prefixed
end

return AssetManager
