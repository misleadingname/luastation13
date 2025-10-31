local DebugStartRound = {}

function DebugStartRound:processOnServer()
	if LS13.RoundManager.getRoundStats().Running then
		return false
	end

	for _, client in ipairs(LS13.Networking.getClients()) do
		LS13.RoundManager.addClient(client)
	end

	LS13.RoundManager.startRound()

	local world = LS13.WorldManager.getWorld("station")
	local plys = LS13.RoundManager.getParticipatingClients()
	for _, ply in ipairs(plys) do
		local ent = LS13.ECSManager.entity("ghost" .. ply.id)
		ent:give("Transform")
		ent:give("Graphic")
		ent:give("BasicTempCharacter")
		ent:give("Sentience", ply.id)

		world:addEntity(ent)

		LS13.Logging.LogDebug("Created ghost entity for player %s", ply.id)
	end

	return true
end

return DebugStartRound
