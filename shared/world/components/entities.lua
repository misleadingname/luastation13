local ecs = LS13.ECSManager

local interactableComponent = ecs.component("Interactable", function(c)
	c.interactions = {}
end)
LS13.ECS.Components.Interactable = interactableComponent

local sentienceComponent = ecs.component("Sentience", function(c, clientId)
	c.clientId = clientId or nil -- player
	c._inputEnabled = true
	c._playerCommand = nil
end)
LS13.ECS.Components.Sentience = sentienceComponent

local basicTempCharacter = ecs.component("BasicTempCharacter", function(c) end)
LS13.ECS.Components.BasicTempCharacter = basicTempCharacter
