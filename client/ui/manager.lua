local manager = {}
manager.__index = manager

function manager.new(name)
	local self = setmetatable({}, manager)

	self.name = string.format("%s(%s)", name or "Scene", lume.uuid())
	self.active = true
	self.scene = LS13.UI.Inky.scene()
	self.pointer = LS13.UI.Inky.pointer(self.scene)

	self.rootElement = nil

	return self
end

function manager:SetRootElement(element)
	self.rootElement = element
end

function manager:Update(dt)
	local x, y = love.mouse.getPosition()
	self.pointer:setPosition(x, y)
end

function manager:Draw()
	if not self.rootElement then error("There's no root element to render!") end
	local w, h = love.graphics.getDimensions()

	self.scene:beginFrame()
	self.rootElement:render(0, 0, w, h)
	self.scene:finishFrame()
end

function manager:MousePressed(x, y, button)
	self.pointer:raise("press", button)
end

function manager:MouseReleased(x, y, button)
	self.pointer:raise("release", button)
end

return manager
