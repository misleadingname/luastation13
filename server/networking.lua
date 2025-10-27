local networking = {}
local enet = require("enet")
networking.Protocol = require("shared.networking.protocol")

local host
local clients = {} -- clientId -> {peer, playerName, lastHeartbeat, worldId, etc}
local clientIdCounter = 1

local messageHandlers = {}

function networking.start(port, maxPeers)
	if host then
		LS13.Logging.LogError("Host already created")
		return false
	end

	LS13.Logging.LogInfo("Running lua-enet %s", enet.linked_version())

	host = enet.host_create("localhost:" .. port, maxPeers, 1)
	if not host then
		LS13.Logging.LogError("Failed to create host on port %s", port)
		return false
	end

	LS13.Logging.LogInfo("Host created on port %s with max %d peers", port, maxPeers)
	return true
end

function networking.getClients()
	return clients
end

function networking.getClientCount()
	return lume.count(clients)
end

function networking.getClientByPeer(peer)
	for clientId, client in pairs(clients) do
		if client.peer == peer then
			return client, clientId
		end
	end
	return nil, nil
end

function networking.broadcastMessage(message, excludeClientId)
	local serialized = networking.Protocol.serialize(message)
	if not serialized then
		return false
	end

	for clientId, client in pairs(clients) do
		if clientId ~= excludeClientId then
			client.peer:send(serialized)
		end
	end
	return true
end

function networking.sendToClient(clientId, message)
	local client = clients[clientId]
	if not client then
		LS13.Logging.LogError("Cannot send to unknown client: %s", clientId)
		return false
	end

	local serialized = networking.Protocol.serialize(message)
	if not serialized then
		return false
	end

	client.peer:send(serialized)
	return true
end

function networking.broadcastVerb(verbName, verbData, sourceClientId)
	local message = networking.Protocol.createVerbBroadcast(verbName, verbData, sourceClientId)
	return networking.broadcastMessage(message, sourceClientId)
end

function networking.sendChunkToClient(clientId, chunkKey, chunkData)
	local message = networking.Protocol.createChunkUpdate(chunkKey, chunkData)
	return networking.sendToClient(clientId, message)
end

function networking.sendWorldInitToClient(clientId)
	local client = clients[clientId]
	if not client then
		LS13.Logging.LogError("Cannot send world init to unknown client %s", clientId)
		return false
	end
	if client.worldId then
		return LS13.WorldManager.sendWorldDataToClient(clientId, client.worldId)
	else
		LS13.Logging.LogDebug("Client %s not assigned to any world, skipping world init", clientId)
		return true
	end
end

messageHandlers[networking.Protocol.MessageType.HANDSHAKE] = function(peer, message)
	local clientVersion = message.data.clientVersion
	local name = message.data.playerName

	local clientId = clientIdCounter
	clientIdCounter += 1

	clients[clientId] = {
		id = clientId,
		peer = peer,
		name = name,
		clientVersion = clientVersion,
		lastHeartbeat = love.timer.getTime(),
		connected = true,
		worldId = nil,
	}

	LS13.Logging.LogInfo("Client %s (%s) connected with version %s", clientId, name, clientVersion)

	local response = networking.Protocol.createMessage(networking.Protocol.MessageType.HANDSHAKE_RESPONSE, {
		clientId = clientId,
		serverVersion = LS13.Info.Version,
		netVersion = networking.Protocol.Version,
		gameState = LS13.StateManager.currentState.name,
	})

	local serialized = networking.Protocol.serialize(response)
	if serialized then
		peer:send(serialized)
		networking.sendWorldInitToClient(clientId)
	end
end

messageHandlers[networking.Protocol.MessageType.VERB_REQUEST] = function(peer, message)
	local client, clientId = networking.getClientByPeer(peer)
	if not client then
		LS13.Logging.LogError("Verb request from unknown client")
		return
	end

	local verbName = message.data.verbName
	local verbData = message.data.verbData

	local serverVerbData = {}
	for k, v in pairs(verbData) do
		serverVerbData[k] = v
	end

	local verb = LS13.VerbSystem.createVerb(verbName, serverVerbData)
	verb.invoker = client

	if not verb then
		local errorMsg = networking.Protocol.createVerbError("Unknown verb: " .. verbName, message.data)
		networking.sendToClient(clientId, errorMsg)
		return
	end

	local valid, error = verb:validate()
	if not valid then
		local errorMsg =
			networking.Protocol.createVerbError("Verb validation failed: " .. (error or "Unknown error"), message.data)
		networking.sendToClient(clientId, errorMsg)
		return
	end

	if verb.processOnServer then
		local success, result = pcall(verb.processOnServer, verb, clientId)
		if not success then
			LS13.Logging.LogError("Verb processing failed: %s", result)
			local errorMsg = networking.Protocol.createVerbError("Verb processing failed", message.data)
			networking.sendToClient(clientId, errorMsg)
			return
		end
	end

	networking.broadcastVerb(verbName, verbData or {}, clientId)
