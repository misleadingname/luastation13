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

	-- Search through all entities for one with matching metadata name
	for _, entity in ipairs(self.entities) do
		if entity.Metadata and entity.Metadata.name == id then
			return entity
		end
	end

	return nil
end

-- Destroy the scene and clean up all entities
function scene:destroy(world)
	if not world then
		LS13.Logging.LogWarning("No world provided to scene:destroy()")
		return
	end

	for _, entity in ipairs(self.entities) do
		if world:hasEntity(entity) then
			world:removeEntity(entity)
		end
	end

	self.entities = {}
	self.rootEntity = nil
end

-- Get all entities in the scene
function scene:getEntities()
	return self.entities
end

-- Get the root entity of the scene
function scene:getRootEntity()
	return self.rootEntity
end

-- Check if the scene contains a specific entity
function scene:hasEntity(entity)
	for _, sceneEntity in ipairs(self.entities) do
		if sceneEntity == entity then
			return true
		end
	end
	return false
end

return scene
