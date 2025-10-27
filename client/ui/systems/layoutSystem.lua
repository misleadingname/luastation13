--[[
	May god have mercy on my soul, as I have been bashing my head at the wall next to me for 3 hours.
	Flexbox layouts are a spawn of the devil, horrid scums that now will plauge me, and I will be damned for eternity.
	This still might be incorrect and may implode on a more complex layout any moment.

	I am done here, fix it yourself.
	- misleadingname
]]

local layoutSystem = LS13.ECSManager.system({ pool = { "UiElement", "UiTransform" } })

local function resolveTransform(trans, parentSize, entity)
	-- Ensure fallback csize exists (so content fallbacks can be read)
	trans.csize = trans.csize or Vector2.new(0, 0)

	local pos = Vector2.new(
		(trans.posx == "ratio") and (trans.position.x * parentSize.x) or trans.position.x,
		(trans.posy == "ratio") and (trans.position.y * parentSize.y) or trans.position.y
	)

	local sizeX = trans.size.x
	local sizeY = trans.size.y

	-- Handle different size modes, but if "content" use precomputed csize (if present)
	if trans.sizex == "ratio" then
		sizeX = trans.size.x * parentSize.x
	elseif trans.sizex == "content" then
		-- use precomputed csize if available, otherwise 0
		sizeX = trans.csize and trans.csize.x or 0
	end

	if trans.sizey == "ratio" then
		sizeY = trans.size.y * parentSize.y
	elseif trans.sizey == "content" then
		sizeY = trans.csize and trans.csize.y or 0
	end

	local size = Vector2.new(sizeX, sizeY)
	return pos, size
end

local function applyAnchor(pos, size, anchor)
	if not anchor then
		return pos -- fallback if not set
	end
	return pos - Vector2.new(size.x * anchor.x, size.y * anchor.y)
end

