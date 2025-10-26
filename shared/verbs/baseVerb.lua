local baseVerb = {}
baseVerb.__index = baseVerb

function baseVerb.new(name, data)
	local action = setmetatable({
		name = name,
		data = data or {},
		timestamp = love.timer.getTime(),
	}, baseVerb)

	return action
end

function baseVerb:validate()
	return true, nil
end

function baseVerb:serialize()
	return {
		name = self.name,
		data = self.data,
		timestamp = self.timestamp
	}
end

function baseVerb.deserialize(serializedData)
	return baseVerb.new(serializedData.name, serializedData.data)
end

return baseVerb
