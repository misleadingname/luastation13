local ecs = LS13.ECSManager

local uiElement = ecs.component("UiElement", function(c, parent, visible, enabled, z)
	c.parent = parent or nil
	c.visible = visible or true
	c.enabled = enabled or true
	c.z = z or 0
end)
LS13.ECS.Components.UiElement = uiElement

local uiTransform = ecs.component("UiTransform", function(c, position, rotation, size)
	c.position = position or Vector2.new(0, 0)
	c.size = size or Vector2.new(100, 100)
	c.rotation = rotation or 0

	c.cpos = Vector2.new(0, 0)
end)
LS13.ECS.Components.UiTransform = uiTransform

local uiLayout = ecs.component("UiLayout", function(c, type, padding, spacing, align, justify)
	c.type = type or "vertical" -- vertical, horizontal
	c.padding = padding or Vector2.new(0, 0)
	c.spacing = spacing or 0
	c.align = align or "begin"  -- begin, center, end
	c.justify = justify or "begin" -- begin, center, end, stretch
end)
LS13.ECS.Components.UiLayout = uiLayout

local uiTarget = ecs.component("UiTarget", function(c)
	c.hovered = false
	c.focused = false
	c.selected = false
end)
LS13.ECS.Components.UiTarget = uiTarget
