local ecs = LS13.ECSManager

local interactableComponent = ecs.component("Interactable", function(c)
	c.interactions = {}
end)

LS13.ECS.Components.Interactable = interactableComponent

