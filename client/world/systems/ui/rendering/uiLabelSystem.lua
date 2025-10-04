local labelSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform", "UiLabel" } })

function labelSystem:draw()
	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform
		local label = ent.UiLabel
		local font = LS13.AssetManager.Get(label.font).font

		local y = trans.cpos.y
		if label.yAlign == "center" then
			y = y - font:getHeight() / 2
		elseif label.yAlign == "bottom" then
			y = y - font:getHeight()
		end

		local text = label.text
		if type(text) == "function" then
			local success, err = pcall(function() text = text() end)
			if not success then
				LS13.Logging.LogError("Error in label %s function: %s", ent.Metadata.name, err)
			end
		else
			text = text
		end

		love.graphics.setColor(label.color:toNumbers())
		love.graphics.setFont(font)
		love.graphics.printf(tostring(text), trans.cpos.x, trans.cpos.y, trans.size.x, label.hAlign)
	end
end

LS13.ECS.Systems.UiLabelSystem = labelSystem
