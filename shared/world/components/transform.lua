local ecs = LS13.ECSManager

local transformComponent = ecs.component("Transform", function(c, position, z, rotation, scale)
	c.position = position or Vector2.new(0, 0)
	c.direction = Vector2.new(1, 0)
	c.facing = DIRECTION_RIGHT
	c.z = z or 0

	c.rotation = rotation or 0
	c.scale = scale or Vector2.new(1, 1)
end)

LS13.ECS.Components.Transform = transformComponent
LS13.ECS.Replication.Transform = {
	{ name = "position",  type = NETWORK_TYPE.VECTOR2 },
	{ name = "direction", type = NETWORK_TYPE.VECTOR2 },
	{ name = "facing",    type = NETWORK_TYPE.BYTE },
	{ name = "z",         type = NETWORK_TYPE.BYTE },
	{ name = "rotation",  type = NETWORK_TYPE.FLOAT },
	{ name = "scale",     type = NETWORK_TYPE.VECTOR2 },
}
