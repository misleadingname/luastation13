local renderingSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function renderingSystem:draw()
	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform

		if ent.UiPanel then
			local panel = ent.UiPanel

			local graphic = LS13.AssetManager.Get(panel.graphic)
			local gsx, gsy = graphic.image:getDimensions()

			love.graphics.setColor(panel.color:toNumbers())
			love.graphics.draw(
				graphic.image,
				trans.cpos.x,
				trans.cpos.y,
				trans.rotation,
				trans.csize.x / gsx,
				trans.csize.y / gsy
			)
		end

		if ent.UiLabel then
			local label = ent.UiLabel
			local font = LS13.AssetManager.Get(label.font).font

			local text = label.text
			if type(text) == "function" then
				local success, err = pcall(function()
					text = text()
				end)
				if not success then
					LS13.Logging.LogError("Error in label %s function: %s", ent.Metadata.name, err)
				end
			else
				text = text
			end

			local _, numLines = string.gsub(tostring(text), "\n", "\n")
			numLines = numLines + 1

			local textHeight = font:getHeight() * numLines

			local y = trans.cpos.y
			if label.vAlign == "center" then
				y = y + trans.csize.y / 2 - textHeight / 2
			elseif label.vAlign == "bottom" then
				y = y + trans.csize.y - textHeight
			end

			love.graphics.setColor(label.color:toNumbers())
			love.graphics.setFont(font)
			love.graphics.printf(tostring(text), trans.cpos.x, y, trans.csize.x, label.hAlign)
		end
	end
end

LS13.ECS.Systems.UiRenderingSystem = renderingSystem
