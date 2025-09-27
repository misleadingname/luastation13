-- Simple hierarchical UI example using manual layout
local Inky = require("lib/Inky")

return function()
	-- Create Inky scene and pointer
	local scene = Inky.scene()
	local pointer = Inky.pointer(scene)
	
	-- Load UI components
	local Label = require("client/ui/controls/label")
	local Button = require("client/ui/controls/button")
	
	-- Create a hierarchical structure manually
	local ui = {
		scene = scene,
		pointer = pointer,
		elements = {}
	}
	
	-- Root container concept - we'll manage children manually
	local function createContainer(name, x, y, w, h, backgroundColor)
		return {
			name = name,
			x = x, y = y, w = w, h = h,
			backgroundColor = backgroundColor,
			children = {},
			
			addChild = function(self, child, childX, childY, childW, childH)
				child.x = self.x + (childX or 0)
				child.y = self.y + (childY or 0)
				child.w = childW or child.w or 100
				child.h = childH or child.h or 30
				table.insert(self.children, child)
			end,
			
			render = function(self)
				-- Draw container background
				if self.backgroundColor then
					love.graphics.setColor(self.backgroundColor)
					love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
				end
				
				-- Draw border
				love.graphics.setColor(0.5, 0.5, 0.5, 1)
				love.graphics.setLineWidth(1)
				love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
				
				-- Render children
				for _, child in ipairs(self.children) do
					if child.render then
						child:render()
					elseif child.element then
						-- It's an Inky element
						child.element:render(child.x, child.y, child.w, child.h, 1)
					end
				end
				
				love.graphics.setColor(1, 1, 1, 1)
			end
		}
	end
	
	-- Create root container
	local rootContainer = createContainer("Root", 0, 0, 800, 600, { 0.1, 0.1, 0.15, 1 })
	
	-- Create header container
	local headerContainer = createContainer("Header", 0, 0, 800, 80, { 0.15, 0.15, 0.2, 0.9 })
	
	-- Create header title
	local headerTitle = Label(scene)
	headerTitle.props.text = "LuaStation13 - Hierarchical UI Demo"
	headerTitle.props.color = { 1, 1, 1, 1 }
	headerTitle.props.align = "center"
	headerTitle.props.shadow = true
	
	-- Add title to header
	headerContainer:addChild({ element = headerTitle }, 10, 20, 780, 40)
	
	-- Create main content container
	local mainContainer = createContainer("Main", 0, 80, 800, 440, { 0.08, 0.08, 0.12, 0.9 })
	
	-- Create left panel
	local leftPanel = createContainer("LeftPanel", 0, 0, 200, 440, { 0.12, 0.15, 0.12, 0.9 })
	
	-- Create buttons for left panel
	local buttons = {}
	local buttonNames = { "Build", "Destroy", "Repair", "Examine", "Inventory" }
	
	for i, buttonName in ipairs(buttonNames) do
		local button = Button(scene)
		button.props.text = buttonName
		button.props.backgroundColor = { 0.2, 0.25, 0.2, 1 }
		button.props.hoverColor = { 0.3, 0.35, 0.3, 1 }
		button.props.onClick = function()
			print(buttonName .. " clicked!")
		end
		
		buttons[i] = button
		leftPanel:addChild({ element = button }, 10, 10 + (i - 1) * 45, 180, 35)
	end
	
	-- Create center panel
	local centerPanel = createContainer("CenterPanel", 200, 0, 400, 440, { 0.06, 0.06, 0.1, 0.9 })
	
	-- Create center content
	local centerLabel = Label(scene)
	centerLabel.props.text = "Game View Area\n\nThis demonstrates a hierarchical UI structure:\n\nRoot Container\n├── Header Container\n│   └── Title Label\n├── Main Container\n│   ├── Left Panel\n│   │   └── Tool Buttons\n│   ├── Center Panel\n│   │   └── This Label\n│   └── Right Panel\n│       └── Info Labels\n└── Footer Container\n    └── Status Labels"
	centerLabel.props.color = { 0.8, 0.8, 0.9, 1 }
	centerLabel.props.align = "left"
	
	centerPanel:addChild({ element = centerLabel }, 20, 20, 360, 400)
	
	-- Create right panel
	local rightPanel = createContainer("RightPanel", 600, 0, 200, 440, { 0.15, 0.12, 0.12, 0.9 })
	
	-- Create info labels for right panel
	local infoLabels = {
		"Player Info:",
		"Health: 100%",
		"Oxygen: 98%",
		"Hunger: 85%",
		"",
		"Location:",
		"Medbay",
		"",
		"Time:",
		"15:32"
	}
	
	for i, text in ipairs(infoLabels) do
		local label = Label(scene)
		label.props.text = text
		label.props.color = text == "" and { 0, 0, 0, 0 } or 
		                   (text:match(":$") and { 1, 1, 1, 1 } or { 0.8, 0.8, 0.8, 1 })
		label.props.align = "left"
		
		rightPanel:addChild({ element = label }, 10, 10 + (i - 1) * 20, 180, 18)
	end
	
	-- Create footer container
	local footerContainer = createContainer("Footer", 0, 520, 800, 80, { 0.1, 0.1, 0.1, 0.95 })
	
	-- Create status labels
	local statusTexts = { "Round: 15:32", "Players: 24/32", "Server: Alpha", "Ping: 45ms" }
	for i, text in ipairs(statusTexts) do
		local statusLabel = Label(scene)
		statusLabel.props.text = text
		statusLabel.props.color = { 0.8, 0.8, 0.8, 1 }
		statusLabel.props.align = "center"
		
		footerContainer:addChild({ element = statusLabel }, (i - 1) * 200 + 10, 30, 180, 20)
	end
	
	-- Add all containers to root
	rootContainer:addChild(headerContainer)
	rootContainer:addChild(mainContainer)
	mainContainer:addChild(leftPanel)
	mainContainer:addChild(centerPanel)
	mainContainer:addChild(rightPanel)
	rootContainer:addChild(footerContainer)
	
	-- Store everything in ui object
	ui.rootContainer = rootContainer
	ui.elements = {
		headerTitle = headerTitle,
		centerLabel = centerLabel,
		buttons = buttons
	}
	
	-- UI management functions
	function ui:setPointerPosition(x, y)
		self.pointer:setPosition(x, y)
	end
	
	function ui:raisePointerEvent(eventName, ...)
		self.pointer:raise(eventName, ...)
	end
	
	function ui:raiseSceneEvent(eventName, ...)
		self.scene:raise(eventName, ...)
	end
	
	function ui:render(x, y, w, h, depth)
		-- Begin scene frame
		self.scene:beginFrame()
		
		-- Render the entire hierarchy
		self.rootContainer:render()
		
		-- Finish scene frame
		self.scene:finishFrame()
	end
	
	return ui
end
