local ecs = LS13.ECSManager
local nlay = require("lib.nlay")

local uiElement = ecs.component("UiElement", function(c, parent, visible, enabled, z)
	c.parent = parent or nil
	c.children = {}
	c.visible = visible or true
	c.enabled = enabled or true
	c.z = z or 0
end)
LS13.ECS.Components.UiElement = uiElement

local uiTransform = ecs.component("UiTransform", function(c)
	c.constraint = nil
	c.position = Vector2.new(0, 0)
	c.size = Vector2.new(0, 0)
end)
LS13.ECS.Components.UiTransform = uiTransform

local uiConstraint = ecs.component("UiConstraint", function(c, parent)
	c.parent = parent or nlay  -- parent constraint (defaults to root)
	c.top = nil
	c.left = nil
	c.bottom = nil
	c.right = nil
	c.inTop = false
	c.inLeft = false
	c.inBottom = false
	c.inRight = false
end)
LS13.ECS.Components.UiConstraint = uiConstraint

local uiSize = ecs.component("UiSize", function(c, width, height, widthMode, heightMode)
	c.width = width or -1
	c.height = height or -1
	c.widthMode = widthMode or "pixel" -- pixel, percent
	c.heightMode = heightMode or "pixel"
end)
LS13.ECS.Components.UiSize = uiSize

local uiMargin = ecs.component("UiMargin", function(c, top, left, bottom, right)
	c.top = top or 0
	c.left = left or 0
	c.bottom = bottom or 0
	c.right = right or 0
end)
LS13.ECS.Components.UiMargin = uiMargin

local uiPadding = ecs.component("UiPadding", function(c, top, left, bottom, right)
	c.top = top or 0
	c.left = left or 0
	c.bottom = bottom or 0
	c.right = right or 0
end)
LS13.ECS.Components.UiPadding = uiPadding

-- Bias component (for centering)
local uiBias = ecs.component("UiBias", function(c, horizontal, vertical)
	c.horizontal = horizontal or 0.5  -- 0.0 = left/top, 0.5 = center, 1.0 = right/bottom
	c.vertical = vertical or 0.5
end)
LS13.ECS.Components.UiBias = uiBias

local uiTarget = ecs.component("UiTarget", function(c, toggle)
	c.hovered = false
	c.focused = false
	c.selected = false
	c.toggle = toggle or false

	c.onHover = function() end
	c.onFocus = function() end
	c.onClick = function() end
end)
LS13.ECS.Components.UiTarget = uiTarget

local uiLabel = ecs.component("UiLabel", function(c, text, color, font, hAlign, vAlign)
	c.text = text or ""
	c.color = color or Color.white
	c.font = font or "Font.Default"
	c.hAlign = hAlign or "left" -- left, center, right, justify
	c.vAlign = vAlign or "top" -- top, center, bottom
end)
LS13.ECS.Components.UiLabel = uiLabel

local uiTextField = ecs.component("UiTextField", function(c, value, placeholder, disabled)
	c.value = value or ""
	c.placeholder = placeholder or ""
	c.disabled = disabled or false

	c.cursorPosition = utf8.len(c.value) -- cursor position in characters, not bytes
	c.selectionStart = nil            -- start of text selection (nil means no selection)
	c.selectionEnd = nil              -- end of text selection
end)
LS13.ECS.Components.UiTextField = uiTextField

local uiPanel = ecs.component("UiPanel", function(c, graphic, color)
	c.color = color or Color.white
	c.graphic = graphic or "Graphic.UiPanel"
end)
LS13.ECS.Components.UiPanel = uiPanel
