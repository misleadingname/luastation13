return LS13.UI.defineElement(function(self, props)
	self.props = props or {}

	self.props.text = self.props.text or "Label!"
	self.props.font = self.props.font or love.graphics.getFont()
	self.props.color = self.props.color or { 1, 1, 1, 1 }
	self.props.align = self.props.align or "left"
	self.props.shadow = self.props.shadow or false

	return function(self, x, y, w, h, depth)
		local text = self.props.text
		local color = self.props.color
		local align = self.props.align
		local shadow = self.props.shadow

		if shadow then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf(text, x + 1, y + 1, w, align)
		end

		love.graphics.setColor(color)
		love.graphics.setFont(self.props.font)
		love.graphics.printf(text, x, y, w, align)
	end
end)
