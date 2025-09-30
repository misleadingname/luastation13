local AssetManager = {}
AssetManager.Loader = require("shared.assets.loader")

local assets = {}

function AssetManager.Get(id)
	local asset = assets[id]
	if not asset then
		LS13.Logging.LogError("Asset with id %s not found!", id)
	end

	return asset
end

function AssetManager.Push(asset, id)
	if id:match("[%s/]") then
		LS13.Logging.LogError("Asset ID (\"%s\") contains illegal characters, BAIL!", id)
		return
	end

	if assets[id] then
		LS13.Logging.LogInfo("Asset with id %s already exists! Overwriting...", id)
	end

	if not asset then
		LS13.Logging.LogError("Asset with id %s is nil! BAIL!", id)
		return
	end

	assets[id] = asset
	LS13.Logging.LogDebug("Inserted %s as %s ", asset.type, id)
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
