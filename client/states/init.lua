local states = {
	require("client.states.loading"),
	require("client.states.menu"),
}

for _, state in ipairs(states) do
	LS13.StateManager.loadState(state)
end

return states
