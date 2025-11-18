local serializer = require("shared.replication.serializer")

local replicationSystem = LS13.ECSManager.system({ pool = { "Replicated" } })

local nextNetworkId = 1

function replicationSystem:init(world)
	self.world = world
	self.lastSync = 0
end

function replicationSystem:update()
	local currentTime = love.timer.getTime()
	if currentTime - self.lastSync < 1 / NETWORK_TICK_RATE then
		return
	end
	self.lastSync = currentTime

	for _, entity in ipairs(self.pool) do
		self:syncEntity(entity)
	end
end

function replicationSystem:syncEntity(entity)
	local replicated = entity.Replicated

	if not replicated.networkId then
		replicated.networkId = nextNetworkId
		nextNetworkId = nextNetworkId + 1

		-- send full snapshot on first time
		replicated.lastReplicatedState = serializer.snapshotEntityComponents(entity)
		self:broadcastEntityCreate(entity)
		return
	end

	-- diff against last replication
	local prevSnapshot = replicated.lastReplicatedState or {}
	local nextSnapshot = serializer.snapshotEntityComponents(entity)
	local added, updated, removed = serializer.diffStates(prevSnapshot, nextSnapshot)

	if next(added) then
		self:broadcastEntityAdd(entity, added)
	end
	if next(updated) then
		self:broadcastEntityUpdate(entity, updated)
	end
	if next(removed) then
		self:broadcastEntityRemove(entity, removed)
	end

	replicated.lastReplicatedState = nextSnapshot
end

function replicationSystem:broadcastEntityCreate(entity)
	local data = serializer.serializeEntityForReplication(entity)
	if data then
		local message = LS13.Networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.ENTITY_CREATE, {
			id = entity.Replicated.networkId,
			data = tostring(data)
		})
		LS13.Networking.broadcastMessage(message)
	end
end

function replicationSystem:broadcastEntityAdd(entity, addedMap)
	local buf = serializer.buildComponentBuffer(addedMap)
	local message = LS13.Networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.ENTITY_ADD, {
		id = entity.Replicated.networkId,
		data = tostring(buf),
	})
	LS13.Networking.broadcastMessage(message)
end

function replicationSystem:broadcastEntityUpdate(entity, updatedMap)
	local buf = serializer.buildComponentBuffer(updatedMap)
	local message = LS13.Networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.ENTITY_UPDATE, {
		id = entity.Replicated.networkId,
		data = tostring(buf),
	})
	LS13.Networking.broadcastMessage(message)
end

function replicationSystem:broadcastEntityRemove(entity, removedSet)
	local buf = buffer.new()
	local count = 0
	for _ in pairs(removedSet) do count = count + 1 end
	buf:writeUShort(count)
	for name, _ in pairs(removedSet) do
		buf:writeString(name)
	end
	local message = LS13.Networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.ENTITY_REMOVE, {
		id = entity.Replicated.networkId,
		data = tostring(buf),
	})
	LS13.Networking.broadcastMessage(message)
end

function replicationSystem:broadcastEntityDestroy(entity)
	if entity.Replicated and entity.Replicated.networkId then
		local message = LS13.Networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.ENTITY_DESTROY, {
			id = entity.Replicated.networkId,
		})
		LS13.Networking.broadcastMessage(message)
	end
end

LS13.ECS.Systems.ReplicationSystem = replicationSystem
