local serializer = {}
local buffer = require("shared.networking.buffer")

function serializer.serializeComponentForReplication(component)
	if not component then
		return nil
	end

	local info = component.replicationInfo
	local data = buffer.new()
	for k, v in pairs(info) do -- this might be out of order, but technically shouldn't ever be
		local type = v.type
		local value = component[k]

		-- lua not having switches is wild
		if type == NETWORK_TYPE.RAW then
			buffer:writeRaw(value)
		elseif type == NETWORK_TYPE.BOOL then
			buffer:writeBool(value)
		elseif type == NETWORK_TYPE.BYTE then
			buffer:writeByte(value)
		elseif type == NETWORK_TYPE.STRING then
			buffer:writeString(value)
		elseif type == NETWORK_TYPE.USHORT then
			buffer:writeUShort(value)
		elseif type == NETWORK_TYPE.SHORT then
			buffer:writeShort(value)
		elseif type == NETWORK_TYPE.UINT then
			buffer:writeUInt(value)
		elseif type == NETWORK_TYPE.INT then
			buffer:writeInt(value)
		elseif type == NETWORK_TYPE.ULONG then
			buffer:writeULong(value)
		elseif type == NETWORK_TYPE.LONG then
			buffer:writeLong(value)
		elseif type == NETWORK_TYPE.FLOAT then
			buffer:writeFloat(value)
		elseif type == NETWORK_TYPE.DOUBLE then
			buffer:writeDouble(value)
		elseif type == NETWORK_TYPE.VECTOR2 then
			buffer:writeFloat(value.x)
			buffer:writeFloat(value.y)
		elseif type == NETWORK_TYPE.VECTOR2I then
			buffer:writeInt(value.x)
			buffer:writeInt(value.y)
		elseif type == NETWORK_TYPE.COLOR then
			buffer:writeByte(value.r)
			buffer:writeByte(value.g)
			buffer:writeByte(value.b)
			buffer:writeByte(value.a)
		end
	end

	return data
end

function serializer.serializeEntityForReplication(entity)
	if not entity or not entity.Replicated then
		return nil
	end

	local data = buffer.new()
	data:writeUInt(entity.Replicated.networkId) -- network ID

	local components = {}
	for componentName, component in pairs(entity:getComponents()) do
		if componentName ~= "Replicated" and type(component) == "table" and component.replicationInfo then
			local replicatedData = serializer.serializeComponentForReplication(component)
			if replicatedData then
				components[componentName] = replicatedData
			end
		end
	end

	local count = lume.count(components)
	data:writeUShort(count) -- replicatable component count

	for componentName, replicatedData in pairs(components) do
		data:writeString(componentName)
		data:appendBuffer(replicatedData)
	end

	return data
end

return serializer
