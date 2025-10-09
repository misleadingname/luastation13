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
					local position = parseVector2(substituteParams(attrs.Position, templateParams))
					local size = parseVector2(substituteParams(attrs.Size, templateParams))
					local rotation = tonumber(substituteParams(attrs.Rotation or "0", templateParams)) or 0
					local posX = substituteParams(attrs.PosX or "pixel", templateParams)
					local posY = substituteParams(attrs.PosY or "pixel", templateParams)
					local sizeX = substituteParams(attrs.SizeX or "pixel", templateParams)
					local sizeY = substituteParams(attrs.SizeY or "pixel", templateParams)
					local anchor = parseVector2(substituteParams(attrs.Anchor or "0,0", templateParams))

					entity:give("UiTransform", position, size, rotation, posX, posY, sizeX, sizeY, anchor)
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
				elseif componentName == "UiLayout" then
					local layoutType = substituteParams(attrs.Type or "vertical", templateParams):lower()
					local padding = parseVector2(substituteParams(attrs.Padding or "0,0", templateParams))
					local spacing = tonumber(substituteParams(attrs.Spacing or "0", templateParams))
					local align = substituteParams(attrs.Align or "begin", templateParams)
					local justify = substituteParams(attrs.Justify or "begin", templateParams)

					entity:give("UiLayout", layoutType, padding, spacing, align, justify)
				elseif componentName == "UiTarget" then
					entity:give("UiTarget")
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

	local rootEntity = nil
	if xmlNode._attr or not parentEntity then
		rootEntity = createEntityFromXML(xmlNode, parentEntity, {})
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
	end

	local childParent = rootEntity or parentEntity

	for nodeName, nodeData in pairs(xmlNode) do
		if nodeName ~= "_attr" then
			-- Handle both single elements and arrays of elements
			local nodeList = {}

			-- Check if nodeData is a single element or an array
			if nodeData._attr then
				-- Single element, wrap in array for uniform processing
				nodeList = { nodeData }
			elseif type(nodeData) == "table" and #nodeData > 0 then
				-- Array of elements (multiple elements with same name)
				nodeList = nodeData
			end

			-- Process each element in the list
			for _, elementData in ipairs(nodeList) do
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
				end

				if entity then
					table.insert(entities, entity)
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
