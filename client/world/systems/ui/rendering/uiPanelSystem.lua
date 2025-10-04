local panelSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform", "UiPanel" } })

function panelSystem:draw()
	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform
		local panel = ent.UiPanel

		local graphic = LS13.AssetManager.Get(panel.graphic)
		local gsx, gsy = graphic.image:getDimensions()

		love.graphics.setColor(panel.color:toNumbers())
		love.graphics.draw(graphic.image, trans.cpos.x, trans.cpos.y, trans.rotation, trans.size.x / gsx,
			trans.size.y / gsy)
	end
end

LS13.ECS.Systems.UiPanelSystem = panelSystem
