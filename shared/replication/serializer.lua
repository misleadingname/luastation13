local Serializer = {}

function Serializer.serializeComponentForReplication(component)
	if not component then
		return nil
	end

	local data
	if component.getReplicatedData then
		data = component:getReplicatedData()
	else
		data = {}
		for k, v in pairs(component) do
			if not k:match("^_") and type(v) ~= "userdata" and type(v) ~= "function" then
				data[k] = v
			end
		end
	end

	return data
end

function Serializer.serializeEntityForReplication(entity)
	if not entity or not entity.Replicated then
		return nil
	end

	local serialized = {
		networkId = entity.Replicated.networkId,
		components = {}
	}

	for componentName, component in pairs(entity:getComponents()) do
		if componentName ~= "Replicated" and type(component) == "table" then
			LS13.Logging.LogDebug("Serializing component: " .. componentName)
			local replicatedData = Serializer.serializeComponentForReplication(component)
			if replicatedData then
				serialized.components[componentName] = replicatedData
			end
		end
	end

	return serialized
end

function Serializer.serializeEntityForReplication(entity)
	if not entity or not entity.Replicated then
		return nil
	end

	local serialized = {
		networkId = entity.Replicated.networkId,
		components = {}
	}

	for componentName, component in pairs(entity:getComponents()) do
		if componentName ~= "Replicated" and type(component) == "table" then
			local replicatedData = Serializer.serializeComponentForReplication(component)
			if replicatedData then
				serialized.components[componentName] = replicatedData
			end
		end
	end

	return serialized
end

function Serializer.hasComponentChanged(entity, componentName, lastState)
	local component = entity[componentName]
	if not component then
		return false
	end

	local currentData = Serializer.serializeComponentForReplication(component)
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

function Serializer.getChangedComponents(entity, lastState)
	if not entity or not entity.Replicated then
		return {}
	end

	local changed = {}

	for componentName, component in pairs(entity:getComponents()) do
		if componentName ~= "Replicated" and type(component) == "table" then
			if Serializer.hasComponentChanged(entity, componentName, lastState) then
				local replicatedData = Serializer.serializeComponentForReplication(component)
				if replicatedData then
					changed[componentName] = replicatedData
				end
			end
		end
	end

	return changed
end

return Serializer
