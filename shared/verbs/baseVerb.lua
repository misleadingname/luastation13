local baseVerb = {}
baseVerb.__index = baseVerb
baseVerb.schema = {}

function baseVerb.new(name, data)
	local action = setmetatable({
		name = name,
		data = data,
		timestamp = love.timer.getTime(),
	}, baseVerb)

	return action
end

function baseVerb:validate()
	return true, nil
end

function baseVerb:serialize(buffer)
	buffer:writeString(self.name)
end

function baseVerb.deserialize(serializedData)
	return baseVerb.new(serializedData.name, serializedData.data)
end

return baseVerb
