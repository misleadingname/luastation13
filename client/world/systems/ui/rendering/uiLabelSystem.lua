local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform", "UiLabel" } })

function layoutSystem:draw()
	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform
		local label = ent.UiLabel
		local font = LS13.AssetManager.Get(label.font).font

		love.graphics.setColor(label.color:toNumbers())
		love.graphics.setFont(font)
		love.graphics.print(label.text, trans.cpos.x, trans.cpos.y)
	end
end

LS13.ECS.Systems.UiLabelSystem = layoutSystem
