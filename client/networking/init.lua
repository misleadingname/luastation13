local networking = {}
local enet = require("enet")
local lzw = require("lib.lualzw.lualzw")

networking.Protocol = require("shared.networking.protocol")

local host
local peer
local connectionState = "disconnected" -- disconnected, connecting, handshake, connected
local clientId = nil
local lastHeartbeat = 0
local heartbeatInterval = 5.0

local lastPlayerCommand = nil
local pendingChunkRequests = {}

local EntityReceiver = require("client.networking.entities")
local messageHandlers = {}

networking.ConnectingIp = string.format("127.0.0.1:%d", NETWORK_DEFAULT_PORT)
networking.Disconnect = {
	code = NETWORK_DISCONNECT.UNKNOWN,
	reason = "No reason specified."
}

function networking.start(ip)
	if peer then
		LS13.Logging.LogError("Already connected")
		return false
	end

	LS13.Logging.LogInfo("Running lua-enet %s", enet.linked_version())
	LS13.Logging.LogInfo("Connecting to %s", ip)
	if host then
		networking.shutdown()
	end

	host = enet.host_create()

	peer = host:connect(ip, 1)
	if not peer then
		LS13.Logging.LogError("Failed to connect to %s", ip)
		return false
	end

	networking.ConnectingIp = ip
	connectionState = "connecting"
	return true
end

function networking.isConnected()
	return connectionState == "connected"
end

function networking.getConnectionState()
	return connectionState
end

function networking.getClientId()
	return clientId
end

function networking.sendMessage(message, flag)
	if not peer or (connectionState ~= "connected" and connectionState ~= "handshake") then
		LS13.Logging.LogError("Cannot send message: not connected")
		return false
	end

	local msg = tostring(message)
	local cmp = msg -- lzw.compress(msg)
	peer:send(cmp, 0, flag or "reliable")

	if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.updateNetworkStats then
		LS13.DebugOverlay.updateNetworkStats(message.type, #cmp, "sent")
	end

	return true
end

function networking.sendVerb(verb)
	local name = verb.name
	local buf = networking.Protocol.buffer.new()
	verb:serialize(buf)

	local message = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.VERB_REQUEST, {
		verbName = name,
		verbData = tostring(buf)
	})
	networking.sendMessage(message)
end

function networking.requestChunk(chunkX, chunkY)
	local chunkKey = chunkX .. "," .. chunkY
	if pendingChunkRequests[chunkKey] then
		return -- already requested
	end

	local message = networking.Protocol.createChunkRequest(chunkX, chunkY)
	if networking.sendMessage(message) then
		pendingChunkRequests[chunkKey] = love.timer.getTime()
		LS13.Logging.LogDebug("Requested chunk %s", chunkKey)
	end
end

function networking.sendPlayerCommand(command)
	if lastPlayerCommand and lastPlayerCommand:compare(command) then
		return
	end

	local message = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.PLAYER_COMMAND, {
		moveDirection = command.moveDirection,
		targetPosition = command.targetPosition
	})

	networking.sendMessage(message, "unreliable")
	lastPlayerCommand = command
end

function networking.update()
	if not host or not peer then
		return
	end

	local event = host:service()
	while event do
		if event.type == "receive" then
			if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.updateNetworkStats then
				LS13.DebugOverlay.updateNetworkStats("unknown", #event.data, "received")
			end

			local dcmp = event.data -- lzw.decompress(event.data)
			local type, timestamp, message = networking.Protocol.deserialize(dcmp)
			if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.updateNetworkStats then
				LS13.DebugOverlay.updateNetworkStats(type, #event.data, "received")
			end

			local data = networking.Protocol.deserializeEx(message, type)
			local handler = messageHandlers[type]
			if handler then
				handler(data)
			else
				LS13.Logging.LogDebug("No handler for message type: %s", type)
			end
		elseif event.type == "connect" then
			LS13.Logging.LogDebug("Connected to server, sending handshake")
			connectionState = "handshake"
			local handshake = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.HANDSHAKE, {
				protoVersion = NETWORK_PROTOCOL_VERSION,
				clientVersion = LS13.Info.Version,
				playerName = networking.playerName
			})

			networking.sendMessage(handshake)
		elseif event.type == "disconnect" then
			networking.Disconnect.code = event.data

			LS13.Logging.LogInfo("Disconnected from server")
			connectionState = "disconnected"
			clientId = nil
			pendingChunkRequests = {}
			LS13.StateManager.switchState("Disconnected")
		end
		event = host:service()
	end

	local currentTime = love.timer.getTime()
	if connectionState == "connected" and currentTime - lastHeartbeat > heartbeatInterval then
		local ping = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.PING, {})
		networking.sendMessage(ping)
		lastHeartbeat = currentTime
	end

	if connectionState == "connected" then
		local cmd = networking.Protocol.preparePlayerCommand()
		cmd.moveDirection = LS13.Input.getMovementVector()
		networking.sendPlayerCommand(cmd)
	end
end

function networking.shutdown()
	if peer then
		peer:disconnect_now()
		peer = nil
	end

	if host then
		host:destroy()
		host = nil
	end

	connectionState = "disconnected"
	pendingChunkRequests = {}
	clientId = nil
end

messageHandlers[NETWORK_MESSAGE_TYPE.PONG] = function(message)
	lastHeartbeat = love.timer.getTime()
end

messageHandlers[NETWORK_MESSAGE_TYPE.DISCONNECT] = function(message)
	networking.Disconnect.reason = message.reason
end

