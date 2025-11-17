local ecs = LS13.ECSManager

local interactableComponent = ecs.component("Interactable", function(c)
	c.interactions = {}
end)
LS13.ECS.Components.Interactable = interactableComponent

local sentienceComponent = ecs.component("Sentience", function(c, clientId)
	c.clientId = clientId or nil -- player
	c.inputEnabled = true
	c.playerCommand = nil
end)
LS13.ECS.Components.Sentience = sentienceComponent
LS13.ECS.Replication.Sentience = {
	{ name = "clientId", NETWORK_TYPE.USHORT },
	{ name = "inputEnabled", NETWORK_TYPE.BOOL }
}

local basicTempCharacter = ecs.component("BasicTempCharacter", function(c) end)
LS13.ECS.Components.BasicTempCharacter = basicTempCharacter
LS13.ECS.Replication.BasicTempCharacter = {}
