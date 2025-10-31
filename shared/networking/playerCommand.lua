local playerCommand = {}
playerCommand.__index = playerCommand

function playerCommand.new(player)
	local self = setmetatable({}, playerCommand)
	self.MoveDirection = Vector2.new(0, 0)
	self.TargetPosition = Vector2.new(0, 0)

	return self
end

function playerCommand:compare(other)
	if not other then return false end
	return self.MoveDirection:compare(other.MoveDirection)
		and self.TargetPosition:compare(other.TargetPosition)
end

return playerCommand
