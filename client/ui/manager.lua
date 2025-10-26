-- is this mostly vibecoded?
-- yes! fuck you! ui code, is shite! 

local scene = require("client.ui.scene")

local manager = {}

local scenes = {}
local templates = {}

local function parseColor(colorStr)
	if not colorStr then return Color.white end

	local r, g, b, a = colorStr:match("([%d%.]+),%s*([%d%.]+),%s*([%d%.]+),%s*([%d%.]+)")
	if r and g and b and a then
		return Color.new(tonumber(r) * 255, tonumber(g) * 255, tonumber(b) * 255, tonumber(a) * 255)
	end

	return Color.white
end

local function parseVector2(vecStr)
	if not vecStr then return Vector2.new(0, 0) end

	local x, y = vecStr:match("([%d%.%-]+),%s*([%d%.%-]+)")
	if x and y then
		return Vector2.new(tonumber(x), tonumber(y))
	end

	return Vector2.new(0, 0)
end

local function parseMargin(str)
	if not str then return {0, 0, 0, 0} end
	local values = {}
	for val in str:gmatch("[^,]+") do
		table.insert(values, tonumber(val) or 0)
	end
	if #values == 1 then
		return {values[1], values[1], values[1], values[1]}
	elseif #values == 4 then
		return values
	end
	return {0, 0, 0, 0}
end

local function parseNumber(str, default)
	if not str then return default or 0 end
	return tonumber(str) or default or 0
end

local function substituteParams(text, params)
	if not text or not params then return text end
	local sub = text:gsub("{([^}]+)}", function(paramName)
		return params[paramName] or ("{" .. paramName .. "}")
	end)

	return sub or text
end

local function createEntityFromXML(xmlNode, parentEntity, templateParams)
	if not xmlNode then return nil end

	local entityId = xmlNode._attr and xmlNode._attr.Id or "UnnamedEntity"
	entityId = substituteParams(entityId, templateParams)

	local entity = LS13.ECSManager.entity(entityId)
	entity:give("UiElement", parentEntity)

	for nodeName, nodeData in pairs(xmlNode) do
		if nodeName ~= "_attr" then
			local componentName = nodeName

			if nodeData._attr then
				local attrs = nodeData._attr

				-- replace with a table lookup later, but this works :)
				if componentName == "UiTransform" then
					entity:give("UiTransform")
				elseif componentName == "UiConstraint" then
					local top = substituteParams(attrs.Top, templateParams)
					local left = substituteParams(attrs.Left, templateParams)
					local bottom = substituteParams(attrs.Bottom, templateParams)
					local right = substituteParams(attrs.Right, templateParams)
					local inTop = (attrs.InTop or "false"):lower() == "true"
					local inLeft = (attrs.InLeft or "false"):lower() == "true"
					local inBottom = (attrs.InBottom or "false"):lower() == "true"
					local inRight = (attrs.InRight or "false"):lower() == "true"

					entity:give("UiConstraint")
					entity.UiConstraint.top = top
					entity.UiConstraint.left = left
					entity.UiConstraint.bottom = bottom
					entity.UiConstraint.right = right
					entity.UiConstraint.inTop = inTop
					entity.UiConstraint.inLeft = inLeft
					entity.UiConstraint.inBottom = inBottom
					entity.UiConstraint.inRight = inRight
				elseif componentName == "UiSize" then
					local width = parseNumber(substituteParams(attrs.Width, templateParams), -1)
					local height = parseNumber(substituteParams(attrs.Height, templateParams), -1)
					local widthMode = substituteParams(attrs.WidthMode or "pixel", templateParams)
					local heightMode = substituteParams(attrs.HeightMode or "pixel", templateParams)

					entity:give("UiSize", width, height, widthMode, heightMode)
				elseif componentName == "UiMargin" then
					local margin = parseMargin(substituteParams(attrs.Margin, templateParams))
					entity:give("UiMargin", margin[1], margin[2], margin[3], margin[4])
				elseif componentName == "UiPadding" then
					local padding = parseMargin(substituteParams(attrs.Padding, templateParams))
					entity:give("UiPadding", padding[1], padding[2], padding[3], padding[4])
				elseif componentName == "UiBias" then
					local horizontal = parseNumber(substituteParams(attrs.Horizontal, templateParams), 0.5)
					local vertical = parseNumber(substituteParams(attrs.Vertical, templateParams), 0.5)

					entity:give("UiBias", horizontal, vertical)
				elseif componentName == "UiLabel" then
					local text = substituteParams(attrs.Text or "", templateParams)
					local color = parseColor(substituteParams(attrs.Color, templateParams))
					local font = substituteParams(attrs.Font or "Font.Default", templateParams)
					local hAlign = substituteParams(attrs.HAlign or "left", templateParams)
					local vAlign = substituteParams(attrs.VAlign or "top", templateParams)

					entity:give("UiLabel", text, color, font, hAlign, vAlign)
				elseif componentName == "UiPanel" then
					local graphic = substituteParams(attrs.Graphic or "Graphic.UiPanel", templateParams)
					local color = parseColor(substituteParams(attrs.Color, templateParams))

					entity:give("UiPanel", graphic, color)
				elseif componentName == "UiTarget" then
					local toggle = substituteParams(attrs.Toggle or "false", templateParams):lower() == "true"
					entity:give("UiTarget", toggle)
				elseif componentName == "UiTextField" then
					local value = substituteParams(attrs.Value or "", templateParams)
					local placeholder = substituteParams(attrs.Placeholder or "", templateParams)
					local disabled = substituteParams(attrs.Disabled or "false", templateParams):lower() == "true"

					entity:give("UiTextField", value, placeholder, disabled)
				end
			else
				if componentName == "UiTarget" then
					entity:give("UiTarget")
				end
			end
		end
	end

	return entity
