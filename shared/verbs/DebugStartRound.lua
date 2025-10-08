local DebugStartVerb = {}
DebugStartVerb.__index = DebugStartVerb
setmetatable(DebugStartVerb, { __index = LS13.VerbSystem.BaseVerb })

function DebugStartVerb.new(name, data)
	local action = LS13.VerbSystem.BaseVerb.new(name, data)
	setmetatable(action, DebugStartVerb)
	return action
end

function DebugStartVerb:validate()
	if DEBUG then
		return true, nil
	end

	return false, "Debug mode is not enabled."
end

return DebugStartVerb
