local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

local function resolveTransform(trans, parentSize)
	local pos = Vector2.new(
		(trans.posx == "ratio") and (trans.position.x * parentSize.x) or trans.position.x,
		(trans.posy == "ratio") and (trans.position.y * parentSize.y) or trans.position.y
	)

	local size = Vector2.new(
		(trans.sizex == "ratio") and (trans.size.x * parentSize.x) or trans.size.x,
		(trans.sizey == "ratio") and (trans.size.y * parentSize.y) or trans.size.y
	)

	return pos, size
end

local function applyAnchor(pos, size, anchor)
	if not anchor then
		return pos -- fallback if not set
	end
	return pos - Vector2.new(size.x * anchor.x, size.y * anchor.y)
end

local function processLayoutEntity(parent)
	local layout = parent.UiLayout
	local parentTrans = parent.UiTransform
	local children = parent.UiElement.children
	if #children == 0 then
		return
	end

	local parentPos = parentTrans.cpos
	local parentSize = parentTrans.csize

	-- Calculate available space for children (subtract padding)
	local availableSize = Vector2.new(
		parentSize.x - layout.padding.x * 2,
		parentSize.y - layout.padding.y * 2
	)

	-- total size of children in layout direction
	local totalSize = 0
	for _, child in ipairs(children) do
		local _, csize = resolveTransform(child.UiTransform, availableSize)
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
			offset = layout.padding.y + (availableSize.y - totalSize) / 2
		elseif layout.justify == "end" then
			offset = layout.padding.y + availableSize.y - totalSize
		else -- stretch
			offset = layout.padding.y
		end
	else
		if layout.justify == "begin" then
			offset = layout.padding.x
		elseif layout.justify == "center" then
			offset = layout.padding.x + (availableSize.x - totalSize) / 2
		elseif layout.justify == "end" then
			offset = layout.padding.x + availableSize.x - totalSize
		else -- stretch
			offset = layout.padding.x
		end
	end

	-- position children
	for _, child in ipairs(children) do
		local ctrans = child.UiTransform
		local cpos, csize = resolveTransform(ctrans, availableSize)

		if layout.type == "vertical" then
			-- horizontal align
			if layout.align == "begin" then
				ctrans.cpos.x = parentPos.x + layout.padding.x + cpos.x
			elseif layout.align == "center" then
				ctrans.cpos.x = parentPos.x + layout.padding.x + (availableSize.x - csize.x) / 2 + cpos.x
			elseif layout.align == "end" then
				ctrans.cpos.x = parentPos.x + layout.padding.x + availableSize.x - csize.x + cpos.x
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
				ctrans.cpos.y = parentPos.y + layout.padding.y + (availableSize.y - csize.y) / 2 + cpos.y
			elseif layout.align == "end" then
				ctrans.cpos.y = parentPos.y + layout.padding.y + availableSize.y - csize.y + cpos.y
			end

			ctrans.cpos.x = parentPos.x + offset + cpos.x
			ctrans.csize = csize
			ctrans.cpos = applyAnchor(ctrans.cpos, ctrans.csize, ctrans.anchor)

			offset = offset + csize.x + layout.spacing
		end
	end
end

local function getHierarchyDepth(entity)
	local depth = 0
	local current = entity.UiElement.parent
	while current do
		depth = depth + 1
		current = current.UiElement and current.UiElement.parent
	end
	return depth
end

function layoutSystem:update(dt)
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

	local layoutEntities = {}
	for _, parent in ipairs(self.pool) do
		if parent.UiLayout then
			table.insert(layoutEntities, parent)
		end
	end

	table.sort(layoutEntities, function(a, b)
		return getHierarchyDepth(a) < getHierarchyDepth(b)
	end)

	for _, parent in ipairs(layoutEntities) do
		processLayoutEntity(parent)
	end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
