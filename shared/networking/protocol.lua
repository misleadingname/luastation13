local playerCommand = require("shared.networking.playerCommand")
local buffer = require("shared.networking.buffer")

local schemas = {
	[NETWORK_MESSAGE_TYPE.HANDSHAKE] = {
		protoVersion = NETWORK_TYPE.USHORT,
		clientVersion = NETWORK_TYPE.STRING,
		playerName = NETWORK_TYPE.STRING
	},

	[NETWORK_MESSAGE_TYPE.HANDSHAKE_RESPONSE] = {
		serverVersion = NETWORK_TYPE.STRING,
		clientId = NETWORK_TYPE.USHORT,
		gameState = NETWORK_TYPE.BYTE,
	},

	[NETWORK_MESSAGE_TYPE.GAME_STATE] = {
		gameState = NETWORK_TYPE.BYTE,
	},

	[NETWORK_MESSAGE_TYPE.CHUNK_REQUEST] = {
		chunk = NETWORK_TYPE.VECTOR2I,
	}
}

-- TODO: This is a dupe from serializer.lua !!! Condense into a single function somewhere
local function write(buf, type, value)
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

local Protocol = {}

function Protocol.createMessage()
	local msg = buffer.new()
	msg:writeFloat(0) -- TODO: implement networked curtime

	return msg
end

function Protocol.createMessageEx(type, ...)
	local sch = schemas[type]
	if not sch then error("Invalid message type") end
	local buf = Protocol.createMessage()

	local data = { ... }
	for k, v in pairs(sch) do
		write(buf, v, data[k])
	end

	return buf
end

function Protocol.deserialize(msg)
	local buf = buffer.fromString(msg)
	return buf:readByte(), buf -- NETWORK_MESSAGE_TYPE, Rest of the buffer
end

function Protocol.preparePlayerCommand()
	return playerCommand.new()
end

return Protocol
