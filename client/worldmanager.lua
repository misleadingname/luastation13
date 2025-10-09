local WorldManager = {}
WorldManager.worlds = {}
WorldManager.currentWorldId = nil

function WorldManager.newWorld(name)
	if not WorldManager.worlds then
		return nil
	end

	if WorldManager.worlds[name] then
		return nil
	end

	local world = LS13.ECSManager.world()
	world:addSystems(LS13.ECS.Systems.RenderTilemapSystem)
	world:addSystems(LS13.ECS.Systems.RenderEntitiesSystem)

	local worldEntity = LS13.ECSManager.entity("World")
	worldEntity:give("World")
	worldEntity.World.worldId = name
	world:addEntity(worldEntity)

	WorldManager.worlds[name] = world

	return world
end

function WorldManager.switchToWorld(worldId)
	if worldId ~= nil and not WorldManager.worlds[worldId] then
		LS13.Logging.LogError("Cannot switch to non-existent world: %s", worldId)
		return false
	end

	WorldManager.currentWorldId = worldId

	if worldId then
		LS13.Logging.LogInfo("Switched to world: %s", worldId)
	else
		LS13.Logging.LogInfo("Switched to no world")
	end
	return true
end

function WorldManager.getCurrentWorld()
	if WorldManager.currentWorldId then
		return WorldManager.worlds[WorldManager.currentWorldId]
	end
	return nil
end

function WorldManager.getCurrentWorldId()
	return WorldManager.currentWorldId
end

function WorldManager.getWorld(worldId)
	return WorldManager.worlds[worldId]
end

function WorldManager.update(dt)
	local currentWorld = WorldManager.getCurrentWorld()
	if currentWorld then
		currentWorld:emit("update", dt)
	end
end

function WorldManager.deleteWorld(worldId)
	if not WorldManager.worlds[worldId] then
		LS13.Logging.LogError("Cannot delete non-existent world: %s", worldId)
		return false
	end

	if WorldManager.currentWorldId == worldId then
		LS13.Logging.LogInfo("Deleting current world %s, switching to nil world", worldId)
		WorldManager.switchToWorld(nil)
	end

	WorldManager.worlds[worldId] = nil
	LS13.Logging.LogInfo("Deleted world: %s", worldId)
	return true
end

return WorldManager
