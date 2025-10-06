local ConnectingState = LS13.StateManager.new("Connecting")

local frame

function ConnectingState:enter()
	frame = 1
end

function ConnectingState:update(dt)
	if frame == 1 then
		LS13.Networking.start(LS13.Networking.ConnectingIp)
	end

	frame = frame + 1
end

function ConnectingState:draw()
	love.graphics.clear(0.2, 0.1, 0.4)
end

function ConnectingState:exit() end

return ConnectingState
