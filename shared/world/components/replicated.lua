local ecs = LS13.ECSManager

local replicatedComponent = ecs.component("Replicated", function(c, networkId)
	c.networkId = networkId or nil
	c.lastReplicatedState = {}
end)

LS13.ECS.Components.Replicated = replicatedComponent
