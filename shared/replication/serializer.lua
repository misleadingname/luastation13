local serializer = {}

function serializer.serializeComponentForReplication(component)
	if not component then
		LS13.Logging.LogError("Tried to serialize nil component")
		return nil
	end

	local info = LS13.ECS.Replication[component:getName()]
	if not info then
		return nil
	end

	local buf = buffer.new()
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

	local data = buffer.new()

	local components = {}
	for name, component in pairs(entity:getComponents()) do
		if LS13.ECS.Replication[name] then
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

	return tostring(currentData) ~= tostring(lastData)
end

function serializer.getChangedComponents(entity, lastState)
	if not entity or not entity.Replicated then
		return {}
	end

    local changed = {}
    for name, component in pairs(entity:getComponents()) do
		if type(component) == "table" then
			if serializer.hasComponentChanged(entity, name, lastState) then
				local replicatedData = serializer.serializeComponentForReplication(component)
				if replicatedData then
					changed[name] = replicatedData
				end
			end
		end
	end

	return changed
end

return serializer
