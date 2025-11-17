local playerCommand = {}
playerCommand.__index = playerCommand

function playerCommand:__tostring()
	return string.format("PLYCMD: MoveDirection: %s, TargetPosition: %s", self.moveDirection, self.targetPosition)
end

function playerCommand.new()
	local self = setmetatable({}, playerCommand)
	self.moveDirection = Vector2.new(0, 0)
	self.targetPosition = Vector2.new(0, 0)

	return self
end

function playerCommand:compare(other)
	if not other then return false end
	return self.moveDirection:compare(other.moveDirection)
		and self.targetPosition:compare(other.targetPosition)
end

return playerCommand
