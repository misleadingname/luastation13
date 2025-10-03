-- world loading, yipper!

LS13.Logging.LogDebug("Preloading world...")
require("shared.world.components.meta")
require("shared.world.components.transform")
require("shared.world.components.rendering")
require("shared.world.components.physics")

if CLIENT then
	require("client.world.components.ui")

	require("client.world.systems.rendering.renderViewportSystem")
	require("client.world.systems.ui.rendering.uiLabelSystem")
	require("client.world.systems.ui.layoutSystem")
elseif SERVER then

end

local entMethod = LS13.ECSManager.entity
LS13.ECSManager.entity = function(name, ...)
	local entity = entMethod(...)
	entity:give("Metadata", name)

	return entity
end
