local networking = {}
local enet = require("enet")
networking.Protocol = require("shared.networking.protocol")

local host
local peer
local connectionState = "disconnected" -- disconnected, connecting, connected
local clientId = nil
local lastHeartbeat = 0
local heartbeatInterval = 5.0

local outgoingVerbs = {}
local pendingChunkRequests = {}

local messageHandlers = {}

networking.ConnectingIp = "127.0.0.1:14700"

function networking.start(ip)
	if peer then
		LS13.Logging.LogError("Already connected")
		return false
	end

	LS13.Logging.LogInfo("Running lua-enet %s", enet.linked_version())
	LS13.Logging.LogInfo("Connecting to %s", ip)
	if host then networking.shutdown() end
	host = enet.host_create()

	peer = host:connect(ip, 1)
	if not peer then
		LS13.Logging.LogError("Failed to connect to %s", ip)
		return false
	end

	networking.ConnectingIp = ip
	connectionState = "connecting"

	networking.playerName = "Guest"
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

function networking.sendMessage(message)
	if not peer or connectionState ~= "connected" then
		LS13.Logging.LogError("Cannot send message: not connected")
		return false
	end

	local serialized = networking.Protocol.serialize(message)
	if not serialized then
		return false
	end

	peer:send(serialized)

	if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.updateNetworkStats then
		LS13.DebugOverlay.updateNetworkStats(message.type, #serialized, "sent")
	end

	return true
end

function networking.sendVerb(verbName, verbData)
	local message = networking.Protocol.createVerbRequest(verbName, verbData or {})
	return networking.sendMessage(message)
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

messageHandlers[networking.Protocol.MessageType.HANDSHAKE_RESPONSE] = function(message)
	connectionState = "connected"
	clientId = message.data.clientId
	LS13.Logging.LogInfo("Connected to server with client ID: %s", clientId)

	if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.onConnected then
		LS13.DebugOverlay.onConnected()
	end

	if messageHandlers.onConnected then
		messageHandlers.onConnected()
	end

	LS13.StateManager.switchState("Lobby")
end

messageHandlers[networking.Protocol.MessageType.VERB_BROADCAST] = function(message)
	local verbName = message.data.verbName
	local verbData = message.data.verbData

	local verb = LS13.VerbSystem.createVerb(verbName, verbData)
	if verb and verb.processOnClient then
		verb:processOnClient()
	end
end

messageHandlers[networking.Protocol.MessageType.CHUNK_UPDATE] = function(message)
	local chunkKey = message.data.chunkKey
	local chunkData = message.data.chunkData

	pendingChunkRequests[chunkKey] = nil

	local currentWorld = LS13.WorldManager.getCurrentWorld()
	if currentWorld then
		local worldEnt = currentWorld:getEntities()[1]
		if worldEnt and worldEnt.World then
			worldEnt.World.tilemap:deserializeChunk(chunkKey, chunkData)
			LS13.Logging.LogDebug("Updated chunk %s in world %s", chunkKey, LS13.WorldManager.getCurrentWorldId())
		end
	end
end

messageHandlers[networking.Protocol.MessageType.WORLD_INIT] = function(message)
	local chunks = message.data.chunks
	local worldId = message.data.metadata and message.data.metadata.worldId or "default"

	if not LS13.WorldManager.worlds[worldId] then
		LS13.WorldManager.newWorld(worldId)
	end

	LS13.WorldManager.switchToWorld(worldId)

	local currentWorld = LS13.WorldManager.getCurrentWorld()
	if currentWorld then
		local worldEnt = currentWorld:getEntities()[1]
		if worldEnt and worldEnt.World then
			local tilemap = worldEnt.World.tilemap

			tilemap.chunks = {}

			for chunkKey, chunkData in pairs(chunks) do
				tilemap:deserializeChunk(chunkKey, chunkData)
			end

			local chunkCount = 0
			for _ in pairs(chunks) do chunkCount = chunkCount + 1 end
			LS13.Logging.LogInfo("Received world initialization for world %s with %d chunks", worldId, chunkCount)
		end
	end
end

messageHandlers[networking.Protocol.MessageType.GAME_STATE] = function(message)
	local state = message.data.state
	local welcomeSnd = LS13.SoundManager.NewSource("Sound.CommWelcome")
	welcomeSnd:play()

	LS13.Logging.LogDebug("Received game state %s", state)
	if state == "Round" then
		LS13.StateManager.switchState("Game")
	else
		LS13.StateManager.switchState("Lobby")
	end
end

messageHandlers[networking.Protocol.MessageType.VERB_ERROR] = function(message)
	LS13.Logging.LogError("Verb error from server: %s", message.data.error)
end

messageHandlers[networking.Protocol.MessageType.WORLD_SWITCH] = function(message)
	local worldId = message.data.worldId

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

messageHandlers[networking.Protocol.MessageType.PONG] = function(message)
	lastHeartbeat = love.timer.getTime()
end

function networking.update()
	if not host or not peer then return end

	local event = host:service()
	while event do
		if event.type == "receive" then
			if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.updateNetworkStats then
				LS13.DebugOverlay.updateNetworkStats("unknown", #event.data, "received")
			end

			local message = networking.Protocol.deserialize(event.data)
			if message then
				local valid, error = networking.Protocol.validateMessage(message)
				if valid then
					if DEBUG and LS13.DebugOverlay and LS13.DebugOverlay.updateNetworkStats then
						LS13.DebugOverlay.updateNetworkStats(message.type, #event.data, "received")
					end

					local handler = messageHandlers[message.type]
					if handler then
						handler(message)
					else
						LS13.Logging.LogDebug("No handler for message type: %s", message.type)
					end
				else
					LS13.Logging.LogError("Invalid message received: %s", error)
				end
			end
		elseif event.type == "connect" then
			LS13.Logging.LogDebug("Connected to server, sending handshake")
			local handshake = networking.Protocol.createHandshake(LS13.Info.Version, networking.playerName)
			local serialized = networking.Protocol.serialize(handshake)
			if serialized then
				event.peer:send(serialized)
			end
		elseif event.type == "disconnect" then
			LS13.Logging.LogInfo("Disconnected from server")
			connectionState = "disconnected"
			clientId = nil
			pendingChunkRequests = {}
			LS13.StateManager.switchState("Connecting")
		end
		event = host:service()
	end

	local currentTime = love.timer.getTime()
	if connectionState == "connected" and currentTime - lastHeartbeat > heartbeatInterval then
		local ping = networking.Protocol.createMessage(networking.Protocol.MessageType.PING, {})
		networking.sendMessage(ping)
		lastHeartbeat = currentTime
	end
end

function networking.onConnected(callback)
	messageHandlers.onConnected = callback
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
	clientId = nil
	pendingChunkRequests = {}
end

return networking
