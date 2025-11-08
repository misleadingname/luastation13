local RoundManager = {}
local participatingClients = {}

RoundManager.State = GAMESTATE.PREROUND
local stateTimer = 0
local running = false

local PREROUND_TIME = 180
local POSTROUND_TIME = 20

local function setState(state, time)
	RoundManager.State = state
	stateTimer = time

	local msg = LS13.Networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.GAME_STATE, {
		gameState = state,
		stateTimer = stateTimer
	})
end

function RoundManager.update(dt)
	if not running then return end

	if RoundManager.State ~= GAMESTATE.ROUND then
		stateTimer = stateTimer - dt
		if stateTimer <= 0 then
			RoundManager.advanceState()
		end
	end
end

function RoundManager.advanceState()
	if RoundManager.State == GAMESTATE.PREROUND then
		RoundManager.startRound()
	elseif RoundManager.State == GAMESTATE.ROUND then
		RoundManager.endRound()
	elseif RoundManager.State == GAMESTATE.POSTROUND then
		RoundManager.resetToPreRound()
	end
end

function RoundManager.start()
	if running then
		LS13.Logging.LogWarn("RoundManager already running, ignoring start")
		return
	end
	running = true
	setState(GAMESTATE.PREROUND, PREROUND_TIME)

	LS13.Logging.LogInfo("RoundManager started, entering PREROUND for %ds", PREROUND_TIME)
end

function RoundManager.addClient(client)
	if not lume.find(participatingClients, client) then
		table.insert(participatingClients, client)
		LS13.Logging.LogDebug("Client %s added to participating players", client.name)
	else
		LS13.Logging.LogWarn("Client %s already participating", client.name)
	end
end

function RoundManager.removeClient(client)
	local index = lume.find(participatingClients, client)
	if index then
		table.remove(participatingClients, index)
		LS13.Logging.LogDebug("Client %s removed from participating players", client.name)
	else
		LS13.Logging.LogError("Cannot remove client %s, not found in participating players", client.name)
	end
end

function RoundManager.getRoundStats()
	return {
		State = RoundManager.State,
		TimeRemaining = stateTimer,
		Running = running,
		Players = #participatingClients,
	}
end

function RoundManager.getParticipatingClients()
	return participatingClients
end

function RoundManager.startRound()
	setState(GAMESTATE.ROUND)

	LS13.Logging.LogInfo("Starting round!")

	LS13.WorldManager.deleteWorld("station")
	LS13.WorldManager.newWorld("station")

	for _, client in ipairs(participatingClients) do
		LS13.WorldManager.switchWorld(client, "station")
	end
end

function RoundManager.endRound()
	setState(GAMESTATE.POSTROUND, POSTROUND_TIME)
	LS13.Logging.LogInfo("Round ended, entering POSTROUND for %ds", POSTROUND_TIME)
end

function RoundManager.resetToPreRound()
	setState(GAMESTATE.PREROUND, PREROUND_TIME)
	LS13.Logging.LogInfo("Postround finished, restarting preround")

	for _, client in ipairs(LS13.Networking.getClients()) do
		LS13.WorldManager.switchWorld(client, nil)
	end

	table.clear(participatingClients)
end

return RoundManager
