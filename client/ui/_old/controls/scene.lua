return LS13.UI.defineElement(function(self, props)
	self.props = props or {}

	self.props.children = self.props.children or {}
	self.props.backgroundColor = self.props.backgroundColor or nil
	self.props.name = self.props.name or "Scene"
	self.props.visible = self.props.visible ~= false

	self.scene = LS13.UI.scene()
	self.pointer = LS13.UI.pointer(self.scene)

	function self:addChild(childElement, childProps)
		if childElement then
			local child = {
				element = childElement(self.scene), -- Create element instance with scene
				props = childProps or {}
			}
			table.insert(self.props.children, child)
			return child.element
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

	self:onEnable(function()
	end)

	self:onDisable(function()
	end)

	function self:setPointerPosition(x, y)
		self.pointer:setPosition(x, y)
	end

	function self:raisePointerEvent(eventName, ...)
		self.pointer:raise(eventName, ...)
	end

	function self:raiseSceneEvent(eventName, ...)
		self.scene:raise(eventName, ...)
	end

	return function(element, x, y, w, h, depth)
		if not self.props.visible then
			return
		end

		self.scene:beginFrame()

		if self.props.backgroundColor then
			love.graphics.setColor(self.props.backgroundColor)
			love.graphics.rectangle("fill", x, y, w, h)
		end

		for i, childData in ipairs(self.props.children) do
			if childData.element then
				local childElement = childData.element
				local childProps = childData.props

				if childElement.props and childProps then
					for key, value in pairs(childProps) do
						childElement.props[key] = value
					end
				end

				local childX = childProps.x or x
				local childY = childProps.y or y
				local childW = childProps.w or w
				local childH = childProps.h or h
				local childDepth = (depth or 0) + 1

				childElement:render(childX, childY, childW, childH, childDepth)
			end
		end

		self.scene:finishFrame()
	end
end)
