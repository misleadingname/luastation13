return LS13.UI.defineElement(function(self, props)
	self.props = props or {}

	self.props.children = self.props.children or {}
	self.props.layout = self.props.layout or "none" -- "none", "vertical", "horizontal", "grid"
	self.props.padding = self.props.padding or { top = 0, right = 0, bottom = 0, left = 0 }
	self.props.spacing = self.props.spacing or 0
	self.props.backgroundColor = self.props.backgroundColor or nil
	self.props.borderColor = self.props.borderColor or nil
	self.props.borderWidth = self.props.borderWidth or 0
	self.props.visible = self.props.visible ~= false

	function self:addChild(child, childProps)
		if child and type(child) == "function" then
			table.insert(self.props.children, {
				element = child,
				props = childProps or {}
			})
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

	-- Layout calculation functions
	local function calculateLayout(containerX, containerY, containerW, containerH, children, layout, padding, spacing)
		local positions = {}
		local innerX = containerX + padding.left
		local innerY = containerY + padding.top
		local innerW = containerW - padding.left - padding.right
		local innerH = containerH - padding.top - padding.bottom

		if layout == "vertical" then
			local childHeight = (#children > 0) and ((innerH - spacing * (#children - 1)) / #children) or 0
			for i = 1, #children do
				local y = innerY + (i - 1) * (childHeight + spacing)
				positions[i] = { x = innerX, y = y, w = innerW, h = childHeight }
			end
		elseif layout == "horizontal" then
			local childWidth = (#children > 0) and ((innerW - spacing * (#children - 1)) / #children) or 0
			for i = 1, #children do
				local x = innerX + (i - 1) * (childWidth + spacing)
				positions[i] = { x = x, y = innerY, w = childWidth, h = innerH }
			end
		else -- layout == "none" or any other value
			-- Children use their own positioning or fill the container
			for i = 1, #children do
				positions[i] = { x = innerX, y = innerY, w = innerW, h = innerH }
			end
		end

		return positions
	end

	return function(self, x, y, w, h, depth)
		if not self.props.visible then
			return
		end

		-- Draw background
		if self.props.backgroundColor then
			love.graphics.setColor(self.props.backgroundColor)
			love.graphics.rectangle("fill", x, y, w, h)
		end

		-- Draw border
		if self.props.borderColor and self.props.borderWidth > 0 then
			love.graphics.setColor(self.props.borderColor)
			love.graphics.setLineWidth(self.props.borderWidth)
			love.graphics.rectangle("line", x, y, w, h)
		end

		-- Calculate child positions based on layout
		local childPositions = calculateLayout(x, y, w, h, self.props.children, self.props.layout, self.props.padding,
			self.props.spacing)

		-- Render children
		for i, childData in ipairs(self.props.children) do
			if childData.element and childPositions[i] then
				local pos = childPositions[i]
				local childElement = childData.element
				local childProps = childData.props

				-- If the child element has props, merge them
				if childElement.props then
					for key, value in pairs(childProps) do
						childElement.props[key] = value
					end
				end

				-- Render the child element
				childElement:render(pos.x, pos.y, pos.w, pos.h, (depth or 0) + 1)
			end
		end

		-- Reset graphics state
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setLineWidth(1)
	end
end)
