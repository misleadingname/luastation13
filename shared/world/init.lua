-- world loading, yipper!

LS13.Logging.LogDebug("Preloading world...")
_G.Tilemap = require("shared.world.tilemap")

LS13.VerbSystem = require("shared.verbs")
LS13.VerbSystem.discoverVerbs()

LS13.InteractionSystem = require("shared.interactions")
LS13.InteractionSystem.discoverHandlers()

require("shared.world.components.meta")
require("shared.world.components.transform")
require("shared.world.components.rendering")
require("shared.world.components.physics")
require("shared.world.components.entities")
require("shared.world.components.world")
require("shared.world.components.replicated")

require("shared.world.systems.interactionSystem")

if CLIENT then
	require("client.world.systems.cameraSystem")
	require("client.world.systems.renderTilemapSystem")
	require("client.world.systems.renderEntitiesSystem")
elseif SERVER then
	require("server.world.systems.chunkSyncSystem")
	require("server.world.systems.entitySyncSystem")
	require("server.world.systems.sentienceSystem")
end

local entMethod = LS13.ECSManager.entity
LS13.ECSManager.entity = function(name, ...)
	local entity = entMethod(...)
	entity:give("Metadata", name)

	if SERVER then
		local origGive = entity.give

		function entity:give(componentName, ...)
			local result = origGive(self, componentName, ...)

			if componentName == "Transform" and not self.Replicated then
				origGive(self, "Replicated")
			elseif self.Replicated then
			end

			return result
		end
	end

	return entity
end
