local chunkSyncSystem = LS13.ECSManager.system({ pool = { "World" } })

local updateInterval = 1 / 10

function chunkSyncSystem:init(world)
	self.lastUpdate = 0
end

function chunkSyncSystem:update(dt)
	local currentTime = love.timer.getTime()

	if currentTime - self.lastUpdate < updateInterval then
		return
	end
	self.lastUpdate = currentTime

	local worldEnt = self.pool[1]
	if not worldEnt or not worldEnt.World then
		return
	end

	local tilemap = worldEnt.World.tilemap

	local dirtyChunks = tilemap:getDirtyChunks()

	for chunkKey, _ in pairs(dirtyChunks) do
		local chunkData = tilemap:serializeChunk(chunkKey)
		if chunkData then
			local worldId = worldEnt.World.worldId
			local clientsInWorld = LS13.WorldManager.getClientsInWorld(worldId)

			for _, client in ipairs(clientsInWorld) do
				LS13.Networking.sendChunkToClient(client.id, chunkKey, chunkData)
			end

			LS13.Logging.LogDebug(
				"Broadcasted chunk update %s to %d clients in world %s",
				chunkKey,
				#clientsInWorld,
				worldId
			)
		end
	end
end

LS13.ECS.Systems.ChunkSyncSystem = chunkSyncSystem
