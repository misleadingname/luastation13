local RoundManager = {}

local participatingClients = {}

local postRound = false

local running = false
local roundTime = 0
local idleTime = 0

function RoundManager.update(dt)
	if roundTime > 0 then
		roundTime = roundTime - dt
	elseif idleTime > 0 then
		idleTime = idleTime - dt
	elseif running then
		RoundManager.endRound()
	end
end

function RoundManager.addClient(client)
	table.insert(participatingClients, client)
	LS13.Logging.LogDebug("Client %s added to participating players", client.name)
end

function RoundManager.removeClient(client)
	local index = lume.find(participatingClients, client)
	if index then
		table.remove(participatingClients, index)
	else
		LS13.Logging.LogError("Cannot roundremove, client %s not found in participating players", client.name)
	end
end

function RoundManager.getParticipatingClients()
	return participatingClients
end

function RoundManager.roundTimeout()
	postRound = true
end

function RoundManager.startRound()
	LS13.Logging.LogDebug("Starting round")
	if running then
		LS13.Logging.LogWarn("Cannot restart round, already running")
		return
	end

	postRound = false
	running = true
	roundTime = 0
	idleTime = 0

	LS13.WorldManager.deleteWorld("station") -- will just do an error so it's safe to just ignore it
	LS13.WorldManager.newWorld("station")
	local msg = LS13.Networking.Protocol.createMessage(LS13.Networking.Protocol.MessageType.GAME_STATE, {
		state = "Round",
	})

	for _, client in ipairs(participatingClients) do
		LS13.WorldManager.switchWorld(client, "station")
		LS13.Networking.sendToClient(client.id, msg)
	end
end

function RoundManager.endRound()
	postRound = false
	running = false
	roundTime = 0
	idleTime = 0

	for _, client in ipairs(LS13.Networking.getClients()) do
		LS13.WorldManager.switchWorld(client, nil)
	end
end

return RoundManager