local function calculateContentSize(entity, availableSize)
	local trans = entity.UiTransform
	local layout = entity.UiLayout
	local label = entity.UiLabel

	local contentWidth = 0
	local contentHeight = 0

	-- If entity has a label, calculate text size
	if label then
		local font = LS13.AssetManager.Get(label.font).font
		local text = tostring(label.text)
		contentWidth = font:getWidth(text)

		local _, numLines = string.gsub(text, "\n", "\n")
		numLines += 1
		contentHeight = font:getHeight() * numLines
	end

	-- If entity has a layout with children, calculate children size
	if layout and entity.UiElement then
		local children = {}
		for _, child in pairs(entity.UiElement.children) do
			if child.UiTransform then
				table.insert(children, child)
			end
		end

		if #children > 0 then
			if layout.type == "vertical" then
				-- Calculate total height and max width
				local totalHeight = 0
				local maxWidth = 0

				for _, child in pairs(children) do
					-- pass down availableSize so ratio/content sizes are relative to parent's content area
					local _, csize = resolveTransform(child.UiTransform, availableSize, child)
					totalHeight += csize.y
					maxWidth = math.max(maxWidth, csize.x)
				end

				if #children > 1 then
					totalHeight += layout.spacing * (#children - 1)
				end

				contentWidth = math.max(contentWidth, maxWidth + layout.padding.x * 2)
				contentHeight = math.max(contentHeight, totalHeight + layout.padding.y * 2)
			else
				-- Horizontal layout
				local totalWidth = 0
				local maxHeight = 0

				for _, child in pairs(children) do
					local _, csize = resolveTransform(child.UiTransform, availableSize, child)
					totalWidth += csize.x
					maxHeight = math.max(maxHeight, csize.y)
				end

				if #children > 1 then
					totalWidth += layout.spacing * (#children - 1)
				end

				contentWidth = math.max(contentWidth, totalWidth + layout.padding.x * 2)
				contentHeight = math.max(contentHeight, maxHeight + layout.padding.y * 2)
			end
		end
	end

	return contentWidth, contentHeight
end

local function processLayoutEntity(parent)
	local layout = parent.UiLayout
	local parentTrans = parent.UiTransform
	local allChildren = parent.UiElement.children

	-- Filter children to only include those with UiTransform
	local children = {}
	for _, child in pairs(allChildren) do
		if child.UiTransform then
			table.insert(children, child)
		end
	end

	if #children == 0 then
		return
	end

	-- Ensure parent csize/cpos exist
	parentTrans.csize = parentTrans.csize or Vector2.new(parentTrans.size.x, parentTrans.size.y)
	parentTrans.cpos = parentTrans.cpos or Vector2.new(0, 0)

	local parentPos = parentTrans.cpos
	local parentSize = parentTrans.csize

	-- Calculate available space for children (subtract padding) *earlier so we can use it when calculating content sizes*
	local availableSize = Vector2.new(
		math.max(0, parentSize.x - (layout and layout.padding.x or 0) * 2),
		math.max(0, parentSize.y - (layout and layout.padding.y or 0) * 2)
	)

	-- First, calculate content size for children that need it, using availableSize (not full screen)
	for _, child in pairs(children) do
		local ctrans = child.UiTransform
		-- ensure csize exists to be written into and read from resolveTransform
		ctrans.csize = ctrans.csize or Vector2.new(0, 0)
		if ctrans.sizex == "content" or ctrans.sizey == "content" then
			local contentWidth, contentHeight = calculateContentSize(child, availableSize)

			if ctrans.sizex == "content" then
				ctrans.csize.x = contentWidth
			end
			if ctrans.sizey == "content" then
				ctrans.csize.y = contentHeight
			end
		end
	end

	-- Check if parent size should fit content
	local fitContentX = parentTrans.sizex == "content"
	local fitContentY = parentTrans.sizey == "content"

	if layout.type == "vertical" then
		-- Vertical layout
		local totalSize = 0
		for _, child in pairs(children) do
			local _, csize = resolveTransform(child.UiTransform, availableSize, child)
			totalSize += csize.y
		end
		if #children > 1 then
			totalSize += layout.spacing * (#children - 1)
		end

		local offset
		local stretchSpacing = 0
		if layout.justify == "begin" then
			offset = layout.padding.y
		elseif layout.justify == "center" then
			offset = layout.padding.y + (availableSize.y - totalSize) / 2
		elseif layout.justify == "end" then
			offset = layout.padding.y + availableSize.y - totalSize
		elseif layout.justify == "stretch" and #children > 1 then
			local extraSpace = availableSize.y - totalSize + layout.spacing * (#children - 1)
			stretchSpacing = extraSpace / (#children - 1)
			offset = layout.padding.y
		else
			offset = layout.padding.y
		end

		-- Calculate max width if fitting children horizontally
		local maxChildWidth = 0
		if fitContentX then
			for _, child in pairs(children) do
				local _, csize = resolveTransform(child.UiTransform, availableSize, child)
				maxChildWidth = math.max(maxChildWidth, csize.x)
			end
		end

		-- Position children vertically
		for _, child in pairs(children) do
			local ctrans = child.UiTransform
			local cpos, csize = resolveTransform(ctrans, availableSize, child)

			-- horizontal align
			if layout.align == "begin" then
				ctrans.cpos.x = parentPos.x + layout.padding.x + cpos.x
			elseif layout.align == "center" then
				ctrans.cpos.x = parentPos.x + layout.padding.x + (availableSize.x - csize.x) / 2 + cpos.x
			elseif layout.align == "end" then
				ctrans.cpos.x = parentPos.x + layout.padding.x + availableSize.x - csize.x + cpos.x
			else
				ctrans.cpos.x = parentPos.x + layout.padding.x + cpos.x
			end

			ctrans.cpos.y = parentPos.y + offset + cpos.y
			ctrans.csize = csize
			ctrans.cpos = applyAnchor(ctrans.cpos, ctrans.csize, ctrans.anchor)

			local spacing = (layout.justify == "stretch" and stretchSpacing > 0) and stretchSpacing or layout.spacing
			offset += csize.y + spacing
		end

		-- Apply auto-sizing if enabled
		if fitContentX then
			parentTrans.csize.x = maxChildWidth + layout.padding.x * 2
		end
		if fitContentY then
			parentTrans.csize.y = totalSize + layout.padding.y * 2
		end
	else
		-- Horizontal layout with flexbox behavior
		local childData = {}
		local totalBaseSize = 0
		local totalGrow = 0
		local totalShrink = 0

		for _, child in pairs(children) do
			local ctrans = child.UiTransform
			local cpos, csize = resolveTransform(ctrans, availableSize, child)
			local flexItem = child.UiFlexItem
			local grow = flexItem and flexItem.grow or 0
			local shrink = flexItem and flexItem.shrink or 1

			table.insert(childData, {
				entity = child,
				baseSize = csize.x,
				finalSize = csize.x,
				height = csize.y,
				offsetPos = cpos,
				grow = grow,
				shrink = shrink,
			})

			totalBaseSize += csize.x
			totalGrow += grow
			totalShrink += shrink
		end

		if #children > 1 then
			totalBaseSize += layout.spacing * (#children - 1)
		end

		-- Calculate flex grow/shrink
		local remainingSpace = availableSize.x - totalBaseSize
		if remainingSpace > 0 and totalGrow > 0 then
			for _, data in ipairs(childData) do
				if data.grow > 0 then
					data.finalSize = data.finalSize + (remainingSpace * (data.grow / totalGrow))
				end
			end
		elseif remainingSpace < 0 and totalShrink > 0 then
			for _, data in ipairs(childData) do
				if data.shrink > 0 then
					local shrinkAmount = -remainingSpace * (data.shrink / totalShrink)
					data.finalSize = math.max(0, data.finalSize - shrinkAmount)
				end
			end
		end

		-- Recalculate total size after flex
		local totalFinalSize = 0
		for _, data in ipairs(childData) do
			totalFinalSize += data.finalSize
		end
		if #children > 1 then
			totalFinalSize += layout.spacing * (#children - 1)
		end

		-- Calculate initial offset based on justify
		local offset
		local stretchSpacing = 0
		if layout.justify == "begin" then
			offset = layout.padding.x
		elseif layout.justify == "center" then
			offset = layout.padding.x + (availableSize.x - totalFinalSize) / 2
		elseif layout.justify == "end" then
			offset = layout.padding.x + availableSize.x - totalFinalSize
		elseif layout.justify == "stretch" and #children > 1 then
			local extraSpace = availableSize.x - totalFinalSize + layout.spacing * (#children - 1)
			stretchSpacing = extraSpace / (#children - 1)
			offset = layout.padding.x
		else
			offset = layout.padding.x
		end

		-- Calculate max height if fitting children vertically
		local maxChildHeight = 0
		if fitContentY then
			for _, data in ipairs(childData) do
				maxChildHeight = math.max(maxChildHeight, data.height)
			end
		end

		-- Position children horizontally
		for _, data in ipairs(childData) do
			local ctrans = data.entity.UiTransform

			-- vertical align
			if layout.align == "begin" then
				ctrans.cpos.y = parentPos.y + layout.padding.y + data.offsetPos.y
			elseif layout.align == "center" then
				ctrans.cpos.y = parentPos.y + layout.padding.y + (availableSize.y - data.height) / 2 + data.offsetPos.y
			elseif layout.align == "end" then
				ctrans.cpos.y = parentPos.y + layout.padding.y + availableSize.y - data.height + data.offsetPos.y
			else
				ctrans.cpos.y = parentPos.y + layout.padding.y + data.offsetPos.y
			end

			ctrans.cpos.x = parentPos.x + offset + data.offsetPos.x
			ctrans.csize = Vector2.new(data.finalSize, data.height)
			ctrans.cpos = applyAnchor(ctrans.cpos, ctrans.csize, ctrans.anchor)

			local spacing = (layout.justify == "stretch" and stretchSpacing > 0) and stretchSpacing or layout.spacing
			offset += data.finalSize + spacing
		end

		-- Apply auto-sizing if enabled
		if fitContentX then
			parentTrans.csize.x = totalFinalSize + layout.padding.x * 2
		end
		if fitContentY then
			parentTrans.csize.y = maxChildHeight + layout.padding.y * 2
		end
	end
end

local function getHierarchyDepth(entity)
	local depth = 0
	local current = entity.UiElement.parent
	while current do
		depth += 1
		current = current.UiElement and current.UiElement.parent
	end
	return depth
end

function layoutSystem:update(dt)
	-- First pass: Position entities without layout parents (root elements and children of non-layout parents)
	for _, ent in ipairs(self.pool) do
		local elem = ent.UiElement
		local trans = ent.UiTransform

		-- ensure trans.csize/cpos exist
		trans.csize = trans.csize or Vector2.new(trans.size.x, trans.size.y)
		trans.cpos = trans.cpos or Vector2.new(0, 0)

		if elem.parent and not elem.parent.UiLayout then
			-- Parent exists but has no layout - position relative to parent
			local parentTrans = elem.parent.UiTransform
			if parentTrans then
				local parentSize = parentTrans.csize
				local cpos, csize = resolveTransform(trans, parentSize, ent)

				trans.cpos = parentTrans.cpos + cpos
				trans.csize = csize
				trans.cpos = applyAnchor(trans.cpos, trans.csize, trans.anchor)
			else
				-- Parent has no transform - position relative to screen
				local screenSize = Vector2.new(love.graphics.getDimensions())
				local cpos, csize = resolveTransform(trans, screenSize, ent)

				trans.cpos = cpos
				trans.csize = csize
				trans.cpos = applyAnchor(trans.cpos, trans.csize, trans.anchor)
			end
		elseif not elem.parent then
			-- No parent - position relative to screen
			local screenSize = Vector2.new(love.graphics.getDimensions())
			local cpos, csize = resolveTransform(trans, screenSize, ent)

			trans.cpos = cpos
			trans.csize = csize
			trans.cpos = applyAnchor(trans.cpos, trans.csize, trans.anchor)
		end
		-- Note: Entities with layout parents will be positioned by processLayoutEntity
	end

	-- Second pass: Process all layout entities in hierarchy order (parent to child)
	local layoutEntities = {}
	for _, parent in ipairs(self.pool) do
		if parent.UiLayout then
			table.insert(layoutEntities, parent)
		end
	end

	table.sort(layoutEntities, function(a, b)
		return getHierarchyDepth(a) < getHierarchyDepth(b)
	end)

	-- Process each layout entity - this positions all their children
	for _, parent in ipairs(layoutEntities) do
		processLayoutEntity(parent)
	end
end

LS13.ECS.Systems.UiLayoutSystem = layoutSystem
