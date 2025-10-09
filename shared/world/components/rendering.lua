local ecs = LS13.ECSManager

local rendererComponent = ecs.component("Renderer", function(c, visible)
	c.visible = visible or true
end)
LS13.ECS.Components.Renderer = rendererComponent

local graphicComponent = ecs.component("Graphic", function(c, graphicId, visible, origin, playing)
	c.graphicId = graphicId or "Graphic.Fallback"
	c.visible = visible or true
	c.origin = origin or Vector2.new(0, 0)
	c.tint = Color.new(255, 255, 255, 255)
	c.playing = playing or false
end)
LS13.ECS.Components.Graphic = graphicComponent
