local ecs = LS13.ECSManager

local transformComponent = ecs.component("Transform", function(c, position, z, rotation, scaleX, scaleY)
	c.position = position or Vector2.new(0, 0)
	c.direction = "left"
	c.z = z or 0

	c.rotation = rotation or 0
	c.scaleX = scaleX or 1
	c.scaleY = scaleY or 1
end)
LS13.ECS.Components.Transform = transformComponent
