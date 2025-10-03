local baseState = require("shared.states.state")

local states = {}
local loadedStates = {}

states.currentState = nil

function states.loadState(state)
	LS13.Logging.LogDebug(string.format("loading state %s", state.name))
	if loadedStates[state.name] then
		return loadedStates[state.name]
	end

	loadedStates[state.name] = state
	return state
end

function states.switchState(name)
	LS13.Logging.LogDebug(string.format("switching to state %s", name))
	if not loadedStates[name] then
		LS13.Logging.LogWarn("%s not preloaded, but switching to it. please preload!!!", name)
		states.loadState(name)
	end

	if states.currentState then
		states.currentState:exit()
	end

	states.currentState = loadedStates[name]
	states.currentState:enter()
end

states.new = baseState.new

states = setmetatable(states, {
	__index = function(t, k)
		if k == "update" or k == "draw" then
			return function(dt)
				if states.currentState then
					states.currentState[k](states.currentState, dt)
				end
			end
		end
	end
})

return states
