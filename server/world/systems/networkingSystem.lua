-- Server-side Networking System
-- Handles broadcasting dirty chunks to clients

local networkingSystem = LS13.ECSManager.system({ pool = { "World" } })

local updateInterval = 1/10 -- 10 Hz update rate for chunk broadcasting
local lastUpdate = 0

function networkingSystem:update(dt)
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
    
    -- Broadcast updates to all connected clients
    for chunkKey, _ in pairs(dirtyChunks) do
        local chunkData = tilemap:serializeChunk(chunkKey)
        if chunkData then
            -- Broadcast chunk update to all clients
            if LS13.Networking and LS13.Networking.broadcastAction then
                LS13.Networking.broadcastAction("ChunkUpdate", {
                    chunkKey = chunkKey,
                    chunkData = chunkData
                })
            end
            
            LS13.Logging.LogDebug("Broadcasted chunk update: %s", chunkKey)
        end
    end
end

LS13.ECS.Systems.NetworkingSystem = networkingSystem
