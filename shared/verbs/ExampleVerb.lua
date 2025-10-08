local ExampleVerb = {}
ExampleVerb.__index = ExampleVerb
setmetatable(ExampleVerb, { __index = LS13.VerbSystem.BaseVerb })

function ExampleVerb.new(name, data)
	local action = LS13.VerbSystem.BaseVerb.new(name, data)
	setmetatable(action, ExampleVerb)
	return action
end

function ExampleVerb:validate()
	return true, nil
end

return ExampleVerb