end

local function processTemplateUsage(templateName, attrs, parentEntity, world)
	local template = templates[templateName]
	if not template then
		LS13.Logging.LogWarning("Template not found: %s", templateName)
		return nil
	end

	local params = {}
	for key, defaultValue in pairs(template.params) do
		params[key] = defaultValue
	end

	if attrs then
		for key, value in pairs(attrs) do
			params[key] = value
		end
	end

	local entity = createEntityFromXML(template.content, parentEntity, params)
	if entity and world then
		world:addEntity(entity)
	end

	return entity
end

function manager.registerTemplate(id, data)
	templates[id] = data
	LS13.Logging.LogDebug("Registered UI template: %s", id)
end

function manager.registerScene(id, data)
	scenes[id] = data
	LS13.Logging.LogDebug("Registered UI scene: %s", id)
end

function manager.loadPrototype(path)
	return LS13.PrototypeManager.Parse(path)
end

function manager.createScene(sceneId, world)
	local sceneData = scenes[sceneId]
	if not sceneData then
		LS13.Logging.LogError("Scene not found: %s", sceneId)
		return nil
	end

	local sceneInstance = scene.new()
	sceneInstance.id = sceneId
	sceneInstance.entities = {}

	local rootElement = sceneData.content
	if rootElement then
		local rootEntity = manager.createUIElement(rootElement, nil, world, sceneInstance)
		if rootEntity then
			sceneInstance.rootEntity = rootEntity
		end
	end

	return sceneInstance
end

function manager.createUIElement(xmlNode, parentEntity, world, sceneInstance)
	if not xmlNode then return nil end

	local entities = {}

	-- Always create an entity for UIElement nodes (they may have components even without attributes)
	local rootEntity = createEntityFromXML(xmlNode, parentEntity, {})
	if rootEntity and world then
		world:addEntity(rootEntity)
		if sceneInstance then
			table.insert(sceneInstance.entities, rootEntity)
			if xmlNode._attr and xmlNode._attr.Id then
				sceneInstance.entities[xmlNode._attr.Id] = rootEntity
			end
		end
	end
	table.insert(entities, rootEntity)

	local childParent = rootEntity

	for nodeName, nodeData in pairs(xmlNode) do
		if nodeName ~= "_attr" then
			-- Handle Children block specially
			if nodeName == "Children" then
				-- Process children inside the Children block
				if nodeData.UIElement then
					local childElements = nodeData.UIElement

					-- Handle both single UIElement and array of UIElements
					local childList = {}
					if childElements._attr or childElements.Children then
						-- Single child
						childList = {childElements}
					else
						-- Multiple children
						for _, child in pairs(childElements) do
							table.insert(childList, child)
						end
					end

					-- Create each child entity
					for _, childXml in ipairs(childList) do
						local childEntities = manager.createUIElement(childXml, childParent, world, sceneInstance)
						if childEntities then
							for _, childEntity in ipairs(childEntities) do
								table.insert(entities, childEntity)
								-- Add to parent's children list
								if childParent and childParent.UiElement then
									table.insert(childParent.UiElement.children, childEntity)
								end
							end
						end
					end
				end
			else
				-- Handle both single elements and arrays of elements
				local nodeList = {}

				-- Check if nodeData is a single element or an array
				if nodeData._attr then
					-- Single element, wrap in array for uniform processing
					nodeList = { nodeData }
				elseif type(nodeData) == "table" and lume.count(nodeData) > 0 then
					-- Array of elements (multiple elements with same name)
					-- Use lume.count instead of # because XML tables may have non-consecutive keys
					nodeList = nodeData
				end

				-- Process each element in the list
				-- Use pairs instead of ipairs to handle non-consecutive keys
				for _, elementData in pairs(nodeList) do
					local entity = nil

					if templates[nodeName] then
						entity = processTemplateUsage(nodeName, elementData._attr, childParent, world)
						if entity and sceneInstance then
							table.insert(sceneInstance.entities, entity)
							if elementData._attr and elementData._attr.Id then
								sceneInstance.entities[elementData._attr.Id] = entity
							end
						end
					elseif nodeName == "UIElement" then
						local childEntities = manager.createUIElement(elementData, childParent, world, sceneInstance)
						if childEntities then
							for _, childEntity in ipairs(childEntities) do
								table.insert(entities, childEntity)
							end
						end
					elseif nodeName == "UIEntity" then
						-- UIEntity creates a single entity with components (used in templates)
						-- It should NOT create a wrapper entity like UIElement does
						entity = createEntityFromXML(elementData, childParent, {})
						if entity and world then
							world:addEntity(entity)
							if sceneInstance then
								table.insert(sceneInstance.entities, entity)
								if elementData._attr and elementData._attr.Id then
									sceneInstance.entities[elementData._attr.Id] = entity
								end
							end
						end
					end

					if entity then
						table.insert(entities, entity)
					end
				end
			end
		end
	end

	return entities
end

function manager.init()
	LS13.Logging.LogInfo("UI Manager initialized")
end

function manager.getTemplate(templateId)
	return templates[templateId]
end

function manager.getScene(sceneId)
	return scenes[sceneId]
end

function manager.listTemplates()
	local templateList = {}
	for id, _ in pairs(templates) do
		table.insert(templateList, id)
	end
	return templateList
end

function manager.listScenes()
	local sceneList = {}
	for id, _ in pairs(scenes) do
		table.insert(sceneList, id)
	end
	return sceneList
end

return manager
