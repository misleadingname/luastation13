local InteractionRequestVerb = {}
InteractionRequestVerb.__index = InteractionRequestVerb
setmetatable(InteractionRequestVerb, { __index = LS13.VerbSystem.BaseVerb })

function InteractionRequestVerb.new(name, data)
	local action = LS13.VerbSystem.BaseVerb.new(name, data)
	setmetatable(action, InteractionRequestVerb)
	return action
end

function InteractionRequestVerb:validate()
	if not self.data.interactionName then
		return false, "No interaction specified"
	end
	if not self.data.targetEntityId then
		return false, "No target entity specified"
	end
	return true, nil
end

return InteractionRequestVerb

