local loader = {}
local loaded = {}
local loaders = require("shared.assets.loaders")

local typesLookup = {
	["png"] = "Graphics",
	["ogg|wav|mp3|it|mod|xm"] = "Sound"
}

function loader.Load(path, options)
	local asset = loaded[path]
	if asset then return asset end

	local ext = string.match(path, "%.(%w+)$")
	local type

	for typeMatch, aType in pairs(typesLookup) do
		local exts = lume.split(typeMatch, "|")
		for _, aExt in ipairs(exts) do
			if ext == aExt then
				type = aType
				break
			end
		end
	end

	if not path then
		error("Invalid asset path")
	end

	if not loaders[type] then
		error("Invalid asset type: " .. type)
	end

	local success, err = pcall(function()
		asset = loaders[type](path, options or {})
	end)

	if not success then
		error(string.format("Failed to load asset (fallback failed!!!) %s: %s", path, err))
	end

	loaded[path] = asset
	return asset
end

return loader
