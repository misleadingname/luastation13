return LS13.UI.defineElement(function(self, props)
	self.props = props or {}

	self.props.text = self.props.text or "Button"
	self.props.font = self.props.font or love.graphics.getFont()
	self.props.textColor = self.props.textColor or { 1, 1, 1, 1 }
	self.props.backgroundColor = self.props.backgroundColor or { 0.3, 0.3, 0.3, 1 }
	self.props.hoverColor = self.props.hoverColor or { 0.4, 0.4, 0.4, 1 }
	self.props.pressedColor = self.props.pressedColor or { 0.2, 0.2, 0.2, 1 }
	self.props.borderColor = self.props.borderColor or { 0.6, 0.6, 0.6, 1 }
	self.props.borderWidth = self.props.borderWidth or 1
	self.props.cornerRadius = self.props.cornerRadius or 3
	self.props.padding = self.props.padding or { top = 5, right = 10, bottom = 5, left = 10 }
	self.props.enabled = self.props.enabled ~= false
	self.props.visible = self.props.visible ~= false

	-- Button state
	self.props.hovered = false
	self.props.pressed = false
	self.props.clickCount = 0

	-- Callback functions
	self.props.onClick = self.props.onClick or function() end
	self.props.onHover = self.props.onHover or function() end
	self.props.onPress = self.props.onPress or function() end
	self.props.onRelease = self.props.onRelease or function() end

	-- Event handlers
	self:onPointerEnter(function(element, pointer)
		if self.props.enabled then
			self.props.hovered = true
			self.props.onHover(self, pointer)
		end
	end)

	self:onPointerExit(function(element, pointer)
		self.props.hovered = false
		self.props.pressed = false
	end)

	self:onPointer("press", function(element, pointer)
		if self.props.enabled then
			self.props.pressed = true
			self.props.onPress(self, pointer)
		end
	end)

	self:onPointer("release", function(element, pointer)
		if self.props.enabled and self.props.pressed then
			self.props.pressed = false
			self.props.clickCount = self.props.clickCount + 1
			self.props.onRelease(self, pointer)
			self.props.onClick(self, pointer)
		end
	end)

	-- Public methods
	function self:setText(text)
		self.props.text = text
	end

	function self:setEnabled(enabled)
		self.props.enabled = enabled
		if not enabled then
			self.props.hovered = false
			self.props.pressed = false
		end
	end

	function self:isHovered()
		return self.props.hovered
	end

	function self:isPressed()
		return self.props.pressed
	end

	function self:getClickCount()
		return self.props.clickCount
	end

	return function(element, x, y, w, h, depth)
		if not self.props.visible then
			return
		end

		-- Determine button color based on state
		local bgColor = self.props.backgroundColor
		if not self.props.enabled then
			bgColor = { bgColor[1] * 0.5, bgColor[2] * 0.5, bgColor[3] * 0.5, bgColor[4] * 0.7 }
		elseif self.props.pressed then
			bgColor = self.props.pressedColor
		elseif self.props.hovered then
			bgColor = self.props.hoverColor
		end

		-- Draw button background
		love.graphics.setColor(bgColor)
		if self.props.cornerRadius > 0 then
			love.graphics.rectangle("fill", x, y, w, h, self.props.cornerRadius)
		else
			love.graphics.rectangle("fill", x, y, w, h)
		end

		-- Draw button border
		if self.props.borderColor and self.props.borderWidth > 0 then
			love.graphics.setColor(self.props.borderColor)
			love.graphics.setLineWidth(self.props.borderWidth)
			if self.props.cornerRadius > 0 then
				love.graphics.rectangle("line", x, y, w, h, self.props.cornerRadius)
			else
				love.graphics.rectangle("line", x, y, w, h)
			end
		end

		-- Draw button text
		if self.props.text then
			local textColor = self.props.textColor
			if not self.props.enabled then
				textColor = { textColor[1] * 0.5, textColor[2] * 0.5, textColor[3] * 0.5, textColor[4] * 0.7 }
			end

			love.graphics.setColor(textColor)
			love.graphics.setFont(self.props.font)

			-- Center text in button
			local textX = x + self.props.padding.left
			local textY = y + self.props.padding.top
			local textW = w - self.props.padding.left - self.props.padding.right
			local textH = h - self.props.padding.top - self.props.padding.bottom

			-- Vertical centering
			local font = self.props.font
			local textHeight = font:getHeight()
			local centerY = textY + (textH - textHeight) / 2

			love.graphics.printf(self.props.text, textX, centerY, textW, "center")
		end

		-- Reset graphics state
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setLineWidth(1)
	end
end)
