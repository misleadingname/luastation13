local ecs = LS13.ECSManager

local uiElement = ecs.component("UiElement", function(c, parent, visible, enabled, z)
	c.parent = parent or nil
	c.visible = visible or true
	c.enabled = enabled or true
	c.z = z or 0
end)

local uiTransform = ecs.component("UiTransform", function(c, position, rotation, size)
	c.position = position or Vector2.new(0, 0)

	c.rotation = rotation or 0
	c.size = size or Vector2.new(100, 100)

	c.cpos = position or Vector2.new(0, 0)
	c.size = size or Vector2.new(100, 100)
end)

local uiLayout = ecs.component("UiLayout", function(c, type, padding, spacing, align, justify)
	c.type = type or "horizontal"
	c.padding = padding or Vector2.new(0, 0)
	c.spacing = spacing or 0
	c.align = align or "center"
	c.justify = justify or "center"
end)

local uiTarget = ecs.component("UiTarget", function(c)
	c.hovered = false
	c.focused = false
	c.selected = false
end)

LS13.ECS.Components.UiElement = uiElement
LS13.ECS.Components.UiTransform = uiTransform
LS13.ECS.Components.UiLayout = uiLayout
LS13.ECS.Components.UiTarget = uiTarget
