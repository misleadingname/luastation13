local playerCommand = require("shared.networking.playerCommand")

local schemas = {
	[NETWORK_MESSAGE_TYPE.PING] = {},
	[NETWORK_MESSAGE_TYPE.PONG] = {},

	[NETWORK_MESSAGE_TYPE.HANDSHAKE] = {
		{ "protoVersion", NETWORK_TYPE.USHORT },
		{ "clientVersion", NETWORK_TYPE.STRING },
		{ "playerName", NETWORK_TYPE.STRING }
	},

	[NETWORK_MESSAGE_TYPE.HANDSHAKE_RESPONSE] = {
		{ "serverVersion", NETWORK_TYPE.STRING },
		{ "clientId", NETWORK_TYPE.USHORT },
	},

	[NETWORK_MESSAGE_TYPE.PLAYER_COMMAND] = {
		{ "moveDirection", NETWORK_TYPE.VECTOR2 },
		{ "targetPosition", NETWORK_TYPE.VECTOR2 }
	},

	[NETWORK_MESSAGE_TYPE.VERB_REQUEST] = {
		{ "verbName", NETWORK_TYPE.STRING },
		{ "verbData", NETWORK_TYPE.RAW },
	},

	[NETWORK_MESSAGE_TYPE.VERB_ERROR] = {
		{ "verbName", NETWORK_TYPE.STRING },
		{ "error", NETWORK_TYPE.STRING }
	},

	[NETWORK_MESSAGE_TYPE.VERB_BROADCAST] = {
		{ "verbName", NETWORK_TYPE.STRING },
		{ "verbData", NETWORK_TYPE.RAW },
	},

	[NETWORK_MESSAGE_TYPE.GAME_STATE] = {
		{ "gameState", NETWORK_TYPE.BYTE },
		{ "stateTimer", NETWORK_TYPE.FLOAT }
	},

	[NETWORK_MESSAGE_TYPE.WORLD_SWITCH] = {
		{ "worldId", NETWORK_TYPE.STRING },
	},

	[NETWORK_MESSAGE_TYPE.CHUNK_REQUEST] = {
		{ "chunk", NETWORK_TYPE.VECTOR2I },
	}
}

local Protocol = {}
Protocol.buffer = require("shared.networking.buffer")


-- TODO: This is a dupe from serializer.lua !!! Condense into a single function somewhere
function Protocol.write(buf, type, value)
	if type == NETWORK_TYPE.RAW then
		buf:writeRaw(value)
	elseif type == NETWORK_TYPE.BOOL then
		buf:writeBool(value)
	elseif type == NETWORK_TYPE.BYTE then
		buf:writeByte(value)
	elseif type == NETWORK_TYPE.STRING then
		buf:writeString(value)
	elseif type == NETWORK_TYPE.USHORT then
		buf:writeUShort(value)
	elseif type == NETWORK_TYPE.SHORT then
		buf:writeShort(value)
	elseif type == NETWORK_TYPE.UINT then
		buf:writeUInt(value)
	elseif type == NETWORK_TYPE.INT then
		buf:writeInt(value)
	elseif type == NETWORK_TYPE.ULONG then
		buf:writeULong(value)
	elseif type == NETWORK_TYPE.LONG then
		buf:writeLong(value)
	elseif type == NETWORK_TYPE.FLOAT then
		buf:writeFloat(value)
	elseif type == NETWORK_TYPE.DOUBLE then
		buf:writeDouble(value)
	elseif type == NETWORK_TYPE.VECTOR2 then
		buf:writeVector2(value)
	elseif type == NETWORK_TYPE.VECTOR2I then
		buf:writeVector2i(value)
	elseif type == NETWORK_TYPE.COLOR then
		buf:writeColor(value)
	end
end

function Protocol.read(buf, type)
	if type == NETWORK_TYPE.RAW then
		return buf:readRaw()
	elseif type == NETWORK_TYPE.BOOL then
		return buf:readBool()
	elseif type == NETWORK_TYPE.BYTE then
		return buf:readByte()
	elseif type == NETWORK_TYPE.STRING then
		return buf:readString()
	elseif type == NETWORK_TYPE.USHORT then
		return buf:readUShort()
	elseif type == NETWORK_TYPE.SHORT then
		return buf:readShort()
	elseif type == NETWORK_TYPE.UINT then
		return buf:readUInt()
	elseif type == NETWORK_TYPE.INT then
		return buf:readInt()
	elseif type == NETWORK_TYPE.ULONG then
		return buf:readULong()
	elseif type == NETWORK_TYPE.LONG then
		return buf:readLong()
	elseif type == NETWORK_TYPE.FLOAT then
		return buf:readFloat()
	elseif type == NETWORK_TYPE.DOUBLE then
		return buf:readDouble()
	elseif type == NETWORK_TYPE.VECTOR2 then
		return buf:readVector2()
	elseif type == NETWORK_TYPE.VECTOR2I then
		return buf:readVector2i()
	elseif type == NETWORK_TYPE.COLOR then
		return buf:readColor()
	end
end

function Protocol.createMessage(type)
	local msg = Protocol.buffer.new()
	msg:writeByte(type)
	-- msg:writeFloat(1) -- TODO: implement networked curtime

	return msg
end

function Protocol.createMessageEx(type, data)
	local sch = schemas[type]
	if not sch then
		error("Invalid message type " .. type)
	end
	local buf = Protocol.createMessage(type)

	for i = 1, #sch do
		local k, v = sch[i][1], sch[i][2]
		if data[k] == nil then
			LS13.Logging.LogWarn("Missing field \"%s\", expected type %s", k, lume.invert(NETWORK_TYPE)[v])
		end
		Protocol.write(buf, v, data[k])
	end

	return buf
end

function Protocol.deserialize(msg)
	local buf = Protocol.buffer.fromString(msg)

	local type = buf:readByte()
	local timestamp = 0

	return type, timestamp, buf
end

function Protocol.deserializeEx(buf, type)
	local sch = schemas[type]
	if not sch then
		error("Invalid message type " .. type)
	end

	local data = {}
	for i = 1, #sch do
		local k, v = sch[i][1], sch[i][2]
		data[k] = Protocol.read(buf, v)
	end

	return data
end

function Protocol.preparePlayerCommand()
	return playerCommand.new()
end

return Protocol
