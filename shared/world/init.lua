-- world loading, yipper!

LS13.Logging.LogDebug("Preloading world...")
require("shared.world.components.transform")
require("shared.world.components.rendering")
require("shared.world.components.physics")

if CLIENT then
	require("client.world.components.ui")

	require("client.world.systems.rendering.graphicSystem")
	require("client.world.systems.ui.layoutSystem")
elseif SERVER then

end
