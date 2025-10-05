local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

local function resolveTransform(trans, parentSize)
	local pos = Vector2.new(
		(trans.scalex == "ratio") and (trans.position.x * parentSize.x) or trans.position.x,
		(trans.scaley == "ratio") and (trans.position.y * parentSize.y) or trans.position.y
	)

	local size = Vector2.new(
		(trans.scalex == "ratio") and (trans.size.x * parentSize.x) or trans.size.x,
		(trans.scaley == "ratio") and (trans.size.y * parentSize.y) or trans.size.y
	)

	return pos, size
end

local function applyAnchor(pos, size, anchor)
	if not anchor then
		return pos -- fallback if not set
	end
	return pos - Vector2.new(size.x * anchor.x, size.y * anchor.y)
end

function layoutSystem:update()
	-- handle parents with layouts
	for _, parent in ipairs(self.pool) do
		if parent.UiLayout then
			local layout = parent.UiLayout
			local parentTrans = parent.UiTransform
			local children = parent.UiElement.children
			if #children == 0 then
				goto continue
			end

			local parentPos = parentTrans.cpos
			local parentSize = parentTrans.csize

			-- total size of children in layout direction
			local totalSize = 0
			for _, child in ipairs(children) do
				local _, csize = resolveTransform(child.UiTransform, parentSize)
				if layout.type == "vertical" then
					totalSize = totalSize + csize.y
				else
					totalSize = totalSize + csize.x
				end
			end
			if #children > 1 then
				totalSize = totalSize + layout.spacing * (#children - 1)
			end

			-- compute initial offset based on justify
			local offset
			if layout.type == "vertical" then
				if layout.justify == "begin" then
					offset = layout.padding.y
				elseif layout.justify == "center" then
					offset = (parentSize.y - totalSize) / 2
				elseif layout.justify == "end" then
					offset = parentSize.y - totalSize - layout.padding.y
				else -- stretch
					offset = layout.padding.y
				end
			else
				if layout.justify == "begin" then
					offset = layout.padding.x
				elseif layout.justify == "center" then
					offset = (parentSize.x - totalSize) / 2
				elseif layout.justify == "end" then
					offset = parentSize.x - totalSize - layout.padding.x
				else -- stretch
					offset = layout.padding.x
				end
			end

			-- position children
			for _, child in ipairs(children) do
				local ctrans = child.UiTransform
				local cpos, csize = resolveTransform(ctrans, parentSize)

				if layout.type == "vertical" then
					-- horizontal align
					if layout.align == "begin" then
						ctrans.cpos.x = parentPos.x + layout.padding.x + cpos.x
					elseif layout.align == "center" then
						ctrans.cpos.x = parentPos.x + (parentSize.x - csize.x) / 2 + cpos.x
					elseif layout.align == "end" then
						ctrans.cpos.x = parentPos.x + parentSize.x - csize.x - layout.padding.x + cpos.x
					end

					ctrans.cpos.y = parentPos.y + offset + cpos.y
					ctrans.csize = csize
					ctrans.cpos = applyAnchor(ctrans.cpos, ctrans.csize, ctrans.anchor)

					offset = offset + csize.y + layout.spacing
				else
					-- vertical align
					if layout.align == "begin" then
						ctrans.cpos.y = parentPos.y + layout.padding.y + cpos.y
					elseif layout.align == "center" then
						ctrans.cpos.y = parentPos.y + (parentSize.y - csize.y) / 2 + cpos.y
					elseif layout.align == "end" then
						ctrans.cpos.y = parentPos.y + parentSize.y - csize.y - layout.padding.y + cpos.y
					end

					ctrans.cpos.x = parentPos.x + offset + cpos.x
					ctrans.csize = csize
					ctrans.cpos = applyAnchor(ctrans.cpos, ctrans.csize, ctrans.anchor)

					offset = offset + csize.x + layout.spacing
				end
			end
		end
		::continue::
	end

	-- handle non-layout entities
	for _, ent in ipairs(self.pool) do
		local elem = ent.UiElement
		local trans = ent.UiTransform

		if elem.parent and not elem.parent.UiLayout then
			local parentTrans = elem.parent.UiTransform
			local parentSize = parentTrans.csize
			local cpos, csize = resolveTransform(trans, parentSize)

			trans.cpos = parentTrans.cpos + cpos
			trans.csize = csize
			trans.cpos = applyAnchor(trans.cpos, trans.csize, trans.anchor)
		elseif not elem.parent then
			local screenSize = Vector2.new(love.graphics.getDimensions())
			local cpos, csize = resolveTransform(trans, screenSize)

			trans.cpos = cpos
			trans.csize = csize
			trans.cpos = applyAnchor(trans.cpos, trans.csize, trans.anchor)
		end
	end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
