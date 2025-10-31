local Serializer = require("shared.replication.serializer")

local entitySyncSystem = LS13.ECSManager.system({ pool = { "Replicated" } })

local syncInterval = 1 / 20
local nextNetworkId = 1

function entitySyncSystem:init(world)
	self.world = world
	self.lastSync = 0
end

function entitySyncSystem:update()
	local currentTime = love.timer.getTime()
	if currentTime - self.lastSync < syncInterval then
		return
	end
	self.lastSync = currentTime

	-- TODO: figure out dirtyness automatically
	for _, entity in ipairs(self.pool) do
		if entity.Replicated.dirty then
			self:syncEntity(entity)
			entity.Replicated.dirty = false
		end
	end
end

function entitySyncSystem:syncEntity(entity)
	if not entity.Replicated.networkId then
		entity.Replicated.networkId = nextNetworkId
		nextNetworkId += 1
		self:broadcastEntityCreate(entity)
	else
		local changedComponents = Serializer.getChangedComponents(entity, entity.Replicated.lastReplicatedState)
		if next(changedComponents) then
			self:broadcastEntityUpdate(entity, changedComponents)
		end
	end

	local currentState = {}
	for componentName, component in pairs(entity:getComponents()) do
		if componentName ~= "Replicated" and type(component) == "table" then
			currentState[componentName] = Serializer.serializeComponentForReplication(component)
		end
	end
	entity.Replicated.lastReplicatedState = currentState
end

function entitySyncSystem:broadcastEntityCreate(entity)
	local serialized = Serializer.serializeEntityForReplication(entity)
	if serialized then
		local message = LS13.Networking.Protocol.createEntityCreate(serialized.networkId, serialized.components)
		LS13.Networking.broadcastMessage(message)
	end
end

function entitySyncSystem:broadcastEntityUpdate(entity, changedComponents)
	local message = LS13.Networking.Protocol.createEntityUpdate(entity.Replicated.networkId, changedComponents)
	LS13.Networking.broadcastMessage(message)
end

function entitySyncSystem:broadcastEntityDestroy(entity)
	if entity.Replicated and entity.Replicated.networkId then
		local message = LS13.Networking.Protocol.createEntityDestroy(entity.Replicated.networkId)
		LS13.Networking.broadcastMessage(message)
	end
end

LS13.ECS.Systems.EntitySyncSystem = entitySyncSystem