messageHandlers[NETWORK_MESSAGE_TYPE.HANDSHAKE_RESPONSE] = function(message)
	clientId = message.clientId
	connectionState = "connected"
	LS13.Logging.LogInfo("Connected to server with client ID: %s", clientId)

	if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.onConnected then
		LS13.DebugOverlay.onConnected()
	end

	if messageHandlers.onConnected then
		messageHandlers.onConnected()
	end

	LS13.StateManager.switchState("Lobby")
end

messageHandlers[NETWORK_MESSAGE_TYPE.VERB_BROADCAST] = function(message)
	local verbName = message.verbName
	local rawData = networking.Protocol.buffer.fromString(message.verbData)

	local verb = LS13.VerbSystem.getVerb(verbName)
	if not verb then
		LS13.Logging.LogError("Unknown verb: %s", verbName)
		return
	end

	local data = verb:deserialize(rawData)
	local verb = verb.new(data)
	if verb and verb.processOnClient then
		LS13.Logging.LogDebug("Processing verb %s", verbName)
		verb:processOnClient()
	end
end

messageHandlers[NETWORK_MESSAGE_TYPE.VERB_ERROR] = function(message)
	LS13.Logging.LogError("Verb %s failed: %s", message.verbName, message.error)
end

messageHandlers[NETWORK_MESSAGE_TYPE.GAME_STATE] = function(message)
	local state = message.gameState

	LS13.Logging.LogDebug("Received game state %s", state)
	if state == GAMESTATE.ROUND then
		LS13.StateManager.switchState("Game")
		local welcomeSnd = LS13.SoundManager.NewSource("Sound.CommWelcome")
		welcomeSnd:play()
	elseif state == GAMESTATE.PREROUND then
		LS13.StateManager.switchState("Lobby")
	elseif state == GAMESTATE.POSTROUND then
		local snds = LS13.AssetManager.GetPrefixed("Sound.PostRound")
		local snd = snds[math.random(1, #snds)]
		if snd then
			LS13.SoundManager.NewSource(snd):play()
		end
	end
end

-- messageHandlers[NETWORK_MESSAGE_TYPE.CHUNK_UPDATE] = function(message)
-- 	local chunkKey = message.data.chunkKey
-- 	local chunkData = message.data.chunkData

-- 	pendingChunkRequests[chunkKey] = nil

-- 	local currentWorld = LS13.WorldManager.getCurrentWorld()
-- 	if currentWorld then
-- 		local worldEnt = currentWorld:getEntities()[1]
-- 		if worldEnt and worldEnt.World then
-- 			worldEnt.World.tilemap:deserializeChunk(chunkKey, chunkData)
-- 			LS13.Logging.LogDebug("Updated chunk %s in world %s", chunkKey, LS13.WorldManager.getCurrentWorldId())
-- 		end
-- 	end
-- end

-- messageHandlers[NETWORK_MESSAGE_TYPE.WORLD_INIT] = function(message)
-- 	local chunks = message.data.chunks
-- 	local worldId = message.data.metadata and message.data.metadata.worldId or "default"

-- 	if not LS13.WorldManager.worlds[worldId] then
-- 		LS13.WorldManager.newWorld(worldId)
-- 	end

-- 	LS13.WorldManager.switchToWorld(worldId)

-- 	local currentWorld = LS13.WorldManager.getCurrentWorld()
-- 	if currentWorld then
-- 		local worldEnt = currentWorld:getEntities()[1]
-- 		if worldEnt and worldEnt.World then
-- 			local tilemap = worldEnt.World.tilemap

-- 			tilemap.chunks = {}

-- 			for chunkKey, chunkData in pairs(chunks) do
-- 				tilemap:deserializeChunk(chunkKey, chunkData)
-- 			end

-- 			local chunkCount = 0
-- 			for _ in pairs(chunks) do
-- 				chunkCount += 1
-- 			end
-- 			LS13.Logging.LogInfo("Received world initialization for world %s with %d chunks", worldId, chunkCount)
-- 		end
-- 	end
-- end

messageHandlers[NETWORK_MESSAGE_TYPE.WORLD_SWITCH] = function(message)
	local worldId = message.worldId

	if not worldId then
		LS13.Logging.LogInfo("Switching to no world")
		LS13.WorldManager.switchToWorld(nil)
		return
	end

	if not LS13.WorldManager.worlds[worldId] then
		LS13.WorldManager.newWorld(worldId)
	end

	LS13.WorldManager.switchToWorld(worldId)

	local currentWorld = LS13.WorldManager.getCurrentWorld()
	if currentWorld then
		local worldEnt = currentWorld:getEntities()[1]
		if worldEnt and worldEnt.World then
			worldEnt.World.tilemap.chunks = {}
			worldEnt.World.tilemap.dirtyChunks = {}
		end
	end
end

messageHandlers[NETWORK_MESSAGE_TYPE.ENTITY_CREATE] = function(message)
	local id = message.id
    local data = message.data

	local buf = networking.Protocol.buffer.fromString(data)
	EntityReceiver.handleEntityCreate(id, buf)
end

messageHandlers[NETWORK_MESSAGE_TYPE.ENTITY_UPDATE] = function(message)
	local id = message.id
	local data = message.data
	local components = {}

	local buf = networking.Protocol.buffer.fromString(data)
	EntityReceiver.handleEntityUpdate(id, buf)
end

messageHandlers[NETWORK_MESSAGE_TYPE.ENTITY_DESTROY] = function(message)
	local id = message.id
	EntityReceiver.handleEntityDestroy(id)
end

return networking
