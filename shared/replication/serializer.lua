local serializer = {}

function serializer.deserializeEntity(entity, data)

end

function serializer.serializeComponentForReplication(component)
	if not component then
		return nil
	end

	local info = LS13.ECS.Replication[tostring(component)]
	if not info then return nil end

	local buf = LS13.Networking.Protocol.buffer.new()
	for _, entry in ipairs(info) do
		local name = entry.name
		local type = entry.type

		LS13.Networking.Protocol.write(buf, type, component[name])
	end

	return buf
end

function serializer.serializeEntityForReplication(entity)
	if not entity or not entity.Replicated then
		return nil
	end

	local data = LS13.Networking.Protocol.buffer.new()

	local components = {}
	for component, _ in ipairs(entity:getComponents()) do
		local name = tostring(component)
		if name ~= "Replicated" and LS13.ECS.Replication[name] then
			local replicatedData = serializer.serializeComponentForReplication(component)
			if replicatedData then
				components[name] = replicatedData
			end
		end
	end

	data:writeUShort(lume.count(components)) -- replicatable component count
	for name, data in pairs(components) do
		data:writeString(name)
		data:appendBuffer(data)
	end

	return data
end

function serializer.hasComponentChanged(entity, componentName, lastState)
	local component = entity[componentName]
	if not component then
		return false
	end

	local currentData = serializer.serializeComponentForReplication(component)
	local lastData = lastState[componentName]

	if not lastData then
		return true
	end

	if not currentData then
		return lastData ~= nil
	end

	for k, v in pairs(currentData) do
		if type(v) == "table" then
			local mt = getmetatable(v)
			if mt == "Vector2" then
				return not v:compare(lastData[k])
			end

			if mt == "Color" then
				return not v:compare(lastData[k])
			end
		end

		if lastData[k] ~= v then
			return true
		end
	end

	for k in pairs(lastData) do
		if currentData[k] == nil then
			return true
		end
	end

	return false
end

function serializer.getChangedComponents(entity, lastState)
	if not entity or not entity.Replicated then
		return {}
	end

	local changed = {}

	for componentName, component in pairs(entity:getComponents()) do
		if componentName ~= "Replicated" and type(component) == "table" then
			if serializer.hasComponentChanged(entity, componentName, lastState) then
				local replicatedData = serializer.serializeComponentForReplication(component)
				if replicatedData then
					changed[componentName] = replicatedData
				end
			end
		end
	end

	return changed
end

return serializer
