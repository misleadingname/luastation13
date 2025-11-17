local EntityReceiver = {}

local entities = {}

local function getReplicationEntry(schema, fieldName)
	if not schema then return nil end
	for _, entry in ipairs(schema) do
		if entry.name == fieldName then
			return entry
		end
	end
	return nil
end

function EntityReceiver.getEntity(networkId)
	return entities[networkId]
end

function EntityReceiver.getAllEntities()
	return entities
end

local function readComponentSetFromBuffer(buf)
	local components = {}
	local count = buf:readUShort()
	for i = 1, count do
		local name = buf:readString()
		local info = LS13.ECS.Replication[name]
		local data = {}
		if info then
			for _, entry in ipairs(info) do
				data[entry.name] = LS13.Networking.Protocol.read(buf, entry.type)
			end
			components[name] = data
		else
			-- we don't know the schema, we cannot parse.
			LS13.Logging.LogWarn("Unknown replicated component '%s' received", tostring(name))
		end
	end
	return components
end

function EntityReceiver.handleEntityCreate(id, buf)
	local world = LS13.WorldManager.getCurrentWorld()
	if not world then
		return
	end

	local components = readComponentSetFromBuffer(buf)

	local entity = LS13.ECSManager.entity("NetworkEntity_" .. id)
	LS13.Logging.LogDebug("Received entity create for networkId: %d", id)

	for name, data in pairs(components) do
		if LS13.ECS.Components[name] then
			entity:ensure(name)
			local component = entity[name]
			if component then
				for k, v in pairs(data) do
					component[k] = v
				end
			end
		end
	end

	world:addEntity(entity)
	entities[id] = entity
end

-- Add brand new components to an existing entity
function EntityReceiver.handleEntityAdd(networkId, buf)
	local entity = entities[networkId]
	if not entity then return end
	local components = readComponentSetFromBuffer(buf)
	for name, data in pairs(components) do
		if LS13.ECS.Components[name] then
			entity:ensure(name)
			local component = entity[name]
			if component then
				for k, v in pairs(data) do
					component[k] = v
				end
			end
		end
	end
end

-- Update existing components' fields
function EntityReceiver.handleEntityUpdate(networkId, buf)
	local entity = entities[networkId]
	if not entity then
		return
	end

	local components = readComponentSetFromBuffer(buf)

	for compName, data in pairs(components) do
		if LS13.ECS.Components[compName] then
			entity:ensure(compName)
			local component = entity[compName]
			if component then
				local schema = LS13.ECS.Replication[compName]
				for fieldName, newValue in pairs(data) do
					local entry = getReplicationEntry(schema, fieldName)
					if entry and entry.lerp then
						local current = component[fieldName]
						if current ~= nil then
							LS13.ECS.Systems.InterpolationSystem.queueLerp(entity, compName, fieldName, current, newValue, entry.type)
						else
							component[fieldName] = newValue
						end
					else
						component[fieldName] = newValue
					end
				end
			end
		end
	end
end

function EntityReceiver.handleEntityRemove(networkId, buf)
	local entity = entities[networkId]
	if not entity then return end
	local count = buf:readUShort()
	for i = 1, count do
		local name = buf:readString()
		if entity[name] then
			-- cancel any active interpolations for this component before removal
			if LS13.ECS.Systems.InterpolationSystem then
				LS13.ECS.Systems.InterpolationSystem.cancelComponent(entity, name)
			end
			entity:remove(name)
		end
	end
end

function EntityReceiver.handleEntityDestroy(networkId)
	local entity = entities[networkId]
	if entity then
		local world = LS13.WorldManager.getCurrentWorld()
		if world then
			world:removeEntity(entity)
		end
		entities[networkId] = nil
	end
end

function EntityReceiver.clear()
	entities = {}
end

return EntityReceiver
