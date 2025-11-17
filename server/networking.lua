local networking = {}
local enet = require("enet")
local lzw = require("lib.lualzw.lualzw")

networking.Protocol = require("shared.networking.protocol")

local host
local clients = {} -- clientId -> {peer, playerName, lastHeartbeat, worldId, connected, warnings}
local clientIdCounter = 1
local timeoutThreshold = 30.0

local messageHandlers = {}

local function prepareSendMessage(message)
	local msg = tostring(message)
	-- local cmp = lzw.compress(msg)
	return msg --cmp
end

function networking.start(port, maxPeers)
	if host then
		LS13.Logging.LogError("Host already created")
		return false
	end

	LS13.Logging.LogInfo("Running lua-enet %s", enet.linked_version())

	host = enet.host_create("0.0.0.0:" .. port, maxPeers, 1)
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

function networking.getClientById(clientId)
	return clients[clientId]
end

function networking.getClientByPeer(peer)
	for clientId, client in pairs(clients) do
		if client.peer == peer then
			return client, clientId
		end
	end
	return nil, nil
end

function networking.broadcastMessage(message, list, whitelist)
	local msg = prepareSendMessage(message)

	if type(list) == "number" then
		list = { list }
	end

	for clientId, client in ipairs(clients) do
		if not whitelist then
			if client and not (list and lume.find(list, clientId)) then
				client.peer:send(msg)
			end
		else
			if client and (list and lume.find(list, clientId)) then
				client.peer:send(msg)
			end
		end
	end
end

function networking.sendToClient(clientId, message)
	local client = clients[clientId]
	if not client then
		LS13.Logging.LogError("Cannot send to unknown client: %s", clientId)
		return false
	end

	local msg = prepareSendMessage(message)
	client.peer:send(msg)
	return true
end

function networking.disconnect(client, code, force, reason)
	if client then
		local msg = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.DISCONNECT, {
			reason = reason or "No reason specified."
		})

		networking.sendToClient(client.id, msg)

		client.connected = false
		if force then
			client.peer:disconnect_now(code or NETWORK_DISCONNECT.KICKED)
		else
			client.peer:disconnect_later(code or NETWORK_DISCONNECT.KICKED)
		end
	end
end

function networking.update()
	if not host then
		return
	end

	local event = host:service()
	while event do
		if event.type == "receive" then
			local dcmp = event.data -- lzw.decompress(event.data)
			local type, timestamp, message = networking.Protocol.deserialize(dcmp)
			local handler = messageHandlers[type]
			if handler then
				local data = networking.Protocol.deserializeEx(message, type)
				local client = networking.getClientByPeer(event.peer)
				if client then
					handler(client, data)
				else
					local client = { peer = event.peer } -- New client!
					handler(client, data)
				end
			else
				LS13.Logging.LogDebug("No handler for message type: %s", type)
			end
		elseif event.type == "connect" then
			LS13.Logging.LogDebug("Peer %s attempting to connect", event.peer)
		elseif event.type == "disconnect" then
			local client, clientId = networking.getClientByPeer(event.peer)
			if client then
				LS13.Logging.LogInfo("Client %s (%s) disconnected", clientId, client.name)
				local world = LS13.WorldManager.getWorldOfClient(client.id)
				if world then
					local cmd = networking.Protocol.preparePlayerCommand()
					world:emit("playerCommand", client.id, cmd)
				end

				client.connected = false
			else
				LS13.Logging.LogDebug("Unknown peer %s disconnected", event.peer)
			end
		end
		event = host:service()
	end

	local currentTime = love.timer.getTime()
	for clientId, client in pairs(clients) do
		if currentTime - client.lastHeartbeat > timeoutThreshold and client.connected then
			LS13.Logging.LogInfo("Client %s timed out, disconnecting", clientId)
			LS13.Networking.disconnect(client, NETWORK_DISCONNECT.TIMEOUT, true)
		end

		if client.warnings >= 5 and not client.adminNotified then
			client.adminNotified = true
			LS13.Logging.LogInfo("Client %s has too many warnings, notifying!")
			-- TODO: admin notice logic, aka chat
		end
	end
end

function networking.shutdown()
	if host then
		for clientId, client in pairs(clients) do
			LS13.Networking.disconnect(client, NETWORK_DISCONNECT.SHUTDOWN, true)
		end

		host:destroy()
		host = nil
	end

	clients = {}
	clientIdCounter = 1
end

messageHandlers[NETWORK_MESSAGE_TYPE.PING] = function(client, message)
	client.lastHeartbeat = love.timer.getTime()
	local response = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.PONG, {})
	networking.sendToClient(client.id, response)
end

