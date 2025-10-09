local bitser = require("lib.bitser.bitser")

local Protocol = {}
Protocol.Version = 1

Protocol.MessageType = {
	HANDSHAKE = "HANDSHAKE",
	HANDSHAKE_RESPONSE = "HANDSHAKE_RESPONSE",
	DISCONNECT = "DISCONNECT",

	GAME_STATE = "GAME_STATE",

	VERB_REQUEST = "VERB_REQUEST",
	VERB_BROADCAST = "VERB_BROADCAST",
	VERB_ERROR = "VERB_ERROR",

	WORLD_INIT = "WORLD_INIT",
	WORLD_SWITCH = "WORLD_SWITCH",
	CHUNK_UPDATE = "CHUNK_UPDATE",
	CHUNK_REQUEST = "CHUNK_REQUEST",

	PING = "PING",
	PONG = "PONG",
	HEARTBEAT = "HEARTBEAT"
}

local messageSchemas = {
	[Protocol.MessageType.HANDSHAKE] = {
		networkProtocolVersion = "number",
		clientVersion = "string",
		playerName = "string"
	},
	[Protocol.MessageType.VERB_REQUEST] = {
		verbName = "string",
		verbData = "table"
	},
	[Protocol.MessageType.VERB_BROADCAST] = {
		verbName = "string",
		verbData = "table",
		sourceClient = "string"
	},
	[Protocol.MessageType.WORLD_INIT] = {
		worldId = "string",
	},
	[Protocol.MessageType.WORLD_SWITCH] = {
		worldId = "string",
	},
	[Protocol.MessageType.CHUNK_REQUEST] = {
		chunkX = "number",
		chunkY = "number"
	},
	[Protocol.MessageType.CHUNK_UPDATE] = {
		chunkKey = "string",
		chunkData = "table"
	},
	[Protocol.MessageType.GAME_STATE] = {
		state = "string",
	}
}

function Protocol.createMessage(messageType, data)
	local message = {
		type = messageType,
		timestamp = love.timer.getTime(),
		data = data or {}
	}

	return message
end

function Protocol.sanitizeData(data)
	if type(data) ~= "table" then
		return data
	end

	local sanitized = {}
	for k, v in pairs(data) do
		local valueType = type(v)
		if valueType == "table" then
			local metatable = getmetatable(v)
			if metatable == "Vector2" then
				sanitized[k] = { x = v.x, y = v.y, _type = "Vector2" }
			elseif metatable == "Color" then
				sanitized[k] = { r = v.r, g = v.g, b = v.b, a = v.a, _type = "Color" }
			else
				sanitized[k] = Protocol.sanitizeData(v)
			end
		elseif valueType == "userdata" or valueType == "function" or valueType == "thread" then
			LS13.Logging.LogWarning("Skipping non-serializable %s in verb data: %s", valueType, tostring(k))
		else
			sanitized[k] = v
		end
	end
	return sanitized
end

function Protocol.restoreData(data)
	if type(data) ~= "table" then
		return data
	end

	local restored = {}
	for k, v in pairs(data) do
		if type(v) == "table" and v._type then
			if v._type == "Vector2" then
				restored[k] = Vector2.new(v.x, v.y)
			elseif v._type == "Color" then
				restored[k] = Color.new(v.r, v.g, v.b, v.a)
			else
				restored[k] = v
			end
		elseif type(v) == "table" then
			restored[k] = Protocol.restoreData(v)
		else
			restored[k] = v
		end
	end
	return restored
end

function Protocol.serialize(message)
	local sanitizedMessage = {
		type = message.type,
		timestamp = message.timestamp,
		data = Protocol.sanitizeData(message.data)
	}

	local success, serialized = pcall(bitser.dumps, sanitizedMessage)
	if not success then
		LS13.Logging.LogError("Failed to serialize message: %s", serialized)
		LS13.Logging.LogError("Message type: %s", message.type)
		if DEBUG then
			LS13.Util.PrintTable(sanitizedMessage)
		end
		return nil
	end
	return serialized
end

function Protocol.deserialize(data)
	local success, message = pcall(bitser.loads, data)
	if not success then
		LS13.Logging.LogError("Failed to deserialize message: %s", message)
		return nil
	end

	-- Restore sanitized data
	if message and message.data then
		message.data = Protocol.restoreData(message.data)
	end

	return message
end

function Protocol.validateMessage(message)
	if type(message) ~= "table" then
		return false, "Message must be a table"
	end

	if not message.type then
		return false, "Message missing type field"
	end

	if not Protocol.MessageType[message.type] then
		return false, "Unknown message type: " .. tostring(message.type)
	end

	local schema = messageSchemas[message.type]
	if schema and message.data then
		for field, expectedType in pairs(schema) do
			local actualType = type(message.data[field])
			if actualType ~= expectedType then
				return false, string.format("Field '%s' expected %s, got %s", field, expectedType, actualType)
			end
		end
	end

	return true, nil
end

function Protocol.createHandshake(clientVersion, playerName)
	return Protocol.createMessage(Protocol.MessageType.HANDSHAKE, {
		networkProtocolVersion = Protocol.Version,
		clientVersion = clientVersion,
		playerName = playerName
	})
end

function Protocol.createVerbRequest(verbName, verbData)
	return Protocol.createMessage(Protocol.MessageType.VERB_REQUEST, {
		verbName = verbName,
		verbData = verbData
	})
end

function Protocol.createVerbBroadcast(verbName, verbData, sourceClient)
	return Protocol.createMessage(Protocol.MessageType.VERB_BROADCAST, {
		verbName = verbName,
		verbData = verbData,
		sourceClient = sourceClient or "server"
	})
end

function Protocol.createChunkRequest(chunkX, chunkY)
	return Protocol.createMessage(Protocol.MessageType.CHUNK_REQUEST, {
		chunkX = chunkX,
		chunkY = chunkY
	})
end

function Protocol.createChunkUpdate(chunkKey, chunkData)
	return Protocol.createMessage(Protocol.MessageType.CHUNK_UPDATE, {
		chunkKey = chunkKey,
		chunkData = chunkData
	})
end

function Protocol.createWorldInit(worldData)
	return Protocol.createMessage(Protocol.MessageType.WORLD_INIT, {
		chunks = worldData.chunks or {},
		metadata = worldData.metadata or {}
	})
end

function Protocol.createVerbError(errorMessage, originalVerb)
	return Protocol.createMessage(Protocol.MessageType.VERB_ERROR, {
		error = errorMessage,
		originalVerb = originalVerb
	})
end

function Protocol.createWorldSwitch(worldId)
	return Protocol.createMessage(Protocol.MessageType.WORLD_SWITCH, {
		worldId = worldId
	})
end

return Protocol

