local states = {
	require("client.states.loading"),
	require("client.states.menu"),
	require("client.states.connecting"),
	require("client.states.lobby"),
	require("client.states.game"),
}

for _, state in ipairs(states) do
	LS13.StateManager.loadState(state)
end

return states
