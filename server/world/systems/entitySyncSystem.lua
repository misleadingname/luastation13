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

	for _, entity in ipairs(self.pool) do
		self:syncEntity(entity)
	end
end

function entitySyncSystem:syncEntity(entity)
	local replicated = entity.Replicated
	local currentState = self:getCurrentState(entity)

	-- first time replication
	if not replicated.networkId then
		replicated.networkId = nextNetworkId
		nextNetworkId += 1
		replicated.lastReplicatedState = currentState
		self:broadcastEntityCreate(entity)
		return
	end

	-- detect differences since last replication
	local changedComponents = Serializer.getChangedComponents(entity, replicated.lastReplicatedState)
	if next(changedComponents) then
		self:broadcastEntityUpdate(entity, changedComponents)
		replicated.lastReplicatedState = currentState
	end
end

-- Builds a serializable snapshot of all components (except Replicated)
function entitySyncSystem:getCurrentState(entity)
	local state = {}
	for name, component in pairs(entity:getComponents()) do
		if name ~= "Replicated" and type(component) == "table" then
			state[name] = Serializer.serializeComponentForReplication(component)
		end
	end
	return state
end

function entitySyncSystem:broadcastEntityCreate(entity)
	local serialized = Serializer.serializeEntityForReplication(entity)
	if serialized then
		local message = LS13.Networking.Protocol.createEntityCreate(
			serialized.networkId,
			serialized.components
		)
		LS13.Networking.broadcastMessage(message)
	end
end

function entitySyncSystem:broadcastEntityUpdate(entity, changedComponents)
	local message = LS13.Networking.Protocol.createEntityUpdate(
		entity.Replicated.networkId,
		changedComponents
	)
	LS13.Networking.broadcastMessage(message)
end

function entitySyncSystem:broadcastEntityDestroy(entity)
	if entity.Replicated and entity.Replicated.networkId then
		local message = LS13.Networking.Protocol.createEntityDestroy(entity.Replicated.networkId)
		LS13.Networking.broadcastMessage(message)
	end
end

LS13.ECS.Systems.EntitySyncSystem = entitySyncSystem
