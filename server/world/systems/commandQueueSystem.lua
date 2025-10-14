local commandQueueSystem = LS13.ECSManager.system({ pool = { "World" } })

function commandQueueSystem:init(world)
	self.world = world
end

function commandQueueSystem:update(dt)
	local worldEnt = self.pool[1]

	if not worldEnt or not worldEnt.World then
		return
	end

	local cmd = worldEnt.World.commandQueue

	for _, command in ipairs(cmd.queue) do
		-- TODO: sync to all clients in this world
	end

	cmd:commit(self.world)
end

LS13.ECS.Systems.CommandQueueSystem = commandQueueSystem
