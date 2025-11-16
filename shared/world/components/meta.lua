local ecs = LS13.ECSManager

local metadataComponent = ecs.component("Metadata", function(c, name)
	c.name = name or string.format("UnknownEntity%s", lume.uuid())
end)
LS13.ECS.Components.Metadata = metadataComponent
LS13.ECS.Replication.Metadata = {
	{ name = "name", type = NETWORK_TYPE.STRING },
}
