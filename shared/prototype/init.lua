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

local function safeParseNode(nodeType, node)
	local parser = parsers[nodeType]
	if not parser then
		LS13.Logging.LogError("No parser for node type %s", nodeType)
		return
	end

	local success, err = pcall(function()
		parser(node)
		parsedPrototypes[node._attr.Id] = node
	end)

	if not success then
		local id = node._attr and node._attr.Id or "unknown"
		LS13.Logging.LogError("Failed to parse %s (%s): %s", nodeType, id, err)
	end
end

local function resolveNode(node)
	local parentId = node._attr and node._attr.Parent
	if parentId and parentId ~= node._attr.Id then
		local parent = parsedPrototypes[parentId]
		if not parent then
			LS13.Logging.LogWarn("Parent not parsed yet (%s) pushed", parentId)
			return false
		end

		node = lume.merge(parent, node)
	end
	safeParseNode(node._nodeType, node)
	return true
end

function PrototypeManager.Parse(path, preload)
	local info = love.filesystem.getInfo(path, "file")
	if not info or info.type ~= "file" then
		error(string.format("File not found or invalid: %s", path))
	end

	local xmlString = love.filesystem.read(path)
	local parsed = PrototypeManager.RawParse(xmlString)
	if not parsed then
		error(string.format("Failed to parse prototype: %s", path))
	end

	local ls13 = parsed.LS13
	if not ls13 then
		error(string.format("Invalid prototype (root is not <LS13>): %s", path))
	end

	if preload and ls13._attr and ls13._attr.Preload and string.lower(ls13._attr.Preload) == "false" then
		LS13.Logging.LogDebug("Skipping preload of %s", path)
		return
	end

	local allNodes = {}
	for nodeType, nodes in pairs(ls13) do
		local paired = false
		for _, node in ipairs(nodes) do
			node._nodeType = nodeType
			table.insert(allNodes, node)
			paired = true
		end

		if not paired then
			local node = nodes
			node._nodeType = nodeType
			table.insert(allNodes, node)
		end
	end

	local unresolved = allNodes
	local progress = true
	while #unresolved > 0 and progress do
		progress = false
		local remaining = {}
		for _, node in ipairs(unresolved) do
			if not resolveNode(node) then
				table.insert(remaining, node)
			else
				progress = true
			end
		end

		unresolved = remaining
	end

	-- Anything left is missing parents
	for _, node in ipairs(unresolved) do
		local id = node._attr and node._attr.Id or "unknown"
		LS13.Logging.LogError("Unresolved parent for %s (%s)", node._nodeType, id)
	end
end

function PrototypeManager.ParseAll()
	local basePath = "/resources/prototypes"

	local function recurse(path)
		for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
			local fullPath = path .. "/" .. file
			local info = love.filesystem.getInfo(fullPath)
			if info.type == "directory" then
				recurse(fullPath)
			elseif info.type == "file" and file:sub(-4) == ".xml" then
				PrototypeManager.Parse(fullPath, true)
			end
		end
	end

	recurse(basePath)
end

local channel = love.thread.getChannel("PrototypeWatchdog")
local thread = love.thread.newThread("shared/prototype/watchdog.lua")
thread:start()

function PrototypeManager.UpdateWatchdog()
	local path = channel:pop()
	if path then
		LS13.Logging.LogInfo("Prototype file refreshed, reloading %s", path)
		PrototypeManager.Parse(path)
	end
end

return PrototypeManager
