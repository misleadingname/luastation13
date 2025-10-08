local states = {
	require("server.states.preround"),
	require("server.states.round"),
}

for _, state in ipairs(states) do
	LS13.StateManager.loadState(state)
end

return states
