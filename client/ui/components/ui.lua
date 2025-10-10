local ecs = LS13.ECSManager

local uiElement = ecs.component("UiElement", function(c, parent, visible, enabled, z)
	c.parent = parent or nil
	c.children = {}
	c.visible = visible or true
	c.enabled = enabled or true
	c.z = z or 0
end)
LS13.ECS.Components.UiElement = uiElement

local uiTransform = ecs.component("UiTransform", function(c, position, size, rotation, posx, posy, sizex, sizey, anchor)
	c.position = position or Vector2.new(0, 0)
	c.size = size or Vector2.new(64, 128)
	c.rotation = rotation or 0

	c.anchor = anchor or Vector2.new(0, 0)
	c.posx = posx or "pixel" -- pixel, ratio
	c.posy = posy or "pixel" -- pixel, ratio
	c.sizex = sizex or "pixel" -- pixel, ratio
	c.sizey = sizey or "pixel" -- pixel, ratio

	c.cpos = Vector2.new(0, 0)
	c.csize = Vector2.new(64, 128)
end)
LS13.ECS.Components.UiTransform = uiTransform

local uiLayout = ecs.component("UiLayout", function(c, type, padding, spacing, align, justify, wrap)
	c.type = type or "vertical" -- vertical, horizontal
	c.padding = padding or Vector2.new(0, 0)
	c.spacing = spacing or 0
	c.align = align or "begin"  -- begin, center, end
	c.justify = justify or "begin" -- begin, center, end, stretch
	c.wrap = wrap or false      -- whether to wrap children to next line/column
end)
LS13.ECS.Components.UiLayout = uiLayout

local uiFlexItem = ecs.component("UiFlexItem", function(c, grow, shrink, basis)
	c.grow = grow or 0     -- flex-grow: how much to grow relative to siblings
	c.shrink = shrink or 1 -- flex-shrink: how much to shrink relative to siblings
	c.basis = basis or "auto" -- flex-basis: initial size before growing/shrinking
end)
LS13.ECS.Components.UiFlexItem = uiFlexItem

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
