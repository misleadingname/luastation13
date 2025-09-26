-- UI Manager - manages hierarchical UI scenes and input handling
local UIManager = {}

function UIManager:new()
	local manager = {
		currentScene = nil,
		scenes = {},
		mouseX = 0,
		mouseY = 0,
		inputEnabled = true
	}

	setmetatable(manager, { __index = self })
	return manager
end

-- Scene management
function UIManager:addScene(name, sceneFactory)
	if type(sceneFactory) == "function" then
		self.scenes[name] = sceneFactory()
	else
		self.scenes[name] = sceneFactory
	end
end

function UIManager:setCurrentScene(name)
	if self.scenes[name] then
		self.currentScene = self.scenes[name]
		return true
	end
	return false
end

function UIManager:getCurrentScene()
	return self.currentScene
end

function UIManager:removeScene(name)
	if self.scenes[name] then
		if self.currentScene == self.scenes[name] then
			self.currentScene = nil
		end
		self.scenes[name] = nil
		return true
	end
	return false
end

-- Input handling
function UIManager:setInputEnabled(enabled)
	self.inputEnabled = enabled
end

function UIManager:isInputEnabled()
	return self.inputEnabled
end

function UIManager:updateMouse(x, y)
	self.mouseX = x
	self.mouseY = y

	if self.currentScene and self.inputEnabled and self.currentScene.setPointerPosition then
		self.currentScene:setPointerPosition(x, y)
	end
end

function UIManager:handleMousePressed(x, y, button)
	if self.currentScene and self.inputEnabled and self.currentScene.raisePointerEvent then
		self.currentScene:raisePointerEvent("press", button)
	end
end

function UIManager:handleMouseReleased(x, y, button)
	if self.currentScene and self.inputEnabled and self.currentScene.raisePointerEvent then
		self.currentScene:raisePointerEvent("release", button)
	end
end

function UIManager:handleKeyPressed(key, scancode, isrepeat)
	if self.currentScene and self.inputEnabled and self.currentScene.raiseSceneEvent then
		self.currentScene:raiseSceneEvent("keypressed", key, scancode, isrepeat)
	end
end

function UIManager:handleKeyReleased(key, scancode)
	if self.currentScene and self.inputEnabled and self.currentScene.raiseSceneEvent then
		self.currentScene:raiseSceneEvent("keyreleased", key, scancode)
	end
end

function UIManager:handleTextInput(text)
	if self.currentScene and self.inputEnabled and self.currentScene.raiseSceneEvent then
		self.currentScene:raiseSceneEvent("textinput", text)
	end
end

-- Rendering
function UIManager:render(x, y, w, h)
	if self.currentScene and self.currentScene.render then
		self.currentScene:render(x or 0, y or 0, w or love.graphics.getWidth(), h or love.graphics.getHeight(), 0)
	end
end

function UIManager:update(dt)
	-- Update current scene if needed
	if self.currentScene and self.currentScene.update then
		self.currentScene:update(dt)
	end
end

-- Utility functions
function UIManager:getSceneNames()
	local names = {}
	for name, _ in pairs(self.scenes) do
		table.insert(names, name)
	end
	return names
end

function UIManager:hasScene(name)
	return self.scenes[name] ~= nil
end

-- Debug functions
function UIManager:debugInfo()
	local info = {
		currentScene = self.currentScene and self.currentScene.props.name or "none",
		sceneCount = 0,
		mousePosition = { x = self.mouseX, y = self.mouseY },
		inputEnabled = self.inputEnabled
	}

	for _ in pairs(self.scenes) do
		info.sceneCount = info.sceneCount + 1
	end

	return info
end

function UIManager:printDebugInfo()
	local info = self:debugInfo()
	print("=== UI Manager Debug Info ===")
	print("Current Scene: " .. info.currentScene)
	print("Scene Count: " .. info.sceneCount)
	print("Mouse Position: (" .. info.mousePosition.x .. ", " .. info.mousePosition.y .. ")")
	print("Input Enabled: " .. tostring(info.inputEnabled))
	print("Available Scenes:")
	for _, name in ipairs(self:getSceneNames()) do
		print("  - " .. name)
	end
	print("=============================")
end

return UIManager
