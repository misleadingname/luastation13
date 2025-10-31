local baseCvar = {
	name = nil,
	value = nil,
	type = nil,
	flags = 0x00000000
}
baseCvar.__index = baseCvar

function baseCvar.new(name, flags, value, type)
	local self = setmetatable({}, baseCvar)

	self.name = name
	self.flags = flags
	self.value = value
	self.type = type

	return self
end

function baseCvar:__newindex(key, value)
	if key ~= "value" then
		error("Invalid key for cvar " .. self.name)
	end

	if type(value) ~= self.type then
		error("Invalid type for cvar " .. self.name)
	end

	self.value = value
end

return baseCvar
