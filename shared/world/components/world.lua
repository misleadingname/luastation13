local ecs = LS13.ECSManager

local worldComponent = ecs.component("World", function(c)
	c.worldId = "default"
	c.tilemap = Tilemap.new()
end)

LS13.ECS.Components.World = worldComponent
