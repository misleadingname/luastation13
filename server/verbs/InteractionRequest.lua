local InteractionRequestServer = {}

function InteractionRequestServer:processOnServer(clientId)
	local interactionName = self.data.interactionName
	local targetEntityId = self.data.targetEntityId -- TODO: unused for now :)

	local handler = LS13.InteractionSystem.getHandler(interactionName)
	if not handler then
		LS13.Logging.LogError("Unknown interaction handler: %s", interactionName)
		return false
	end

	return true
end

return InteractionRequestServer

