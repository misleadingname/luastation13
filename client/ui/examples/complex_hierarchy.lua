-- Example of a complex hierarchical UI structure
local Scene = require("client/ui/controls/scene")
local Panel = require("client/ui/controls/panel")
local Container = require("client/ui/controls/container")
local Button = require("client/ui/controls/button")
local Label = require("client/ui/controls/label")

return function()
	-- Create root scene
	local rootScene = Scene()
	rootScene.props.name = "ComplexExample"
	rootScene.props.backgroundColor = { 0.05, 0.05, 0.1, 1 }
	
	-- Header panel
	local headerPanel = Panel()
	headerPanel.props.title = "Game Interface"
	headerPanel.props.layout = "horizontal"
	headerPanel.props.backgroundColor = { 0.15, 0.15, 0.2, 0.95 }
	headerPanel.props.borderColor = { 0.3, 0.3, 0.4, 1 }
	headerPanel.props.padding = { top = 30, right = 10, bottom = 10, left = 10 }
	headerPanel.props.spacing = 10
	
	-- Header buttons
	local menuButton = Button()
	menuButton.props.text = "Menu"
	menuButton.props.onClick = function()
		print("Menu clicked")
	end
	
	local inventoryButton = Button()
	inventoryButton.props.text = "Inventory"
	inventoryButton.props.onClick = function()
		print("Inventory clicked")
	end
	
	local settingsButton = Button()
	settingsButton.props.text = "Settings"
	settingsButton.props.onClick = function()
		print("Settings clicked")
	end
	
	headerPanel:addChild(menuButton)
	headerPanel:addChild(inventoryButton)
	headerPanel:addChild(settingsButton)
	
	-- Main content area
	local mainPanel = Panel()
	mainPanel.props.layout = "horizontal"
	mainPanel.props.backgroundColor = { 0.1, 0.1, 0.15, 0.9 }
	mainPanel.props.borderColor = { 0.2, 0.2, 0.3, 1 }
	mainPanel.props.spacing = 10
	mainPanel.props.padding = { top = 10, right = 10, bottom = 10, left = 10 }
	
	-- Left sidebar
	local leftSidebar = Panel()
	leftSidebar.props.title = "Tools"
	leftSidebar.props.layout = "vertical"
	leftSidebar.props.backgroundColor = { 0.12, 0.15, 0.12, 0.9 }
	leftSidebar.props.borderColor = { 0.25, 0.35, 0.25, 1 }
	leftSidebar.props.padding = { top = 30, right = 10, bottom = 10, left = 10 }
	leftSidebar.props.spacing = 5
	
	-- Tool buttons
	local tools = { "Build", "Destroy", "Repair", "Examine" }
	for _, toolName in ipairs(tools) do
		local toolButton = Button()
		toolButton.props.text = toolName
		toolButton.props.backgroundColor = { 0.2, 0.25, 0.2, 1 }
		toolButton.props.hoverColor = { 0.3, 0.35, 0.3, 1 }
		toolButton.props.onClick = function()
			print(toolName .. " tool selected")
		end
		leftSidebar:addChild(toolButton)
	end
	
	-- Center content area
	local centerPanel = Panel()
	centerPanel.props.title = "Game View"
	centerPanel.props.backgroundColor = { 0.08, 0.08, 0.12, 0.9 }
	centerPanel.props.borderColor = { 0.2, 0.2, 0.3, 1 }
	centerPanel.props.padding = { top = 30, right = 10, bottom = 10, left = 10 }
	
	-- Game view placeholder
	local gameViewLabel = Label()
	gameViewLabel.props.text = "Game View Area\n(This is where the main game would render)"
	gameViewLabel.props.align = "center"
	gameViewLabel.props.color = { 0.7, 0.7, 0.8, 1 }
	
	centerPanel:addChild(gameViewLabel)
	
	-- Right sidebar
	local rightSidebar = Panel()
	rightSidebar.props.title = "Info"
	rightSidebar.props.layout = "vertical"
	rightSidebar.props.backgroundColor = { 0.15, 0.12, 0.12, 0.9 }
	rightSidebar.props.borderColor = { 0.35, 0.25, 0.25, 1 }
	rightSidebar.props.padding = { top = 30, right = 10, bottom = 10, left = 10 }
	rightSidebar.props.spacing = 10
	
	-- Info sections
	local playerInfoContainer = Container()
	playerInfoContainer.props.layout = "vertical"
	playerInfoContainer.props.spacing = 3
	
	local playerNameLabel = Label()
	playerNameLabel.props.text = "Player: John Doe"
	playerNameLabel.props.color = { 1, 1, 1, 1 }
	
	local playerHealthLabel = Label()
	playerHealthLabel.props.text = "Health: 100/100"
	playerHealthLabel.props.color = { 0.5, 1, 0.5, 1 }
	
	local playerOxygenLabel = Label()
	playerOxygenLabel.props.text = "Oxygen: 98%"
	playerOxygenLabel.props.color = { 0.5, 0.8, 1, 1 }
	
	playerInfoContainer:addChild(playerNameLabel)
	playerInfoContainer:addChild(playerHealthLabel)
	playerInfoContainer:addChild(playerOxygenLabel)
	
	-- Action log
	local actionLogContainer = Container()
	actionLogContainer.props.layout = "vertical"
	actionLogContainer.props.spacing = 2
	
	local logTitleLabel = Label()
	logTitleLabel.props.text = "Recent Actions:"
	logTitleLabel.props.color = { 0.8, 0.8, 0.9, 1 }
	
	local logEntries = {
		"Opened airlock",
		"Picked up wrench",
		"Examined console",
		"Moved to corridor"
	}
	
	actionLogContainer:addChild(logTitleLabel)
	for _, entry in ipairs(logEntries) do
		local logLabel = Label()
		logLabel.props.text = "• " .. entry
		logLabel.props.color = { 0.6, 0.6, 0.7, 1 }
		actionLogContainer:addChild(logLabel)
	end
	
	rightSidebar:addChild(playerInfoContainer)
	rightSidebar:addChild(actionLogContainer)
	
	-- Add panels to main content
	mainPanel:addChild(leftSidebar)
	mainPanel:addChild(centerPanel)
	mainPanel:addChild(rightSidebar)
	
	-- Bottom status bar
	local statusPanel = Panel()
	statusPanel.props.layout = "horizontal"
	statusPanel.props.backgroundColor = { 0.1, 0.1, 0.1, 0.95 }
	statusPanel.props.borderColor = { 0.3, 0.3, 0.3, 1 }
	statusPanel.props.padding = { top = 5, right = 10, bottom = 5, left = 10 }
	statusPanel.props.spacing = 20
	
	local statusLabels = {
		"Round Time: 15:32",
		"Players: 24/32",
		"Server: Station Alpha",
		"Ping: 45ms"
	}
	
	for _, statusText in ipairs(statusLabels) do
		local statusLabel = Label()
		statusLabel.props.text = statusText
		statusLabel.props.color = { 0.8, 0.8, 0.8, 1 }
		statusPanel:addChild(statusLabel)
	end
	
	-- Add all panels to root scene with specific positioning
	rootScene:addChild(headerPanel, { x = 0, y = 0, w = 800, h = 60 })
	rootScene:addChild(mainPanel, { x = 0, y = 60, w = 800, h = 480 })
	rootScene:addChild(statusPanel, { x = 0, y = 540, w = 800, h = 40 })
	
	return rootScene
end
