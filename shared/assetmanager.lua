local AssetManager = {}

local assets = {}

function AssetManager.Get(id)
	return assets[id]
end

function AssetManager.Push(asset, id)
	assets[id] = asset
	print("Pushed asset " .. id)
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
