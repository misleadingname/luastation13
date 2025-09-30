local graphicsRenderSystem = LS13.ECS.Systems.GraphicsRenderSystem

function graphicsRenderSystem:draw()
	for _, ent in ipairs(self.pool) do
		local transform = ent.Transform
		local graphic = ent.Graphic

		local offset = graphic.offset
		local position = transform.position + offset

		love.graphics.setColor(graphic.color)
		love.graphics.draw(graphic.sprite, position.x, position.y)
	end
end