end

messageHandlers[networking.Protocol.MessageType.CHUNK_REQUEST] = function(peer, message)
	local client, clientId = networking.getClientByPeer(peer)
	if not client then
		LS13.Logging.LogError("Chunk request from unknown client")
		return
	end

	-- if client is not in any world, send empty chunk
	if not client.worldId then
		local chunkX = message.data.chunkX
		local chunkY = message.data.chunkY
		local chunkKey = chunkX .. "," .. chunkY
		networking.sendChunkToClient(clientId, chunkKey, {})
		return
	end

	local chunkX = message.data.chunkX
	local chunkY = message.data.chunkY
	local chunkKey = chunkX .. "," .. chunkY

	local world = LS13.WorldManager.worlds[client.worldId]
	if not world then
		return
	end

	local worldEnt = world:getEntities()[1]
	if worldEnt and worldEnt.World then
		local chunkData = worldEnt.World.tilemap:serializeChunk(chunkKey)
		if chunkData then
			networking.sendChunkToClient(clientId, chunkKey, chunkData)
			LS13.Logging.LogDebug("Sent chunk %s to client %s in world %s", chunkKey, clientId, client.worldId)
		else
			networking.sendChunkToClient(clientId, chunkKey, {})
		end
	end
end

messageHandlers[networking.Protocol.MessageType.PING] = function(peer, message)
	local client = networking.getClientByPeer(peer)
	if client then
		client.lastHeartbeat = love.timer.getTime()

		local pong = networking.Protocol.createMessage(networking.Protocol.MessageType.PONG, {})
		local serialized = networking.Protocol.serialize(pong)
		if serialized then
			peer:send(serialized)
		end
	end
end

messageHandlers[networking.Protocol.MessageType.WORLD_SWITCH] = function(message)
	local worldId = message.data.worldId
	LS13.Logging.LogInfo("Switching to world: %s", worldId)

	local worldEnt = LS13.World:getEntities()[1]
	if worldEnt and worldEnt.World then
		worldEnt.World.tilemap.chunks = {}
		worldEnt.World.tilemap.dirtyChunks = {}
	end
end

function networking.update()
	if not host then
		return
	end

	local event = host:service()
	while event do
		if event.type == "receive" then
			local message = networking.Protocol.deserialize(event.data)
			if message then
				local valid, error = networking.Protocol.validateMessage(message)
				if valid then
					local handler = messageHandlers[message.type]
					if handler then
						handler(event.peer, message)
					else
						LS13.Logging.LogDebug("No handler for message type: %s", message.type)
					end
				else
					LS13.Logging.LogError("Invalid message received: %s", error)
				end
			end
		elseif event.type == "connect" then
			LS13.Logging.LogDebug("Peer %s attempting to connect", event.peer)
		elseif event.type == "disconnect" then
			local client, clientId = networking.getClientByPeer(event.peer)
			if client then
				LS13.Logging.LogInfo("Client %s (%s) disconnected", clientId, client.playerName)
				clients[clientId] = nil
			else
				LS13.Logging.LogDebug("Unknown peer %s disconnected", event.peer)
			end
		end
		event = host:service()
	end

	local currentTime = love.timer.getTime()
	local timeoutThreshold = 30.0

	for clientId, client in pairs(clients) do
		if currentTime - client.lastHeartbeat > timeoutThreshold then
			LS13.Logging.LogInfo("Client %s timed out, disconnecting", clientId)
			client.peer:disconnect_now()
			clients[clientId] = nil
		end
	end
end

function networking.shutdown()
	if host then
		for clientId, client in pairs(clients) do
			client.peer:disconnect_now()
		end

		host:destroy()
		host = nil
	end

	clients = {}
	clientIdCounter = 1
end

return networking
