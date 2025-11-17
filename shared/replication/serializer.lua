local serializer = {}

-- Serialize a single component according to LS13.ECS.Replication schema
function serializer.serializeComponentForReplication(component)
	if not component then
		LS13.Logging.LogError("Tried to serialize nil component")
		return nil
	end

	local info = LS13.ECS.Replication[component:getName()]
	if not info then
		return nil
	end

	local buf = buffer.new()
	for _, entry in ipairs(info) do
		local name = entry.name
		local type = entry.type
		LS13.Networking.Protocol.write(buf, type, component[name])
	end
	return buf
end

function serializer.snapshotEntityComponents(entity)
	local snapshot = {}
	for name, component in pairs(entity:getComponents()) do
		if LS13.ECS.Replication[name] and type(component) == "table" then
			local compBuf = serializer.serializeComponentForReplication(component)
			if compBuf then
				snapshot[name] = tostring(compBuf)
			end
		end
	end
	return snapshot
end

-- buffer with: USHORT count, then for each entry: STRING name + raw component data
function serializer.buildComponentBuffer(mapNameToBytes)
	local buf = buffer.new()
	local count = 0
	for _ in pairs(mapNameToBytes) do count = count + 1 end
	buf:writeUShort(count)
	for name, bytes in pairs(mapNameToBytes) do
		buf:writeString(name)
		-- append the serialized bytes
		local compBuf = buffer.fromString(bytes)
		buf:appendBuffer(compBuf)
	end
	return buf
end

-- buffer representing the full entity creation payload
function serializer.serializeEntityForReplication(entity)
	if not entity or not entity.Replicated then
		return nil
	end
	local snapshot = serializer.snapshotEntityComponents(entity)
	return serializer.buildComponentBuffer(snapshot)
end

-- diff two snapshots (name->bytes) and return tables: added, updated, removed
function serializer.diffStates(prev, next)
	local added, updated, removed = {}, {}, {}
	-- detect removed and updated
	for name, prevBytes in pairs(prev or {}) do
		local nextBytes = (next or {})[name]
		if not nextBytes then
			removed[name] = true
		elseif nextBytes ~= prevBytes then
			updated[name] = nextBytes
		end
	end
	-- detect added
	for name, nextBytes in pairs(next or {}) do
		if not (prev or {})[name] then
			added[name] = nextBytes
		end
	end
	return added, updated, removed
end

return serializer
