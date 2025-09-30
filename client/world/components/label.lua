local ecs = LS13.ECSManager

local uiLabel = ecs.component("UiLabel", function(c, text, color, font, hAlign, vAlign)
	c.text = text or ""
	c.color = color or Color.white
	c.font = font or "default"
	c.hAlign = hAlign or "left"
	c.vAlign = vAlign or "top"
end)

LS13.ECS.Components.UiLabel = uiLabel
