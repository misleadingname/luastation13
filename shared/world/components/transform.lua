local ecs = LS13.ECSManager

ecs.component("Transform", function(c, x, y, z, r, sx, sy)
	c.x = x or 0
	c.y = y or 0
	c.z = z or 0

	c.r = r or 0
	c.sx = sx or 1
	c.sy = sy or 1
end)