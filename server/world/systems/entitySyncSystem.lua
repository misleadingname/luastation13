local serializer = require("shared.replication.serializer")

local replicationSystem = LS13.ECSManager.system({ pool = { "Replicated" } })

local syncInterval = 1 / 20
local nextNetworkId = 1

function replicationSystem:init(world)
	self.world = world
	self.lastSync = 0
end

function replicationSystem:update()
	local currentTime = love.timer.getTime()
	if currentTime - self.lastSync < syncInterval then
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
		nextNetworkId += 1

		replicated.lastReplicatedState = {}
		self:broadcastEntityCreate(entity)
		return
	end

	-- Diff check against last replication
	local changedComponents = serializer.getChangedComponents(entity, replicated.lastReplicatedState)
	if next(changedComponents) then
		self:broadcastEntityUpdate(entity, changedComponents)
		replicated.lastReplicatedState = changedComponents
	end
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

function replicationSystem:broadcastEntityUpdate(entity, changedComponents)
	local buf = buffer.new()

	local count = 0
	for _, _ in pairs(changedComponents) do
		count += 1
	end

	buf:writeUShort(count)
	for name, componentData in pairs(changedComponents) do
		buf:writeString(name)
		buf:appendBuffer(componentData)
	end

	local message = LS13.Networking.Protocol.createMessageEx(NETWORK_MESSAGE_TYPE.ENTITY_UPDATE, {
		id = entity.Replicated.networkId,
		data = tostring(buf),
	})

	LS13.Networking.broadcastMessage(message)
end

function replicationSystem:broadcastEntityDestroy(entity)
	if entity.Replicated and entity.Replicated.networkId then
		local message = LS13.Networking.Protocol.createEntityDestroy(entity.Replicated.networkId)
		LS13.Networking.broadcastMessage(message)
	end
end

LS13.ECS.Systems.ReplicationSystem = replicationSystem