messageHandlers[NETWORK_MESSAGE_TYPE.HANDSHAKE] = function(client, message)
	local protoVersion = message.protoVersion
	local clientVersion = message.clientVersion
	local playerName = message.playerName

	local clientId = clientIdCounter
	clientIdCounter += 1

	clients[clientId] = {
		id = clientId,
		peer = client.peer,
		name = playerName,
		clientVersion = clientVersion,
		lastHeartbeat = love.timer.getTime(),
		connected = true,
		warnings = 0,
		worldId = nil,
	}

	LS13.Logging.LogInfo("Client %s (%s) connected with version %s", clientId, playerName, clientVersion)

	local response = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.HANDSHAKE_RESPONSE, {
		serverVersion = LS13.Info.Version,
		clientId = clientId,
	})

	local round = LS13.RoundManager.getRoundStats()
	local state = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.GAME_STATE, {
		gameState = round.State,
		stateTimer = round.TimeRemaining
	})

	networking.sendToClient(clientId, response)
	networking.sendToClient(clientId, state)
end

messageHandlers[NETWORK_MESSAGE_TYPE.PLAYER_COMMAND] = function(client, message)
	local world = LS13.WorldManager.getWorldOfClient(client.id)
	local cmd = networking.Protocol.preparePlayerCommand()
	cmd.moveDirection = message.moveDirection
	cmd.targetPosition = message.targetPosition

	if world then
		world:emit("playerCommand", client.id, cmd)
	end
end

messageHandlers[NETWORK_MESSAGE_TYPE.VERB_REQUEST] = function(client, message)
	local verbName = message.verbName
	local rawData = networking.Protocol.buffer.fromString(message.verbData)

	local verb = LS13.VerbSystem.getVerb(verbName)
	if not verb then
		LS13.Logging.LogError("Unknown verb: %s", verbName)
		local err = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.VERB_ERROR, {
			verb = verbName,
			error = error or "Unknown error"
		})
		networking.sendToClient(client.id, err)
		return
	end

	local data = verb:deserialize(rawData)
	verb.invoker = client

	local valid, error = verb:validate()
	if not valid then
		LS13.Logging.LogError("Verb validation failed: %s", error)
		local err = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.VERB_ERROR, {
			verbName = verbName,
			error = error or "Unknown error"
		})
		networking.sendToClient(client.id, err)
		return
	end

	if verb.processOnServer then
		local success, result = pcall(verb.processOnServer, verb, client.id)
		if not success then
			LS13.Logging.LogError("Verb processing failed: %s", result)
			local err = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.VERB_ERROR, {
				verbName = verbName,
				error = result or "Unknown error"
			})
			networking.sendToClient(client.id, err)
			return
		end
	end

	local broadcast = networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.VERB_BROADCAST, {
		verbName = verbName,
		verbData = data
	})
	networking.broadcastMessage(broadcast)
end

-- messageHandlers[networking.Protocol.MessageType.CHUNK_REQUEST] = function(client, message)
-- 	-- if client is not in any world, send empty chunk
-- 	if not client.worldId then
-- 		local chunkX = message.data.chunkX
-- 		local chunkY = message.data.chunkY
-- 		local chunkKey = chunkX .. "," .. chunkY
-- 		networking.sendChunkToClient(client.id, chunkKey, {})
-- 		return
-- 	end

-- 	local chunkX = message.data.chunkX
-- 	local chunkY = message.data.chunkY
-- 	local chunkKey = chunkX .. "," .. chunkY

-- 	local world = LS13.WorldManager.worlds[client.worldId]
-- 	if not world then
-- 		return
-- 	end

-- 	local worldEnt = world:getEntities()[1]
-- 	if worldEnt and worldEnt.World then
-- 		local chunkData = worldEnt.World.tilemap:serializeChunk(chunkKey)
-- 		if chunkData then
-- 			networking.sendChunkToClient(client.id, chunkKey, chunkData)
-- 			LS13.Logging.LogDebug("Sent chunk %s to client %s in world %s", chunkKey, client.id, client.worldId)
-- 		else
-- 			networking.sendChunkToClient(client.id, chunkKey, {})
-- 		end
-- 	end
-- end

messageHandlers[NETWORK_MESSAGE_TYPE.WORLD_SWITCH] = function(client, message)
	LS13.Logging.LogWarn("Client %s sent a dubvious packet type.", client.id)
	client.warnings += 1
end

messageHandlers[NETWORK_MESSAGE_TYPE.ENTITY_CREATE] = function(client, message)
	LS13.Logging.LogWarn("Client %s sent a dubious packet type.", client.id)
	client.warnings += 1
end

messageHandlers[NETWORK_MESSAGE_TYPE.ENTITY_UPDATE] = function(client, message)
	LS13.Logging.LogWarn("Client %s sent a dubious packet type.", client.id)
	client.warnings += 1
end

messageHandlers[NETWORK_MESSAGE_TYPE.ENTITY_DESTROY] = function(client, message)
	LS13.Logging.LogWarn("Client %s sent a dubious packet type.", client.id)
	client.warnings += 1
end

return networking
