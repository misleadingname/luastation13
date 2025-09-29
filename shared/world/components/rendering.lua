local ecs = LS13.ECSManager

ecs.component("GraphicRenderer", function(c, graphicId, offset)
	c.graphicId = graphicId
	c.playing = true
end)
