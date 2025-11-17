local ecs = LS13.ECSManager

local rendererComponent = ecs.component("Renderer", function(c, visible)
	c.visible = visible or true
end)
LS13.ECS.Components.Renderer = rendererComponent
LS13.ECS.Replication.Renderer = {
	{ name = "visible", type = NETWORK_TYPE.BOOL }
}

local graphicComponent = ecs.component("Graphic", function(c, graphicId, visible, origin, playing)
	c.graphicId = graphicId or "Graphic.Fallback"
	c.visible = visible or true
	c.origin = origin or Vector2.new(0, 0)
	c.tint = Color.new(255, 255, 255, 255)
	c.playing = playing or false
end)
LS13.ECS.Components.Graphic = graphicComponent
LS13.ECS.Replication.Graphic = {
	{ name = "graphicId", type = NETWORK_TYPE.STRING },
	{ name = "visible",   type = NETWORK_TYPE.BOOL },
	{ name = "origin",    type = NETWORK_TYPE.VECTOR2 },
	{ name = "tint",      type = NETWORK_TYPE.COLOR },
	{ name = "playing",   type = NETWORK_TYPE.BOOL },
}


local cameraComponent = ecs.component("Camera", function(c, zoom)
	c.zoom = zoom
end)
LS13.ECS.Components.Camera = cameraComponent
