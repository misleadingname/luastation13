local input = {}

local function bool2int(value)
	return value and 1 or 0
end

function input.getMovementVector()
	local x = bool2int(love.keyboard.isDown("d")) - bool2int(love.keyboard.isDown("a"))
	local y = bool2int(love.keyboard.isDown("s")) - bool2int(love.keyboard.isDown("w"))
	return Vector2.new(x, y)
end

return input
