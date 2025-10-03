local renderViewportSystem = LS13.ECSManager.system({ pool = { "Transform", "Renderer" } })

function renderViewportSystem:draw()
	for _, ent in ipairs(self.pool) do
		local transform = ent.Transform
		if ent.Graphic then
			-- local graphicComp = ent.Graphic
			-- local graphic = LS13.AssetManager.Get(graphicComp.graphicId) or LS13.AssetManager.Get("Graphic.Fallback")

			-- local offset = graphicComp.offset
			-- local position = transform.position + offset

			-- love.graphics.setColor(graphicComp.tint:toNumbers())
			-- love.graphics.draw(graphic.image, position.x, position.y)
		end
	end
end

LS13.ECS.Systems.RenderViewportSystem = renderViewportSystem
