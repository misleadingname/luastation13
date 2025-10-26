local VerbSystem = {}

local verbRegistry = {}
local verbsByName = {}

local BaseVerb = require("shared.verbs.baseVerb")

function VerbSystem.registerVerb(name, verbClass)
	if verbRegistry[name] then
		LS13.Logging.LogError("Verb '%s' is already registered", name)
		return false
	end

	verbRegistry[name] = verbClass
	verbsByName[name] = verbClass

	LS13.Logging.LogDebug("Registered verb: %s", name)
	return true
end

function VerbSystem.getVerb(name)
	return verbRegistry[name]
end

function VerbSystem.getAllVerbs()
	return verbsByName
end

function VerbSystem.createVerb(name, data)
	local actionClass = verbRegistry[name]
	if not actionClass then
		LS13.Logging.LogError("Unknown action type: %s", name)
		return nil
	end

	return actionClass.new(name, data)
end

function VerbSystem.deserializeVerb(serializedData)
	local actionClass = verbRegistry[serializedData.name]
	if not actionClass then
		LS13.Logging.LogError("Cannot deserialize unknown action: %s", serializedData.name)
		return nil
	end

	if actionClass.deserialize then
		return actionClass.deserialize(serializedData)
	else
		return BaseVerb.deserialize(serializedData)
	end
end

function VerbSystem.discoverVerbs()
	LS13.Logging.LogDebug("Discovering actions...")

	local sharedActionsPath = "shared/verbs/"
	local actionFiles = love.filesystem.getDirectoryItems(sharedActionsPath)

	for _, file in ipairs(actionFiles) do
		if file:match("%.lua$") and file ~= "init.lua" then
			local actionName = file:gsub("%.lua$", "")
			local success, actionModule = pcall(require, sharedActionsPath:gsub("/", ".") .. actionName)

			if success and actionModule then
				VerbSystem.registerVerb(actionName, actionModule)
			else
				LS13.Logging.LogError("Failed to load action: %s", actionName)
			end
		end
	end

	-- everything else should use this instead of manually requiring everything else
	-- TODO: ^^^^
	local contextPath = CLIENT and "client/verbs/" or (SERVER and "server/verbs/" or nil)
	if contextPath and love.filesystem.getInfo(contextPath) then
		local contextFiles = love.filesystem.getDirectoryItems(contextPath)

		for _, file in ipairs(contextFiles) do
			if file:match("%.lua$") then
				local actionName = file:gsub("%.lua$", "")
				local sharedAction = verbRegistry[actionName]

				if sharedAction then
					local success, contextModule = pcall(require, contextPath:gsub("/", ".") .. actionName)
					if success and contextModule then
						for key, value in pairs(contextModule) do
							sharedAction[key] = value
						end
						LS13.Logging.LogDebug("extended verb '%s' with %s", actionName,
							CLIENT and "client" or "server")
					end
				end
			end
		end
	end
end

VerbSystem.BaseVerb = BaseVerb

return VerbSystem
