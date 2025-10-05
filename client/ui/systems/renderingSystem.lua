local renderingSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

function renderingSystem:draw()
	for _, ent in ipairs(self.pool) do
		local trans = ent.UiTransform

		if ent.UiPanel then
			local panel = ent.UiPanel
			local graphic = LS13.AssetManager.Get(panel.graphic)
			local img = graphic.image
			local imgw, imgh = img:getDimensions()

			local sliced = graphic.graphicType == "nineSlice"

			if sliced then
				local slice = graphic.slice or { left = 0, right = 0, top = 0, bottom = 0 }

				local x, y = trans.cpos.x, trans.cpos.y
				local w, h = trans.csize.x, trans.csize.y

				love.graphics.setColor(panel.color:toNumbers())

				-- shorthand
				local l, r, t, b = slice.left, slice.right, slice.top, slice.bottom

				-- quads
				local quads = {
					-- corners
					tl     = love.graphics.newQuad(0, 0, l, t, imgw, imgh),
					tr     = love.graphics.newQuad(imgw - r, 0, r, t, imgw, imgh),
					bl     = love.graphics.newQuad(0, imgh - b, l, b, imgw, imgh),
					br     = love.graphics.newQuad(imgw - r, imgh - b, r, b, imgw, imgh),

					-- edges
					top    = love.graphics.newQuad(l, 0, imgw - l - r, t, imgw, imgh),
					bottom = love.graphics.newQuad(l, imgh - b, imgw - l - r, b, imgw, imgh),
					left   = love.graphics.newQuad(0, t, l, imgh - t - b, imgw, imgh),
					right  = love.graphics.newQuad(imgw - r, t, r, imgh - t - b, imgw, imgh),

					-- center
					center = love.graphics.newQuad(l, t, imgw - l - r, imgh - t - b, imgw, imgh),
				}

				-- corners
				love.graphics.draw(img, quads.tl, x, y)
				love.graphics.draw(img, quads.tr, x + w - r, y)
				love.graphics.draw(img, quads.bl, x, y + h - b)
				love.graphics.draw(img, quads.br, x + w - r, y + h - b)

				-- edges
				love.graphics.draw(img, quads.top, x + l, y, 0, (w - l - r) / (imgw - l - r), 1)
				love.graphics.draw(img, quads.bottom, x + l, y + h - b, 0, (w - l - r) / (imgw - l - r), 1)
				love.graphics.draw(img, quads.left, x, y + t, 0, 1, (h - t - b) / (imgh - t - b))
				love.graphics.draw(img, quads.right, x + w - r, y + t, 0, 1, (h - t - b) / (imgh - t - b))

				-- center
				love.graphics.draw(img, quads.center, x + l, y + t, 0, (w - l - r) / (imgw - l - r),
					(h - t - b) / (imgh - t - b))
			else
				love.graphics.setColor(panel.color:toNumbers())
				love.graphics.draw(graphic.image, trans.cpos.x, trans.cpos.y, trans.rotation, trans.csize.x / imgw,
					trans.csize.y / imgh)
			end
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
