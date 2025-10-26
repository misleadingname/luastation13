local InteractionSystem = {}

local handlers = {}

function InteractionSystem.registerHandler(interactionName, handler)
	if handlers[interactionName] then
		LS13.Logging.LogError("Interaction handler '%s' is already registered", interactionName)
		return false
	end

	handlers[interactionName] = handler
	LS13.Logging.LogDebug("Registered interaction handler: %s", interactionName)
	return true
end

function InteractionSystem.getHandler(interactionName)
	return handlers[interactionName]
end

function InteractionSystem.getAllHandlers()
	return handlers
end

function InteractionSystem.discoverHandlers()
	LS13.Logging.LogDebug("Discovering interaction handlers...")

	local sharedHandlersPath = "shared/interactions/"
	local handlerFiles = love.filesystem.getDirectoryItems(sharedHandlersPath)

	for _, file in ipairs(handlerFiles) do
		if file:match("%.lua$") and file ~= "init.lua" then
			local handlerName = file:gsub("%.lua$", "")
			local success, handlerModule = pcall(require, sharedHandlersPath:gsub("/", ".") .. handlerName)

			if success and handlerModule then
				InteractionSystem.registerHandler(handlerName, handlerModule)
			else
				LS13.Logging.LogError("Failed to load interaction handler: %s", handlerName)
			end
		end
	end
end

return InteractionSystem

