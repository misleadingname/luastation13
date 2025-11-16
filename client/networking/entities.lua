local EntityReceiver = {}

local entities = {}

function EntityReceiver.getEntity(networkId)
	return entities[networkId]
end

function EntityReceiver.getAllEntities()
	return entities
end

function EntityReceiver.handleEntityCreate(id, buf)
	local world = LS13.WorldManager.getCurrentWorld()
	if not world then
		return
	end

	local components = {}
	local count = buf:readUShort()
	print(count)

	for i = 1, count do
		local name = buf:readString()
		local info = LS13.ECS.Replication[name]
		local data = {}

		if not info then continue end
		for _, entry in ipairs(info) do
			data[entry.name] = LS13.Networking.Protocol.read(buf, entry.type)
		end

		components[name] = data
	end

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

function EntityReceiver.handleEntityUpdate(networkId, buf)
	local entity = entities[networkId]
	if not entity then
		return
	end

	local components = {}
	local count = buf:readUShort()
	print(count)

	for i = 1, count do
		local name = buf:readString()
		local info = LS13.ECS.Replication[name]
		local data = {}

		if not info then continue end
		for _, entry in ipairs(info) do
			data[entry.name] = LS13.Networking.Protocol.read(buf, entry.type)
		end

		components[name] = data
	end

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
