local xml2lua = require("lib.xml2lua.xml2lua")
local parsers = require("shared.prototype.parsers")
local handler = require("lib.xml2lua.xmlhandler.tree")

local PrototypeManager = {}
local parsedPrototypes = {}

function PrototypeManager.RawParse(xmlString)
	local tree = handler:new()
	local parser = xml2lua.parser(tree)
	parser:parse(xmlString)

	return tree.root
end

function PrototypeManager.Parse(path, preload)
	local info = love.filesystem.getInfo(path, "file")
	if not info or info.type ~= "file" then
		return error(string.format("File not found or invalid: %s", path))
	end

	local xmlString = love.filesystem.read(path)
	local parsed = PrototypeManager.RawParse(xmlString)
	if not parsed then
		return error(string.format("Failed to parse prototype: %s", path))
	end

	local ls13 = parsed.LS13
	if not ls13 then
		return error(string.format("Invalid prototype (root is not <LS13>): %s", path))
	end

	if preload and ls13._attr and ls13._attr.Preload and string.lower(ls13._attr.Preload) == "false" then
		LS13.Logging.LogDebug("Skipping preload of %s", path)
		return
	end

	for nodeType, nodes in pairs(ls13) do
		local parser = parsers[nodeType]
		if parser then
			for i, node in ipairs(nodes) do
				local parent = node._attr.Parent
				if parent and parent ~= node._attr.Id then
					local data = parsedPrototypes[parent]
					if data then
						node = lume.merge(data, node)
					end
				end

				local success, err = pcall(function()
					parser(node)
					parsedPrototypes[node._attr.Id] = node
				end)

				if not success then
					local id = node._attr and node._attr.Id and node._attr.Id or "unknown"
					LS13.Logging.LogError("Failed to parse %s (%s): %s", nodeType, id, err)
				end
			end
		else
			LS13.Logging.LogError("No parser for node type %s", nodeType)
		end
	end
end

function PrototypeManager.ParseAll()
	local basePath = "/resources/prototypes"

	local function recurse(path)
		for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
			local info = love.filesystem.getInfo(path .. "/" .. file)
			if info.type == "directory" then
				recurse(path .. "/" .. file)
			elseif info.type == "file" and file:sub(-4) == ".xml" then
				PrototypeManager.Parse(path .. "/" .. file, true)
			end
		end
	end

	recurse(basePath)
end

return PrototypeManager
