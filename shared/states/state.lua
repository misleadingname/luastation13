local state = {}

function state.new(name)
	local self = setmetatable({}, { __index = state })
	self.name = name
	return self
end

function state:enter()
	LS13.Logging.LogWarn("Unimplemented %s:enter()", self.name)
end

function state:update(dt)
	LS13.Logging.LogWarn("Unimplemented %s:update()", self.name)
end

function state:exit()
	LS13.Logging.LogWarn("Unimplemented %s:exit()", self.name)
end

function state:draw()
	LS13.Logging.LogWarn("Unimplemented %s:draw()", self.name)
end

return state
