local baseVerb = {}
baseVerb.__index = baseVerb
baseVerb.schema = {}

function baseVerb.new(name, data)
	local action = setmetatable({
		name = name,
		data = data or {},
	}, baseVerb)

	return action
end

function baseVerb:validate()
	return true, nil
end

function baseVerb:serialize(buf)
	for _, tbl in ipairs(self.schema) do
		local data = self.data[tbl[1]]
		local type = tbl[2]
		LS13.Networking.Protocol.write(buf, type, data)
	end
end

function baseVerb:deserialize(serializedData)
	local data = {}
	for _, tbl in ipairs(self.schema) do
		local type = tbl[2]
		data[tbl[1]] = LS13.Networking.Protocol.read(serializedData, type)
	end

	return baseVerb.new(serializedData.name, data)
end

return baseVerb
