return LS13.UI.defineElement(function(self, props)
	self.props = props or {}

	self.props.children = self.props.children or {}
	self.props.layout = self.props.layout or "none" -- "none", "vertical", "horizontal", "grid"
	self.props.padding = self.props.padding or { top = 5, right = 5, bottom = 5, left = 5 }
	self.props.margin = self.props.margin or { top = 0, right = 0, bottom = 0, left = 0 }
	self.props.spacing = self.props.spacing or 5
	self.props.backgroundColor = self.props.backgroundColor or { 0.2, 0.2, 0.2, 0.8 }
	self.props.borderColor = self.props.borderColor or { 0.5, 0.5, 0.5, 1 }
	self.props.borderWidth = self.props.borderWidth or 1
	self.props.cornerRadius = self.props.cornerRadius or 0
	self.props.visible = self.props.visible ~= false
	self.props.title = self.props.title or nil
	self.props.titleHeight = self.props.titleHeight or 25
	self.props.titleFont = self.props.titleFont or love.graphics.getFont()
	self.props.titleColor = self.props.titleColor or { 1, 1, 1, 1 }

	-- Child management functions
	function self:addChild(childElement, childProps)
		if childElement then
			table.insert(self.props.children, {
				element = childElement,
				props = childProps or {}
			})
			return #self.props.children
		end
	end

	function self:removeChild(index)
		if index and self.props.children[index] then
			table.remove(self.props.children, index)
		end
	end

	function self:clearChildren()
		self.props.children = {}
	end

	function self:getChild(index)
		return self.props.children[index]
	end

	function self:getChildCount()
		return #self.props.children
	end

	local function calculateChildLayout(containerX, containerY, containerW, containerH, children, layout, padding,
										spacing, titleHeight)
		local positions = {}
		local innerX = containerX + padding.left
		local innerY = containerY + padding.top + (titleHeight or 0)
		local innerW = containerW - padding.left - padding.right
		local innerH = containerH - padding.top - padding.bottom - (titleHeight or 0)

		if layout == "vertical" then
			local availableHeight = innerH - spacing * math.max(0, #children - 1)
			local childHeight = (#children > 0) and (availableHeight / #children) or 0
			for i = 1, #children do
				local y = innerY + (i - 1) * (childHeight + spacing)
				positions[i] = { x = innerX, y = y, w = innerW, h = childHeight }
			end
		elseif layout == "horizontal" then
			local availableWidth = innerW - spacing * math.max(0, #children - 1)
			local childWidth = (#children > 0) and (availableWidth / #children) or 0
			for i = 1, #children do
				local x = innerX + (i - 1) * (childWidth + spacing)
				positions[i] = { x = x, y = innerY, w = childWidth, h = innerH }
			end
		elseif layout == "grid" then
			-- simple grid layout - assumes square grid
			local cols = math.ceil(math.sqrt(#children))
			local rows = math.ceil(#children / cols)
			local cellW = (innerW - spacing * (cols - 1)) / cols
			local cellH = (innerH - spacing * (rows - 1)) / rows

			for i = 1, #children do
				local col = ((i - 1) % cols)
				local row = math.floor((i - 1) / cols)
				local x = innerX + col * (cellW + spacing)
				local y = innerY + row * (cellH + spacing)
				positions[i] = { x = x, y = y, w = cellW, h = cellH }
			end
		else -- layout == "none"
			-- children use manual positioning or fill the container
			for i = 1, #children do
				local childProps = children[i].props or {}
				positions[i] = {
					x = childProps.x or innerX,
					y = childProps.y or innerY,
					w = childProps.w or innerW,
					h = childProps.h or innerH
				}
			end
		end

		return positions
	end

	return function(element, x, y, w, h, depth)
		if not self.props.visible then
			return
		end

		local margin = self.props.margin
		local panelX = x + margin.left
		local panelY = y + margin.top
		local panelW = w - margin.left - margin.right
		local panelH = h - margin.top - margin.bottom

		if self.props.backgroundColor then
			love.graphics.setColor(self.props.backgroundColor)
			if self.props.cornerRadius > 0 then
				-- Simple rounded rectangle approximation
				love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, self.props.cornerRadius)
			else
				love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)
			end
		end

		if self.props.borderColor and self.props.borderWidth > 0 then
			love.graphics.setColor(self.props.borderColor)
			love.graphics.setLineWidth(self.props.borderWidth)
			if self.props.cornerRadius > 0 then
				love.graphics.rectangle("line", panelX, panelY, panelW, panelH, self.props.cornerRadius)
			else
				love.graphics.rectangle("line", panelX, panelY, panelW, panelH)
			end
		end

		local titleHeight = 0
		if self.props.title then
			titleHeight = self.props.titleHeight
			love.graphics.setColor(self.props.titleColor)
			love.graphics.setFont(self.props.titleFont)
			love.graphics.printf(self.props.title, panelX + self.props.padding.left, panelY + 5,
				panelW - self.props.padding.left - self.props.padding.right, "left")
		end

		local childPositions = calculateChildLayout(panelX, panelY, panelW, panelH, self.props.children,
			self.props.layout, self.props.padding, self.props.spacing, titleHeight)

		for i, childData in ipairs(self.props.children) do
			if childData.element and childPositions[i] then
				local pos = childPositions[i]
				local childElement = childData.element
				local childProps = childData.props

				if childElement.props and childProps then
					for key, value in pairs(childProps) do
						childElement.props[key] = value
					end
				end

				childElement:render(pos.x, pos.y, pos.w, pos.h, (depth or 0) + 1)
			end
		end
	end
end)
