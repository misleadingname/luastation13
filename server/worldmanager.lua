local WorldManager = {}

function WorldManager.init()
	WorldManager.worlds = {}
end

function WorldManager.newWorld(name)
	if not WorldManager.worlds then
		return nil
	end

	if WorldManager.worlds[name] then
		return nil
	end

	local world = LS13.ECSManager.world()
	world:addSystems(LS13.ECS.Systems.ChunkSyncSystem)

	local worldEntity = LS13.ECSManager.entity("World")
	worldEntity:give("World")
	world:addEntity(worldEntity)

	WorldManager.worlds[name] = world

	return world
end

function WorldManager.update(dt) end

return WorldManager
