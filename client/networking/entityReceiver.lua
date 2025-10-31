local EntityReceiver = {}

local entities = {}

function EntityReceiver.getEntity(networkId)
	return entities[networkId]
end

function EntityReceiver.getAllEntities()
	return entities
end

function EntityReceiver.handleEntityCreate(networkId, components)
	local world = LS13.WorldManager.getCurrentWorld()
	if not world then
		return
	end

	local entity = LS13.ECSManager.entity("NetworkEntity_" .. networkId)
	LS13.Logging.LogDebug("Received entity create for networkId: %d", networkId)

	for componentName, componentData in pairs(components) do
		local componentClass = LS13.ECS.Components[componentName]
		if componentClass then
			entity:ensure(componentName)
			local component = entity[componentName]
			if component then
				for k, v in pairs(componentData) do
					component[k] = v
				end
			end
		end
	end

	world:addEntity(entity)
	entities[networkId] = entity
end

function EntityReceiver.handleEntityUpdate(networkId, components)
	local entity = entities[networkId]
	if not entity then
		return
	end

	for componentName, componentData in pairs(components) do
		local component = entity[componentName]
		if component then
			for k, v in pairs(componentData) do
				component[k] = v
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
