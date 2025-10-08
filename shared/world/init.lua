-- world loading, yipper!

LS13.Logging.LogDebug("Preloading world...")
_G.Tilemap = require("shared.world.tilemap")

LS13.VerbSystem = require("shared.verbs")
LS13.VerbSystem.discoverVerbs()

require("shared.world.components.meta")
require("shared.world.components.transform")
require("shared.world.components.rendering")
require("shared.world.components.physics")
require("shared.world.components.world")

if CLIENT then
	require("client.world.systems.tilemapSystem")
elseif SERVER then
	require("server.world.systems.chunkSyncSystem")
end

local entMethod = LS13.ECSManager.entity
LS13.ECSManager.entity = function(name, ...)
	local entity = entMethod(...)
	entity:give("Metadata", name)

	return entity
end
