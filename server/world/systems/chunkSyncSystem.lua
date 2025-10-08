-- Server-side Networking System For Chunks
-- Handles broadcasting dirty chunks to clients

local chunkSyncSystem = LS13.ECSManager.system({ pool = { "World" } })

local updateInterval = 1 / 10 -- 10 Hz update rate for chunk broadcasting
local lastUpdate = 0

function chunkSyncSystem:update(dt)
	local currentTime = love.timer.getTime()

	-- Only process at the specified interval
	if currentTime - lastUpdate < updateInterval then
		return
	end
	lastUpdate = currentTime

	local worldEnt = self.pool[1]
	if not worldEnt or not worldEnt.World then
		return
	end

	local tilemap = worldEnt.World.tilemap

	-- Get dirty chunks
	local dirtyChunks = tilemap:getDirtyChunks()

	-- Broadcast updates to all clients in this world
	for chunkKey, _ in pairs(dirtyChunks) do
		local chunkData = tilemap:serializeChunk(chunkKey)
		if chunkData then
			-- TODO: broadcast chunk update to all clients in this world

			LS13.Logging.LogDebug("Broadcasted chunk update: %s", chunkKey)
		end
	end
end

LS13.ECS.Systems.ChunkSyncSystem = chunkSyncSystem
