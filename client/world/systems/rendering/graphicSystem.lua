local graphicsRenderSystem = LS13.ECS.Systems.GraphicsRenderSystem

function graphicsRenderSystem:draw()
	for _, ent in ipairs(self.pool) do
		local transform = ent.Transform
		local graphicComp = ent.Graphic
		local graphic = LS13.AssetManager.Get(graphicComp.graphicId)

		local offset = graphicComp.offset
		local position = transform.position + offset

		love.graphics.setColor(graphicComp.tint:toNumbers())
		love.graphics.draw(graphic.image, position.x, position.y)
	end
end
