local debugOverlay = {}

local W = love.graphics.getWidth
local H = love.graphics.getHeight

local init = false
local font

local networkStats = {
	messagesReceived = 0,
	messagesSent = 0,
	bytesReceived = 0,
	bytesSent = 0,
	lastResetTime = 0,
	verbsProcessed = 0,
	chunksReceived = 0,
	connectionTime = 0
}

local function formatBytes(bytes)
	if bytes < 1024 then
		return string.format("%d B", bytes)
	elseif bytes < 1024 * 1024 then
		return string.format("%.1f KB", bytes / 1024)
	else
		return string.format("%.1f MB", bytes / (1024 * 1024))
	end
end

local function formatTime(seconds)
	if seconds < 60 then
		return string.format("%.1fs", seconds)
	elseif seconds < 3600 then
		return string.format("%dm %.0fs", math.floor(seconds / 60), seconds % 60)
	else
		return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
	end
end

local lines = {
	{
		Text = function()
			return "-- ENGINE --"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			return string.format("%s FPS", love.timer.getFPS())
		end,
		Color = function()
			local g = love.timer.getFPS() / 60
			return { 1, g, g, 1 }
		end,
	},

	{
		Text = function()
			return string.format("t: %ss", love.timer.getTime())
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			return string.format("state: %s", LS13.StateManager.currentState.name)
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			return "-- NETWORK --"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			if LS13.Networking then
				local state = LS13.Networking.getConnectionState and LS13.Networking.getConnectionState() or "unknown"
				return string.format("connection: %s", state)
			else
				return "connection: no networking"
			end
		end,
		Color = function()
			if LS13.Networking then
				local connected = LS13.Networking.isConnected and LS13.Networking.isConnected() or false
				return connected and { 0, 1, 0, 1 } or { 1, 0.5, 0, 1 }
			else
				return { 1, 0, 0, 1 }
			end
		end,
	},

	{
		Text = function()
			if LS13.Networking and LS13.Networking.getClientId then
				local clientId = LS13.Networking.getClientId()
				return string.format("client ID: %s", clientId or "none")
			else
				return "client ID: unavailable"
			end
		end,
		Color = function()
			return { 0.8, 0.8, 1, 1 }
		end,
	},

	{
		Text = function()
			return string.format("connecting to: %s", LS13.Networking and LS13.Networking.ConnectingIp or "none")
		end,
		Color = function()
			return { 0.7, 0.7, 0.7, 1 }
		end,
	},

	{
		Text = function()
			return "-- VERBS --"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			if LS13.VerbSystem then
				local verbs = LS13.VerbSystem.getAllVerbs()
				local count = 0
				for _ in pairs(verbs) do count = count + 1 end
				return string.format("registered verbs: %d", count)
			else
				return "registered verbs: no system"
			end
		end,
		Color = function()
			return { 0.5, 1, 0.5, 1 }
		end,
	},

	{
		Text = function()
			if LS13.VerbSystem then
				local verbs = LS13.VerbSystem.getAllVerbs()
				local verbNames = {}
				for name, _ in pairs(verbs) do
					table.insert(verbNames, name)
				end
				table.sort(verbNames)
				return string.format("verbs: %s", table.concat(verbNames, ", "))
			else
				return "verbs: none"
			end
		end,
		Color = function()
			return { 0.7, 0.9, 0.7, 1 }
		end,
	},

	{
		Text = function()
			return "-- WORLD --"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			if LS13.ECSManager and LS13.ECSManager.world then
				local entities = LS13.ECSManager.world:getEntities()
				return string.format("entities: %s", entities and #entities or "nil table")
			else
				return "entities: no world"
			end
		end,
		Color = function()
			return { 1, 0.8, 0.5, 1 }
		end,
	},

	{
		Text = function()
			if LS13.ECSManager and LS13.ECSManager.world then
				local ents = LS13.ECSManager.world:getEntities()
				if not ents or #ents == 0 then return "tilemap chunks: no world" end
				local worldEnt = ents[1]
				if worldEnt and worldEnt.World and worldEnt.World.tilemap then
					local chunkCount = 0
					for _ in pairs(worldEnt.World.tilemap.chunks) do
						chunkCount = chunkCount + 1
					end
					return string.format("tilemap chunks: %d", chunkCount)
				else
					return "tilemap chunks: no tilemap"
				end
			else
				return "tilemap chunks: no world"
			end
		end,
		Color = function()
			return { 0.5, 0.8, 1, 1 }
		end,
	},

	{
		Text = function()
			if LS13.ECSManager and LS13.ECSManager.world then
				local ents = LS13.ECSManager.world:getEntities()
				if not ents or #ents == 0 then return "total tiles: no world" end
				local worldEnt = ents[1]
				if worldEnt and worldEnt.World and worldEnt.World.tilemap then
					local tilemap = worldEnt.World.tilemap
					local tileCount = 0
					for _, chunk in pairs(tilemap.chunks) do
						for i = 1, tilemap.CHUNK_SIZE * tilemap.CHUNK_SIZE do
							if chunk[i] then
								tileCount = tileCount + 1
							end
						end
					end
					return string.format("total tiles: %d", tileCount)
				else
					return "total tiles: no tilemap"
				end
			else
				return "total tiles: no world"
			end
		end,
		Color = function()
			return { 0.7, 0.7, 1, 1 }
		end,
	},

	{
		Text = function()
			if LS13.ECSManager and LS13.ECSManager.world then
				local ents = LS13.ECSManager.world:getEntities()
				if not ents or #ents == 0 then return "dirty chunks: no world" end
				local worldEnt = ents[1]
				if worldEnt and worldEnt.World and worldEnt.World.tilemap and worldEnt.World.tilemap.dirtyChunks then
					local dirtyCount = 0
					for _ in pairs(worldEnt.World.tilemap.dirtyChunks) do
						dirtyCount = dirtyCount + 1
					end
					return string.format("dirty chunks: %d", dirtyCount)
				else
					return "dirty chunks: 0"
				end
			else
				return "dirty chunks: no world"
			end
		end,
		Color = function()
			if LS13.ECSManager and LS13.ECSManager.world then
				local ents = LS13.ECSManager.world:getEntities()
				if not ents or #ents == 0 then return { 0.5, 0.5, 0.5, 1 } end
				local worldEnt = ents[1]
				if worldEnt and worldEnt.World and worldEnt.World.tilemap and worldEnt.World.tilemap.dirtyChunks then
					local dirtyCount = 0
					for _ in pairs(worldEnt.World.tilemap.dirtyChunks) do
						dirtyCount = dirtyCount + 1
					end
					return dirtyCount > 0 and { 1, 1, 0, 1 } or { 0.5, 0.5, 0.5, 1 }
				end
			end
			return { 0.5, 0.5, 0.5, 1 }
		end,
	},

	{
		Text = function()
			return "-- PERFORMANCE --"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			local memUsage = collectgarbage("count")
			return string.format("memory: %.2f MB", memUsage / 1024)
		end,
		Color = function()
			local memUsage = collectgarbage("count") / 1024
			if memUsage > 100 then
				return { 1, 0, 0, 1 }
			elseif memUsage > 50 then
				return { 1, 1, 0, 1 }
			else
				return { 0, 1, 0, 1 }
			end
		end,
	},

	{
		Text = function()
			local dt = love.timer.getDelta()
			return string.format("frame time: %.2f ms", dt * 1000)
		end,
		Color = function()
			local dt = love.timer.getDelta() * 1000
			if dt > 33.33 then
				return { 1, 0, 0, 1 }
			elseif dt > 16.67 then
				return { 1, 1, 0, 1 }
			else
				return { 0, 1, 0, 1 }
			end
		end,
	},

	{
		Text = function()
			return "-- NETWORK STATS --"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			local currentTime = love.timer.getTime()
			local timeSinceReset = currentTime - networkStats.lastResetTime
			if timeSinceReset > 0 then
				local rateIn = networkStats.bytesReceived / timeSinceReset
				local rateOut = networkStats.bytesSent / timeSinceReset
				return string.format("traffic: ↓%s/s ↑%s/s", formatBytes(rateIn), formatBytes(rateOut))
			else
				return "traffic: calculating..."
			end
		end,
		Color = function()
			return { 0.5, 1, 0.5, 1 }
		end,
	},

	{
		Text = function()
			return string.format("messages: ↓%d ↑%d", networkStats.messagesReceived, networkStats.messagesSent)
		end,
		Color = function()
			return { 0.7, 0.9, 1, 1 }
		end,
	},

	{
		Text = function()
			return string.format("total data: ↓%s ↑%s", formatBytes(networkStats.bytesReceived),
				formatBytes(networkStats.bytesSent))
		end,
		Color = function()
			return { 0.9, 0.7, 1, 1 }
		end,
	},

	{
		Text = function()
			if LS13.Networking and LS13.Networking.isConnected and LS13.Networking.isConnected() then
				local connTime = love.timer.getTime() - networkStats.connectionTime
				return string.format("connected: %s", formatTime(connTime))
			else
				return "connected: not connected"
			end
		end,
		Color = function()
			return { 1, 1, 0.5, 1 }
		end,
	},

	{
		Text = function()
			return string.format("verbs processed: %d", networkStats.verbsProcessed)
		end,
		Color = function()
			return { 0.8, 1, 0.8, 1 }
		end,
	},

	{
		Text = function()
			return string.format("chunks received: %d", networkStats.chunksReceived)
		end,
		Color = function()
			return { 0.8, 0.8, 1, 1 }
		end,
	},

	{
		Text = function()
			return "-- CONTROLS --"
		end,
		Color = function()
			return { 1, 1, 1, 1 }
		end,
	},

	{
		Text = function()
			return "[R] Reset network stats"
		end,
		Color = function()
			return { 0.7, 0.7, 0.7, 1 }
		end,
	},

	{
		Text = function()
			return "[G] Force garbage collect"
		end,
		Color = function()
			return { 0.7, 0.7, 0.7, 1 }
		end,
	},
}

function debugOverlay.init()
	font = LS13.AssetManager.Get("Font.Monospace")
	networkStats.lastResetTime = love.timer.getTime()
	networkStats.connectionTime = love.timer.getTime()
	init = true
end

function debugOverlay.updateNetworkStats(messageType, bytes, direction)
	if direction == "received" then
		networkStats.messagesReceived = networkStats.messagesReceived + 1
		networkStats.bytesReceived = networkStats.bytesReceived + (bytes or 0)

		if messageType == "ACTION_BROADCAST" then
			networkStats.verbsProcessed = networkStats.verbsProcessed + 1
		elseif messageType == "CHUNK_UPDATE" then
			networkStats.chunksReceived = networkStats.chunksReceived + 1
		end
	elseif direction == "sent" then
		networkStats.messagesSent = networkStats.messagesSent + 1
		networkStats.bytesSent = networkStats.bytesSent + (bytes or 0)
	end
end

-- Function to reset network statistics
function debugOverlay.resetNetworkStats()
	networkStats.messagesReceived = 0
	networkStats.messagesSent = 0
	networkStats.bytesReceived = 0
	networkStats.bytesSent = 0
	networkStats.lastResetTime = love.timer.getTime()
	networkStats.verbsProcessed = 0
	networkStats.chunksReceived = 0
	LS13.Logging.LogInfo("Network statistics reset")
end

-- Function to update connection time
function debugOverlay.onConnected()
	networkStats.connectionTime = love.timer.getTime()
end

local function shadowText(text, x, y, align, color, shadowColor)
	love.graphics.setFont(font.font)
	local textSize = love.graphics.getFont():getWidth(text)

	if align == "center" then
		x = (W() - textSize) / 2
	elseif align == "right" then
		x = W() - textSize - x
	end

	love.graphics.setColor(shadowColor or { 0, 0, 0, 0.5 })
	love.graphics.printf(text, x + 2, y + 2, textSize, align)
	love.graphics.setColor(color or { 1, 1, 1, 1 })
	love.graphics.printf(text, x, y, textSize, align)
	love.graphics.setColor(1, 1, 1, 1)
end

function debugOverlay.update(dt)
	if not init then
		return
	end

	if love.keyboard.isDown("r") and not debugOverlay.rPressed then
		debugOverlay.rPressed = true
		debugOverlay.resetNetworkStats()
	elseif not love.keyboard.isDown("r") then
		debugOverlay.rPressed = false
	end

	if love.keyboard.isDown("g") and not debugOverlay.gPressed then
		debugOverlay.gPressed = true
		local beforeMem = collectgarbage("count")
		collectgarbage("collect")
		local afterMem = collectgarbage("count")
		LS13.Logging.LogInfo("Garbage collected, freed %.2f KB", beforeMem - afterMem)
	elseif not love.keyboard.isDown("g") then
		debugOverlay.gPressed = false
	end
end

function debugOverlay.draw()
	if not init then
		return
	end
	shadowText("!!! debug !!!", 16, 16, "center")

	local startY = 80
	for i, line in ipairs(lines) do
		shadowText(line.Text(), 16, startY + i * 16, "right", line.Color())
	end
end

debugOverlay.updateNetworkStats = debugOverlay.updateNetworkStats
debugOverlay.resetNetworkStats = debugOverlay.resetNetworkStats
debugOverlay.onConnected = debugOverlay.onConnected

_G.DebugOverlay = debugOverlay

return debugOverlay
