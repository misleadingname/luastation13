local ecs = LS13.ECSManager

local transformComponent = ecs.component("Transform", function(c, v, z, r, sx, sy)
	c.v = v or Vector2.new(0, 0)
	c.z = z or 0

	c.r = r or 0
	c.sx = sx or 1
	c.sy = sy or 1
end)

LS13.ECS.Components.Transform = transformComponent
