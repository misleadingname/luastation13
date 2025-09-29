local ecs = LS13.ECSManager

ecs.component("Graphic", function(c, graphicId, visible, offset, playing)
	c.graphicId = graphicId
	c.visible = visible or true
	c.offset = offset or Vector2.new(0, 0)
	c.tint = Color.new(255, 255, 255, 255)
	c.playing = playing or false
end)
