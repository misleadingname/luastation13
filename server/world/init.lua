local WorldManager = {}
WorldManager.worlds = {}

function WorldManager.newWorld(name)
	if not WorldManager.worlds then
		return nil
	end

	if WorldManager.worlds[name] then
		return nil
	end

	local world = LS13.ECSManager.world()
	world:addSystems(LS13.ECS.Systems.ChunkSyncSystem)
	world:addSystems(LS13.ECS.Systems.InteractionSystem)
	world:addSystems(LS13.ECS.Systems.EntitySyncSystem)
	world:addSystems(LS13.ECS.Systems.SentienceSystem)
	world:addSystems(LS13.ECS.Systems.BasicTempCharSystem)

	local worldEntity = LS13.ECSManager.entity("World")
	worldEntity:give("World")
	worldEntity.World.worldId = name
	world:addEntity(worldEntity)

	WorldManager.worlds[name] = world

	return world
end

function WorldManager.update(dt)
	for _, world in pairs(WorldManager.worlds) do
		world:emit("update", dt)
	end
end

function WorldManager.switchWorld(client, worldId)
	if worldId ~= nil and not WorldManager.worlds[worldId] then
		LS13.Logging.LogError("Cannot switch client %s to non-existent world %s", client.id, worldId)
		return false
	end

	client.worldId = worldId

	if worldId then
		local message = LS13.Networking.Protocol.createWorldSwitch(worldId)
		LS13.Networking.sendToClient(client.id, message)
		WorldManager.sendWorldDataToClient(client.id, worldId)
		LS13.Logging.LogInfo("Switched client %s to world %s", client.id, worldId)
	else
		local message = LS13.Networking.Protocol.createWorldSwitch("nil")
		LS13.Networking.sendToClient(client.id, message)
		LS13.Logging.LogInfo("Switched client %s to no world", client.id)
	end

	return true
end

function WorldManager.sendWorldDataToClient(clientId, worldId)
	local world = WorldManager.worlds[worldId]
	if not world then
		return false
	end

	local worldEnt = world:getEntities()[1]
	if not worldEnt or not worldEnt.World then
		return false
	end

	local tilemap = worldEnt.World.tilemap
	local worldData = {
		chunks = {},
		metadata = { worldId = worldId },
	}

	for chunkKey, chunk in pairs(tilemap.chunks) do
		worldData.chunks[chunkKey] = tilemap:serializeChunk(chunkKey)
	end

	local message = LS13.Networking.Protocol.createWorldInit(worldData)
	return LS13.Networking.sendToClient(clientId, message)
end

function WorldManager.getClientsInWorld(worldId)
	local clientsInWorld = {}
	for clientId, client in pairs(LS13.Networking.getClients()) do
		if client.worldId == worldId then
			table.insert(clientsInWorld, client)
		end
	end
	return clientsInWorld
end

function WorldManager.getClientsInNoWorld()
	local clientsInNoWorld = {}
	for clientId, client in pairs(LS13.Networking.getClients()) do
		if client.worldId == nil then
			table.insert(clientsInNoWorld, client)
		end
	end
	return clientsInNoWorld
end

function WorldManager.getWorldOfClient(clientId)
	local client = LS13.Networking.getClientById(clientId)
	if client then
		return WorldManager.worlds[client.worldId]
	end
	return nil
end

function WorldManager.getWorld(worldId)
	if not WorldManager.worlds[worldId] then
		LS13.Logging.LogWarn("Tried to get world %s, but there's none.", worldId)
		return nil
	end

	return WorldManager.worlds[worldId]
end

function WorldManager.deleteWorld(worldId)
	if not WorldManager.worlds[worldId] then
		LS13.Logging.LogError("Cannot delete non-existent world: %s", worldId)
		return false
	end

	local clientsInWorld = WorldManager.getClientsInWorld(worldId)
	for _, client in ipairs(clientsInWorld) do
		LS13.Logging.LogInfo("Moving client %s from deleted world %s to nil world", client.id, worldId)
		WorldManager.switchWorld(client, nil)
	end

	WorldManager.worlds[worldId] = nil
	LS13.Logging.LogInfo("Deleted world %s and moved %d clients to nil world", worldId, #clientsInWorld)
	return true
end

return WorldManager
