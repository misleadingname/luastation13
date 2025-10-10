local scene = {}
scene.__index = scene

function scene.new()
	local self = setmetatable({}, scene)
	self.id = nil
	self.entities = {}
	self.rootEntity = nil
	return self
end

function scene:getElementById(id) -- javascript ass lmao
	if self.entities[id] then
		return self.entities[id]
	end

	for _, entity in ipairs(self.entities) do
		if entity.Metadata and entity.Metadata.name == id then
			return entity
		end
	end

	return nil
end

function scene:destroy(world)
	if not world then
		LS13.Logging.LogWarning("No world provided to scene:destroy()")
		return
	end

	for _, entity in ipairs(self.entities) do
		world:removeEntity(entity)
	end

	self.entities = {}
	self.rootEntity = nil
end

function scene:getEntities()
	return self.entities
end

function scene:getRootEntity()
	return self.rootEntity
end

function scene:hasEntity(entity)
	for _, sceneEntity in ipairs(self.entities) do
		if sceneEntity == entity then
			return true
		end
	end
	return false
end

return scene
