local RoundState = LS13.StateManager.new("Round")

function RoundState:enter()
	LS13.WorldManager.init()
end

function RoundState:update(dt) end

function RoundState:exit() end

return RoundState
