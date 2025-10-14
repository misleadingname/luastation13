local commandQueue = {}
commandQueue.__index = commandQueue
commandQueue.__metatable = "CommandQueue"

commandQueue.CHUNK_SIZE = 8

function commandQueue.new()
	local self = setmetatable({}, commandQueue)
	self.queue = {}

	return self
end

function commandQueue:__index(key)
	return rawget(commandQueue, key)
end

function commandQueue:addEntity(entity)
	table.insert(self.queue, { "add_ent", entity })
end

function commandQueue:removeEntity(entity)
	table.insert(self.queue, { "remove_ent", entity })
end

function commandQueue:giveComponent(entity, component)
	table.insert(self.queue, { "give_comp", entity, component })
end

function commandQueue:removeComponent(entity, component)
	table.insert(self.queue, { "remove_comp", entity, component })
end

function commandQueue:commit(world)
	for _, command in ipairs(self.queue) do
		if command[1] == "add_ent" then
			world:addEntity(command[2])
		end
		if command[1] == "remove_ent" then
			world:removeEntity(command[2])
		end
		if command[1] == "give_comp" then
			command[2]:give(command[3])
		end
		if command[1] == "remove_comp" then
			command[2]:remove(command[3])
		end
	end

	self.queue = {}
end

return commandQueue
